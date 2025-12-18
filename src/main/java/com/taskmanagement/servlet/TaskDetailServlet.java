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
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet for displaying detailed task information
 * Shows task details, assignments, dependencies, comments, work sessions, and activity log
 */
@WebServlet("/tasks/*")
public class TaskDetailServlet extends HttpServlet {
    
    private TaskDAO taskDAO;
    private CommentDAO commentDAO;
    private WorkSessionDAO workSessionDAO;
    private TaskActivityLogDAO activityLogDAO;
    private NotificationDAO notificationDAO;
    
    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
        commentDAO = new CommentDAO();
        workSessionDAO = new WorkSessionDAO();
        activityLogDAO = new TaskActivityLogDAO();
        notificationDAO = new NotificationDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        
        try {
            // Parse task ID from URL
            if (pathInfo == null || pathInfo.length() <= 1) {
                response.sendRedirect(request.getContextPath() + "/tasks");
                return;
            }
            
            String taskIdStr = pathInfo.substring(1); // Remove leading slash
            int taskId;
            
            try {
                taskId = Integer.parseInt(taskIdStr);
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Invalid task ID");
                request.getRequestDispatcher("/error.jsp").forward(request, response);
                return;
            }
            
            // Get task details
            Task task = taskDAO.getById(taskId);
            
            if (task == null) {
                request.setAttribute("errorMessage", "Task not found");
                request.getRequestDispatcher("/error.jsp").forward(request, response);
                return;
            }
            
            // Load related data
            loadTaskRelatedData(request, task);
            
            // Set task as main attribute
            request.setAttribute("task", task);
            
            // Forward to task detail JSP
            request.getRequestDispatcher("/task-detail.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading task details: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "addComment":
                    handleAddComment(request, response);
                    break;
                case "startWorkSession":
                    handleStartWorkSession(request, response);
                    break;
                case "endWorkSession":
                    handleEndWorkSession(request, response);
                    break;
                case "updateStatus":
                    handleUpdateStatus(request, response);
                    break;
                case "assignEmployee":
                    handleAssignEmployee(request, response);
                    break;
                case "removeAssignment":
                    handleRemoveAssignment(request, response);
                    break;
                case "addDependency":
                    handleAddDependency(request, response);
                    break;
                case "removeDependency":
                    handleRemoveDependency(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error processing request: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle adding a comment to the task
     */
    private void handleAddComment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int taskId = Integer.parseInt(request.getParameter("taskId"));
        String commentText = request.getParameter("commentText");
        
        // Validate input
        if (!ValidationUtil.isValidComment(commentText)) {
            request.setAttribute("errorMessage", "Comment text is required and must be between 1-1000 characters");
            doGet(request, response);
            return;
        }
        
        // Sanitize input
        commentText = ValidationUtil.sanitizeInput(commentText);
        
        // Create comment (use admin user ID = 1)
        Comment comment = new Comment(taskId, 1, commentText);
        
        if (commentDAO.addComment(comment)) {
            // Log activity
            activityLogDAO.logActivity(new TaskActivityLog(
                taskId, 
                1, 
                TaskActivityLog.ActionType.COMMENT_ADDED, 
                "Added comment: " + (commentText.length() > 50 ? commentText.substring(0, 50) + "..." : commentText)
            ));
            
            request.setAttribute("successMessage", "Comment added successfully");
        } else {
            request.setAttribute("errorMessage", "Failed to add comment");
        }
        
        // Redirect to avoid resubmission
        response.sendRedirect(request.getContextPath() + "/tasks/" + taskId + "?success=comment_added");
    }
    
    /**
     * Handle starting a work session
     */
    private void handleStartWorkSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int taskId = Integer.parseInt(request.getParameter("taskId"));
        String notes = request.getParameter("notes");
        
        // Validate notes
        if (!ValidationUtil.isValidSessionNotes(notes)) {
            request.setAttribute("errorMessage", "Session notes must be 500 characters or less");
            doGet(request, response);
            return;
        }
        
        // Create work session (use admin user ID = 1)
        WorkSession session = new WorkSession(taskId, 1, 
                                            Timestamp.valueOf(LocalDateTime.now()), notes);
        
        if (workSessionDAO.startSession(session)) {
            // Log activity
            activityLogDAO.logActivity(new TaskActivityLog(
                taskId, 
                1, 
                TaskActivityLog.ActionType.WORK_SESSION_STARTED, 
                "Started work session"
            ));
            
            request.setAttribute("successMessage", "Work session started");
        } else {
            request.setAttribute("errorMessage", "Failed to start work session. You may already have an active session for this task.");
        }
        
        response.sendRedirect(request.getContextPath() + "/tasks/" + taskId + "?success=session_started");
    }
    
    /**
     * Handle ending a work session
     */
    private void handleEndWorkSession(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int taskId = Integer.parseInt(request.getParameter("taskId"));
        int sessionId = Integer.parseInt(request.getParameter("sessionId"));
        String notes = request.getParameter("notes");
        
        // Validate notes
        if (!ValidationUtil.isValidSessionNotes(notes)) {
            request.setAttribute("errorMessage", "Session notes must be 500 characters or less");
            doGet(request, response);
            return;
        }
        
        if (workSessionDAO.endSession(sessionId, notes)) {
            // Log activity (use admin user ID = 1)
            activityLogDAO.logActivity(new TaskActivityLog(
                taskId, 
                1, 
                TaskActivityLog.ActionType.WORK_SESSION_ENDED, 
                "Ended work session"
            ));
            
            request.setAttribute("successMessage", "Work session ended");
        } else {
            request.setAttribute("errorMessage", "Failed to end work session");
        }
        
        response.sendRedirect(request.getContextPath() + "/tasks/" + taskId + "?success=session_ended");
    }
    
    /**
     * Handle updating task status
     */
    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int taskId = Integer.parseInt(request.getParameter("taskId"));
        String newStatusStr = request.getParameter("newStatus");
        int version = Integer.parseInt(request.getParameter("version"));
        
        Task.Status newStatus;
        try {
            newStatus = Task.Status.valueOf(newStatusStr);
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", "Invalid status");
            doGet(request, response);
            return;
        }
        
        // Get current task
        Task task = taskDAO.getById(taskId);
        if (task == null) {
            request.setAttribute("errorMessage", "Task not found");
            doGet(request, response);
            return;
        }
        
        // Update status (no permission check - all users can update)
        String oldStatus = task.getStatus().name();
        if (taskDAO.updateStatus(taskId, newStatus, 1, version)) {
            // Log activity (use admin user ID = 1)
            activityLogDAO.logStatusChange(taskId, 1, oldStatus, newStatus.name());
            
            request.setAttribute("successMessage", "Task status updated successfully");
        } else {
            request.setAttribute("errorMessage", "Failed to update task status. The task may have been modified by another user.");
        }
        
        response.sendRedirect(request.getContextPath() + "/tasks/" + taskId + "?success=status_updated");
    }
    
