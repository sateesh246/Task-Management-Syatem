package com.taskmanagement.servlet;

import com.taskmanagement.dao.*;
import com.taskmanagement.model.*;
import com.taskmanagement.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

/**
 * Servlet for creating new tasks
 * Only accessible to MANAGER and ADMIN roles
 */
@WebServlet("/tasks/create")
public class TaskCreateServlet extends HttpServlet {
    
    private TaskDAO taskDAO;
    private DepartmentDAO departmentDAO;
    private EmployeeDAO employeeDAO;
    private TaskActivityLogDAO activityLogDAO;
    private NotificationDAO notificationDAO;
    
    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
        departmentDAO = new DepartmentDAO();
        employeeDAO = new EmployeeDAO();
        activityLogDAO = new TaskActivityLogDAO();
        notificationDAO = new NotificationDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Load reference data for form
            loadReferenceData(request);
            
            // Forward to task creation form
            request.getRequestDispatcher("/task-create.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading task creation form: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Parse and validate form data (use default admin user for creation)
            Task task = parseTaskFromRequest(request);
            
            if (task == null) {
                // Validation errors - reload form with error messages
                loadReferenceData(request);
                request.getRequestDispatcher("/task-create.jsp").forward(request, response);
                return;
            }
            
            // Create the task
            if (taskDAO.create(task)) {
                // Log task creation (use admin user ID = 1)
                activityLogDAO.logTaskCreation(task.getId(), 1, task.getTitle());
                
                // Handle initial assignments if provided
                String[] assigneeIds = request.getParameterValues("assignees");
                if (assigneeIds != null && assigneeIds.length > 0) {
                    handleInitialAssignments(task.getId(), assigneeIds);
                }
                
                // Handle initial dependencies if provided
                String[] dependencyIds = request.getParameterValues("dependencies");
                if (dependencyIds != null && dependencyIds.length > 0) {
                    handleInitialDependencies(task.getId(), dependencyIds);
                }
                
                // Redirect to task detail page
                response.sendRedirect(request.getContextPath() + "/tasks/" + task.getId() + "?success=task_created");
                
            } else {
                request.setAttribute("errorMessage", "Failed to create task. Please try again.");
                loadReferenceData(request);
                request.getRequestDispatcher("/task-create.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error creating task: " + e.getMessage());
            loadReferenceData(request);
            request.getRequestDispatcher("/task-create.jsp").forward(request, response);
        }
    }
    
    /**
     * Parse task from request parameters with validation
     */
    private Task parseTaskFromRequest(HttpServletRequest request) {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String priorityStr = request.getParameter("priority");
        String dueDateStr = request.getParameter("dueDate");
        String departmentIdStr = request.getParameter("departmentId");
        
        boolean hasErrors = false;
        
        // Validate title
        if (!ValidationUtil.isValidTitle(title)) {
            request.setAttribute("titleError", "Title is required and must be 3-200 characters");
            hasErrors = true;
        }
        
        // Validate description
        if (!ValidationUtil.isValidDescription(description)) {
            request.setAttribute("descriptionError", "Description is required and must be 10-2000 characters");
            hasErrors = true;
        }
        
        // Validate priority
        Task.Priority priority;
        try {
            priority = Task.Priority.valueOf(priorityStr);
        } catch (IllegalArgumentException e) {
            request.setAttribute("priorityError", "Invalid priority selected");
            hasErrors = true;
            priority = Task.Priority.MEDIUM; // Default
        }
        
        // Validate due date
        LocalDate dueDate;
        try {
            dueDate = LocalDate.parse(dueDateStr);
            if (!ValidationUtil.isValidDueDate(dueDate)) {
                request.setAttribute("dueDateError", "Due date must be in the future");
                hasErrors = true;
            }
        } catch (DateTimeParseException e) {
            request.setAttribute("dueDateError", "Invalid due date format");
            hasErrors = true;
            dueDate = LocalDate.now().plusDays(7); // Default
        }
        
        // Validate department
        int departmentId;
        try {
            departmentId = Integer.parseInt(departmentIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("departmentError", "Invalid department selected");
            hasErrors = true;
            departmentId = 1; // Default to first department
        }
        
        if (hasErrors) {
            // Preserve form data for redisplay
            request.setAttribute("formTitle", title);
            request.setAttribute("formDescription", description);
            request.setAttribute("formPriority", priorityStr);
            request.setAttribute("formDueDate", dueDateStr);
            request.setAttribute("formDepartmentId", departmentIdStr);
            return null;
        }
        
        // Sanitize inputs
        title = ValidationUtil.sanitizeInput(title);
        description = ValidationUtil.sanitizeInput(description);
        
        // Create task object (use admin user ID = 1 as creator)
        Task task = new Task(title, description, priority, dueDate, departmentId, 1);
        
        return task;
    }
    
    /**
     * Handle initial task assignments
     */
    private void handleInitialAssignments(int taskId, String[] assigneeIds) {
        for (String assigneeIdStr : assigneeIds) {
            try {
                int assigneeId = Integer.parseInt(assigneeIdStr);
                
                // Assign as PRIMARY (first assignee) or SECONDARY (others)
                TaskAssignment.AssignmentType type = (assigneeId == Integer.parseInt(assigneeIds[0])) 
                    ? TaskAssignment.AssignmentType.PRIMARY 
                    : TaskAssignment.AssignmentType.SECONDARY;
                
                if (taskDAO.assignEmployee(taskId, assigneeId, type, 1)) {
                    // Log assignment (use admin user ID = 1)
                    activityLogDAO.logAssignment(taskId, 1, assigneeId, "Employee");
                    
                    // Create notification
                    notificationDAO.createTaskAssignmentNotification(taskId, assigneeId, 1);
                }
                
            } catch (NumberFormatException e) {
                // Skip invalid assignee ID
                continue;
            }
        }
    }
    
    /**
     * Handle initial task dependencies
     */
    private void handleInitialDependencies(int taskId, String[] dependencyIds) {
        for (String dependencyIdStr : dependencyIds) {
            try {
                int dependencyId = Integer.parseInt(dependencyIdStr);
                
                if (taskDAO.addDependency(taskId, dependencyId, 1)) {
                    // Log dependency addition (use admin user ID = 1)
                    activityLogDAO.logActivity(new TaskActivityLog(
                        taskId, 
                        1, 
                        TaskActivityLog.ActionType.DEPENDENCY_ADDED, 
                        "Added initial task dependency"
                    ));
                }
                
            } catch (NumberFormatException e) {
                // Skip invalid dependency ID
                continue;
            }
        }
    }
    
    /**
     * Load reference data for the form
     */
    private void loadReferenceData(HttpServletRequest request) {
        // Load all departments
        List<Department> departments = departmentDAO.getAll();
        request.setAttribute("departments", departments);
        
        // Load all employees for assignment
        List<Employee> employees = employeeDAO.getAll(null, null, true);
        request.setAttribute("employees", employees);
        
        // Load existing tasks for dependencies
        java.util.Map<String, Object> filters = new java.util.HashMap<>();
        List<Task> existingTasks = taskDAO.getTasks(filters, 0, 50);
        request.setAttribute("existingTasks", existingTasks);
        
        // Task priorities
        request.setAttribute("taskPriorities", Task.Priority.values());
    }

}