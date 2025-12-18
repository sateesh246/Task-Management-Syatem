package com.taskmanagement.servlet;

import com.taskmanagement.dao.*;
import com.taskmanagement.model.*;
import com.taskmanagement.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet for handling task editing operations
 * Supports optimistic locking and complex business logic
 */
@WebServlet(name = "TaskEditServlet", urlPatterns = {"/tasks/*/edit"})
public class TaskEditServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(TaskEditServlet.class.getName());
    
    private TaskDAO taskDAO;
    private EmployeeDAO employeeDAO;
    private DepartmentDAO departmentDAO;
    private TaskActivityLogDAO activityLogDAO;
    
    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
		employeeDAO = new EmployeeDAO();
		departmentDAO = new DepartmentDAO();
		activityLogDAO = new TaskActivityLogDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee currentUser = (Employee) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            // Extract task ID from URL
            String pathInfo = request.getPathInfo();
            if (pathInfo == null || pathInfo.length() <= 1) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Task ID is required");
                return;
            }
            
            String[] pathParts = pathInfo.split("/");
            if (pathParts.length < 2) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid URL format");
                return;
            }
            
            int taskId;
            try {
                taskId = Integer.parseInt(pathParts[1]);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid task ID");
                return;
            }
            
            // Get task details
            Task task = taskDAO.getTaskById(taskId);
            if (task == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
                return;
            }
            
            // Check permissions
            if (!canEditTask(currentUser, task)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, 
                    "You don't have permission to edit this task");
                return;
            }
            
            // Load form data
            loadFormData(request, task, currentUser);
            
            // Forward to JSP
            request.getRequestDispatcher("/task-edit.jsp").forward(request, response);
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error in TaskEditServlet.doGet", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Database error occurred");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee currentUser = (Employee) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            // Extract task ID
            int taskId = Integer.parseInt(request.getParameter("taskId"));
            int submittedVersion = Integer.parseInt(request.getParameter("version"));
            boolean forceUpdate = "true".equals(request.getParameter("forceUpdate"));
            
            // Get current task
            Task currentTask = taskDAO.getTaskById(taskId);
            if (currentTask == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
                return;
            }
            
            // Check permissions
            if (!canEditTask(currentUser, currentTask)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, 
                    "You don't have permission to edit this task");
                return;
            }
            
            // Check for version conflicts (optimistic locking)
            if (!forceUpdate && currentTask.getVersion() != submittedVersion) {
                handleVersionConflict(request, response, currentTask, submittedVersion);
                return;
            }
            
            // Validate and process the update
            if (processTaskUpdate(request, response, currentTask, currentUser)) {
                // Success - redirect to task detail page
                response.sendRedirect(request.getContextPath() + "/tasks/" + taskId + 
                    "?success=task_updated");
            }
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid task ID or version");
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error in TaskEditServlet.doPost", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Database error occurred");
        }
    }
    
    private boolean canEditTask(Employee user, Task task) {
        // Admins can edit any task
        if (user.getRole() == Employee.Role.ADMIN) {
            return true;
        }
        
        // Managers can edit tasks in their department or tasks they created
        if (user.getRole() == Employee.Role.MANAGER) {
            return task.getDepartmentId() == user.getDepartmentId() || 
                   task.getCreatedBy() == user.getId();
        }
        
        // Employees can only edit tasks they created (limited scenarios)
        return task.getCreatedBy() == user.getId();
    }
    
    private void loadFormData(HttpServletRequest request, Task task, Employee currentUser) 
            throws SQLException {
        
        // Set task data
        request.setAttribute("task", task);
        request.setAttribute("currentUser", currentUser);
        
        // Load enums for dropdowns
        request.setAttribute("taskPriorities", Task.Priority.values());
        request.setAttribute("taskStatuses", Task.Status.values());
        
        // Load available employees for assignment
        List<Employee> availableEmployees;
        if (currentUser.getRole() == Employee.Role.ADMIN) {
            availableEmployees = employeeDAO.getAllActiveEmployees();
        } else {
            // Managers can only assign within their department
            availableEmployees = employeeDAO.getEmployeesByDepartment(currentUser.getDepartmentId());
        }
        request.setAttribute("availableEmployees", availableEmployees);
        
        // Load available tasks for dependencies (exclude current task and completed/cancelled)
        List<Task> availableTasks = taskDAO.getTasksForDependency(task.getId());
        request.setAttribute("availableTasks", availableTasks);
        
        // Load current assignments and dependencies
        task.setAssignments(taskDAO.getTaskAssignments(task.getId()));
        task.setDependencies(taskDAO.getTaskDependencies(task.getId()));
    }
    
    private void handleVersionConflict(HttpServletRequest request, HttpServletResponse response, 
                                     Task currentTask, int submittedVersion) 
            throws ServletException, IOException, SQLException {
        
        // Load the latest task data
        loadFormData(request, currentTask, (Employee) request.getSession().getAttribute("currentUser"));
        
        // Set conflict information
        request.setAttribute("versionConflict", true);
        request.setAttribute("currentVersion", currentTask.getVersion());
        request.setAttribute("submittedVersion", submittedVersion);
        
        // Get last modification info
        List<TaskActivityLog> recentActivity = activityLogDAO.getTaskActivity(currentTask.getId(), 1);
        if (!recentActivity.isEmpty()) {
            TaskActivityLog lastActivity = recentActivity.get(0);
            request.setAttribute("lastModifiedBy", lastActivity.getEmployeeName());
            request.setAttribute("lastModifiedAt", lastActivity.getCreatedAt());
        }
        
        request.setAttribute("errorMessage", 
            "This task has been modified by another user. Please review the changes.");
        
        // Forward back to edit form
        request.getRequestDispatcher("/task-edit.jsp").forward(request, response);
    }
    
    private boolean processTaskUpdate(HttpServletRequest request, HttpServletResponse response, 
                                    Task currentTask, Employee currentUser) 
            throws SQLException, ServletException, IOException {
        
        // Validate input
        Map<String, String> errors = validateTaskInput(request);
        if (!errors.isEmpty()) {
            // Reload form with errors
            loadFormData(request, currentTask, currentUser);
            setValidationErrors(request, errors);
            request.getRequestDispatcher("/task-edit.jsp").forward(request, response);
            return false;
        }
        
        // Create updated task object
        Task updatedTask = buildUpdatedTask(request, currentTask);
        
        // Process the update with all related changes
        boolean success = taskDAO.updateTaskWithRelatedData(
            updatedTask,
            parseAssignmentChanges(request),
            parseDependencyChanges(request),
            currentUser.getId()
        );
        
        if (!success) {
            request.setAttribute("errorMessage", "Failed to update task. Please try again.");
            loadFormData(request, currentTask, currentUser);
            request.getRequestDispatcher("/task-edit.jsp").forward(request, response);
            return false;
        }
        
        return true;
    }
    
    private Map<String, String> validateTaskInput(HttpServletRequest request) {
        Map<String, String> errors = new HashMap<>();
        
        // Validate title
        String title = request.getParameter("title");
        if (!ValidationUtil.isValidTaskTitle(title)) {
            errors.put("titleError", "Title must be between 3 and 200 characters");
        }
        
        // Validate description
        String description = request.getParameter("description");
        if (!ValidationUtil.isValidTaskDescription(description)) {
            errors.put("descriptionError", "Description must be between 10 and 2000 characters");
        }
        
        // Validate due date
        String dueDateStr = request.getParameter("dueDate");
        try {
            LocalDate dueDate = LocalDate.parse(dueDateStr);
            if (dueDate.isBefore(LocalDate.now())) {
                errors.put("dueDateError", "Due date cannot be in the past");
            }
        } catch (Exception e) {
            errors.put("dueDateError", "Invalid due date format");
        }
        
        // Validate priority
        String priority = request.getParameter("priority");
        try {
            Task.Priority.valueOf(priority);
        } catch (IllegalArgumentException e) {
            errors.put("priorityError", "Invalid priority value");
        }
        
        return errors;
    }
    
    private Task buildUpdatedTask(HttpServletRequest request, Task currentTask) {
        Task updatedTask = new Task();
        updatedTask.setId(currentTask.getId());
        updatedTask.setVersion(currentTask.getVersion());
        updatedTask.setTitle(request.getParameter("title").trim());
        updatedTask.setDescription(request.getParameter("description").trim());
        updatedTask.setPriority(Task.Priority.valueOf(request.getParameter("priority")));
        updatedTask.setDueDate(LocalDate.parse(request.getParameter("dueDate")));
        
        // Handle status change if provided
        String statusParam = request.getParameter("status");
        if (statusParam != null && !statusParam.isEmpty()) {
            updatedTask.setStatus(Task.Status.valueOf(statusParam));
        } else {
            updatedTask.setStatus(currentTask.getStatus());
        }
        
        // Keep other fields unchanged
        updatedTask.setDepartmentId(currentTask.getDepartmentId());
        updatedTask.setCreatedBy(currentTask.getCreatedBy());
        updatedTask.setCreatedAt(currentTask.getCreatedAt());
        
        return updatedTask;
    }
    
    private Map<String, Object> parseAssignmentChanges(HttpServletRequest request) {
        Map<String, Object> changes = new HashMap<>();
        
        // New assignments
        String[] newAssignees = request.getParameterValues("newAssignees");
        List<Integer> addedAssignees = new ArrayList<>();
        if (newAssignees != null) {
            for (String assigneeId : newAssignees) {
                try {
                    addedAssignees.add(Integer.parseInt(assigneeId));
                } catch (NumberFormatException e) {
                    // Skip invalid IDs
                }
            }
        }
        changes.put("added", addedAssignees);
        
        // Removed assignments
        String[] removedAssignments = request.getParameterValues("removedAssignments");
        List<Integer> removedAssignees = new ArrayList<>();
        if (removedAssignments != null) {
            for (String assigneeId : removedAssignments) {
                try {
                    removedAssignees.add(Integer.parseInt(assigneeId));
                } catch (NumberFormatException e) {
                    // Skip invalid IDs
                }
            }
        }
        changes.put("removed", removedAssignees);
        
        return changes;
    }
    
    private Map<String, Object> parseDependencyChanges(HttpServletRequest request) {
        Map<String, Object> changes = new HashMap<>();
        
        // New dependencies
        String[] newDependencies = request.getParameterValues("newDependencies");
        List<Integer> addedDependencies = new ArrayList<>();
        if (newDependencies != null) {
            for (String taskId : newDependencies) {
                try {
                    addedDependencies.add(Integer.parseInt(taskId));
                } catch (NumberFormatException e) {
                    // Skip invalid IDs
                }
            }
        }
        changes.put("added", addedDependencies);
        
        // Removed dependencies
        String[] removedDependencies = request.getParameterValues("removedDependencies");
        List<Integer> removedDeps = new ArrayList<>();
        if (removedDependencies != null) {
            for (String taskId : removedDependencies) {
                try {
                    removedDeps.add(Integer.parseInt(taskId));
                } catch (NumberFormatException e) {
                    // Skip invalid IDs
                }
            }
        }
        changes.put("removed", removedDeps);
        
        return changes;
    }
    
    private void setValidationErrors(HttpServletRequest request, Map<String, String> errors) {
        for (Map.Entry<String, String> error : errors.entrySet()) {
            request.setAttribute(error.getKey(), error.getValue());
        }
    }
}