    /**
     * Handle assigning employee to task
     */
    private void handleAssignEmployee(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int taskId = Integer.parseInt(request.getParameter("taskId"));
        int employeeId = Integer.parseInt(request.getParameter("employeeId"));
        String assignmentTypeStr = request.getParameter("assignmentType");
        
        TaskAssignment.AssignmentType assignmentType;
        try {
            assignmentType = TaskAssignment.AssignmentType.valueOf(assignmentTypeStr);
        } catch (IllegalArgumentException e) {
            assignmentType = TaskAssignment.AssignmentType.PRIMARY;
        }
        
        if (taskDAO.assignEmployee(taskId, employeeId, assignmentType, 1)) {
            // Log activity (use admin user ID = 1)
            activityLogDAO.logAssignment(taskId, 1, employeeId, "Employee");
            
            // Create notification for assigned employee
            notificationDAO.createTaskAssignmentNotification(taskId, employeeId, 1);
            
            request.setAttribute("successMessage", "Employee assigned successfully");
        } else {
            request.setAttribute("errorMessage", "Failed to assign employee");
        }
        
        response.sendRedirect(request.getContextPath() + "/tasks/" + taskId + "?success=employee_assigned");
    }
    
    /**
     * Handle removing employee assignment
     */
    private void handleRemoveAssignment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int taskId = Integer.parseInt(request.getParameter("taskId"));
        int employeeId = Integer.parseInt(request.getParameter("employeeId"));
        
        if (taskDAO.removeAssignment(taskId, employeeId)) {
            // Log activity (use admin user ID = 1)
            activityLogDAO.logActivity(new TaskActivityLog(
                taskId, 
                1, 
                TaskActivityLog.ActionType.UNASSIGNED, 
                "Removed employee assignment"
            ));
            
            request.setAttribute("successMessage", "Employee assignment removed");
        } else {
            request.setAttribute("errorMessage", "Failed to remove assignment");
        }
        
        response.sendRedirect(request.getContextPath() + "/tasks/" + taskId + "?success=assignment_removed");
    }
    
    /**
     * Handle adding task dependency
     */
    private void handleAddDependency(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int taskId = Integer.parseInt(request.getParameter("taskId"));
        int dependsOnTaskId = Integer.parseInt(request.getParameter("dependsOnTaskId"));
        
        if (taskDAO.addDependency(taskId, dependsOnTaskId, 1)) {
            // Log activity (use admin user ID = 1)
            activityLogDAO.logActivity(new TaskActivityLog(
                taskId, 
                1, 
                TaskActivityLog.ActionType.DEPENDENCY_ADDED, 
                "Added task dependency"
            ));
            
            request.setAttribute("successMessage", "Dependency added successfully");
        } else {
            request.setAttribute("errorMessage", "Failed to add dependency. This may create a circular dependency.");
        }
        
        response.sendRedirect(request.getContextPath() + "/tasks/" + taskId + "?success=dependency_added");
    }
    
    /**
     * Handle removing task dependency
     */
    private void handleRemoveDependency(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int taskId = Integer.parseInt(request.getParameter("taskId"));
        int dependsOnTaskId = Integer.parseInt(request.getParameter("dependsOnTaskId"));
        
        if (taskDAO.removeDependency(taskId, dependsOnTaskId)) {
            // Log activity (use admin user ID = 1)
            activityLogDAO.logActivity(new TaskActivityLog(
                taskId, 
                1, 
                TaskActivityLog.ActionType.DEPENDENCY_REMOVED, 
                "Removed task dependency"
            ));
            
            request.setAttribute("successMessage", "Dependency removed successfully");
        } else {
            request.setAttribute("errorMessage", "Failed to remove dependency");
        }
        
        response.sendRedirect(request.getContextPath() + "/tasks/" + taskId + "?success=dependency_removed");
    }
    
    /**
     * Load all related data for the task
     */
    private void loadTaskRelatedData(HttpServletRequest request, Task task) {
        // Load comments
        List<Comment> comments = commentDAO.getCommentsForTask(task.getId());
        request.setAttribute("comments", comments);
        
        // Load work sessions
        List<WorkSession> workSessions = workSessionDAO.getSessionsForTask(task.getId());
        request.setAttribute("workSessions", workSessions);
        
        // Load activity log
        List<TaskActivityLog> activityLog = activityLogDAO.getActivityLogForTask(task.getId());
        request.setAttribute("activityLog", activityLog);
        
        // No active session check needed (no authentication)
        request.setAttribute("activeSession", null);
        
        // Calculate total work time for all users
        int totalWorkTime = workSessionDAO.getTotalWorkTimeMinutes(task.getId(), null);
        request.setAttribute("totalWorkTime", totalWorkTime);
        
        // All users can access all features (no authentication)
        request.setAttribute("isAssigned", true);
        
        // All status transitions are valid (no authentication)
        request.setAttribute("validTransitions", Task.Status.values());
    }

}