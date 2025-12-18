<%@page import="com.taskmanagement.dao.TaskDAO"%>
<%@page import="com.taskmanagement.dao.CommentDAO"%>
<%@page import="com.taskmanagement.dao.WorkSessionDAO"%>
<%@page import="com.taskmanagement.dao.TaskActivityLogDAO"%>
<%@page import="com.taskmanagement.dao.EmployeeDAO"%>
<%@page import="com.taskmanagement.dao.DepartmentDAO"%>
<%@page import="com.taskmanagement.model.Task"%>
<%@page import="com.taskmanagement.model.Comment"%>
<%@page import="com.taskmanagement.model.WorkSession"%>
<%@page import="com.taskmanagement.model.TaskActivityLog"%>
<%@page import="com.taskmanagement.model.Employee"%>
<%@page import="com.taskmanagement.model.Department"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Details - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .activity-item {
            border-left: 3px solid #007bff;
            padding-left: 15px;
            margin-bottom: 15px;
        }
        .comment-item {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body class="bg-light">
    <%
        // Get task ID from parameter
        String taskIdParam = request.getParameter("id");
        if (taskIdParam == null || taskIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/tasks.jsp");
            return;
        }
        
        int taskId;
        try {
            taskId = Integer.parseInt(taskIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/tasks.jsp");
            return;
        }
        
        // Initialize DAOs
        TaskDAO taskDAO = new TaskDAO();
        CommentDAO commentDAO = new CommentDAO();
        WorkSessionDAO workSessionDAO = new WorkSessionDAO();
        TaskActivityLogDAO activityLogDAO = new TaskActivityLogDAO();
        EmployeeDAO employeeDAO = new EmployeeDAO();
        DepartmentDAO departmentDAO = new DepartmentDAO();
        
        // Get task details
        Task task = taskDAO.getById(taskId);
        if (task == null) {
            response.sendRedirect(request.getContextPath() + "/tasks.jsp");
            return;
        }
        
        // Get related data
        List<Comment> comments = commentDAO.getCommentsForTask(taskId);
        List<WorkSession> workSessions = workSessionDAO.getSessionsForTask(taskId);
        List<TaskActivityLog> activityLog = activityLogDAO.getActivityLogForTask(taskId);
        
        // Get department info
        Department department = null;
        try {
            department = departmentDAO.getById(task.getDepartmentId());
        } catch (Exception e) {
            // Handle error silently
        }
        
        // Get creator info
        Employee creator = null;
        try {
            creator = employeeDAO.getById(task.getCreatedBy());
        } catch (Exception e) {
            // Handle error silently
        }
        
        // Calculate total work time
        int totalWorkTime = 0;
        try {
            // Try the method first
            totalWorkTime = workSessionDAO.getTotalWorkTimeMinutes(taskId, null);
        } catch (Exception e) {
            // If method fails, calculate manually
            for (WorkSession workSession : workSessions) {
                if (workSession.getDurationMinutes() != null) {
                    totalWorkTime += workSession.getDurationMinutes();
                }
            }
        }
    %>

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="<%= request.getContextPath() %>/">
                <i class="fas fa-tasks me-2"></i>Task Management System
            </a>
            <div class="navbar-nav me-auto">
                <a class="nav-link" href="<%= request.getContextPath() %>/dashboard">
                    <i class="fas fa-tachometer-alt me-1"></i>Dashboard
                </a>
                <a class="nav-link" href="<%= request.getContextPath() %>/tasks.jsp">
                    <i class="fas fa-tasks me-1"></i>Tasks
                </a>
            </div>
            <div class="navbar-nav">
                <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/task-edit.jsp?id=<%= task.getId() %>">
                    <i class="fas fa-edit me-1"></i>Edit Task
                </a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <div class="row">
            <div class="col-12">
                <div class="alert alert-success" role="alert">
                    <i class="fas fa-check-circle me-2"></i>
                    <strong>JSP Direct Access:</strong> This page directly imports and uses Java DAO classes.
                    Task loaded successfully with <%= comments.size() %> comments and <%= workSessions.size() %> work sessions.
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Task Details -->
            <div class="col-md-8">
                <div class="card mb-4">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4 class="mb-0"><%= task.getTitle() %></h4>
                        <%
                            String priorityClass = "success";
                            if (task.getPriority() == Task.Priority.HIGH) {
                                priorityClass = "danger";
                            } else if (task.getPriority() == Task.Priority.MEDIUM) {
                                priorityClass = "warning";
                            }
                        %>
                        <span class="badge bg-<%= priorityClass %> fs-6">
                            <%= task.getPriority() %>
                        </span>
                    </div>
                    <div class="card-body">
                        <p class="card-text"><%= task.getDescription() %></p>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <%
                                    String statusClass = "primary";
                                    if (task.getStatus() == Task.Status.COMPLETED) {
                                        statusClass = "success";
                                    } else if (task.getStatus() == Task.Status.IN_PROGRESS) {
                                        statusClass = "warning";
                                    } else if (task.getStatus() == Task.Status.CANCELLED) {
                                        statusClass = "danger";
                                    }
                                %>
                                <p><strong>Status:</strong> 
                                    <span class="badge bg-<%= statusClass %>">
                                        <%= task.getStatus().toString().replace("_", " ") %>
                                    </span>
                                </p>
                                <p><strong>Due Date:</strong> <%= task.getDueDate() %></p>
                                <p><strong>Created:</strong> <%= task.getCreatedAt() %></p>
                            </div>
                            <div class="col-md-6">
                                <p><strong>Department:</strong> <%= department != null ? department.getName() : "Unknown" %></p>
                                <p><strong>Created By:</strong> <%= creator != null ? creator.getName() : "Unknown" %></p>
                                <p><strong>Total Work Time:</strong> <%= totalWorkTime %> minutes</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Comments Section -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="fas fa-comments me-2"></i>Comments (<%= comments.size() %>)
                        </h5>
                    </div>
                    <div class="card-body">
                        <% if (comments.isEmpty()) { %>
                            <p class="text-muted">No comments yet.</p>
                        <% } else { %>
                            <% for (Comment comment : comments) { %>
                                <div class="comment-item">
                                    <div class="d-flex justify-content-between">
                                        <strong>
                                            <% 
                                                Employee commenter = null;
                                                String commenterName = "Unknown User";
                                                try {
                                                    commenter = employeeDAO.getById(comment.getEmployeeId());
                                                    if (commenter != null) {
                                                        commenterName = commenter.getName();
                                                    }
                                                } catch (Exception e) {
                                                    // Handle error silently
                                                }
                                            %>
                                            <%= commenterName %>
                                        </strong>
                                        <small class="text-muted"><%= comment.getCreatedAt() %></small>
                                    </div>
                                    <p class="mt-2 mb-0"><%= comment.getCommentText() %></p>
                                </div>
                            <% } %>
                        <% } %>
                        
                        <!-- Add Comment Form -->
                        <form action="<%= request.getContextPath() %>/tasks/<%= task.getId() %>" method="post" class="mt-3">
                            <input type="hidden" name="action" value="addComment">
                            <input type="hidden" name="taskId" value="<%= task.getId() %>">
                            <div class="mb-3">
                                <label class="form-label">Add Comment</label>
                                <textarea class="form-control" name="commentText" rows="3" placeholder="Enter your comment..." required></textarea>
                            </div>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-comment me-1"></i>Add Comment
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Sidebar -->
            <div class="col-md-4">
                <!-- Work Sessions -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="fas fa-clock me-2"></i>Work Sessions (<%= workSessions.size() %>)
                        </h5>
                    </div>
                    <div class="card-body">
                        <% if (workSessions.isEmpty()) { %>
                            <p class="text-muted">No work sessions recorded.</p>
                        <% } else { %>
                            <% for (WorkSession workSessionItem : workSessions) { %>
                                <div class="mb-3 p-2 border rounded">
                                    <div class="d-flex justify-content-between">
                                        <strong>
                                            <% 
                                                Employee worker = null;
                                                String workerName = "Unknown User";
                                                try {
                                                    worker = employeeDAO.getById(workSessionItem.getEmployeeId());
                                                    if (worker != null) {
                                                        workerName = worker.getName();
                                                    }
                                                } catch (Exception e) {
                                                    // Handle error silently
                                                }
                                            %>
                                            <%= workerName %>
                                        </strong>
                                        <small class="text-muted">
                                            <%= workSessionItem.getDurationMinutes() != null ? workSessionItem.getDurationMinutes() + " min" : "Active" %>
                                        </small>
                                    </div>
                                    <small class="text-muted">
                                        Started: <%= workSessionItem.getStartTime() %>
                                        <% if (workSessionItem.getEndTime() != null) { %>
                                            <br>Ended: <%= workSessionItem.getEndTime() %>
                                        <% } %>
                                    </small>
                                    <% if (workSessionItem.getNotes() != null && !workSessionItem.getNotes().isEmpty()) { %>
                                        <p class="mt-1 mb-0 small"><%= workSessionItem.getNotes() %></p>
                                    <% } %>
                                </div>
                            <% } %>
                        <% } %>
                    </div>
                </div>

                <!-- Activity Log -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="fas fa-history me-2"></i>Activity Log (<%= activityLog.size() %>)
                        </h5>
                    </div>
                    <div class="card-body">
                        <% if (activityLog.isEmpty()) { %>
                            <p class="text-muted">No activity recorded.</p>
                        <% } else { %>
                            <% for (TaskActivityLog activity : activityLog) { %>
                                <div class="activity-item">
                                    <div class="d-flex justify-content-between">
                                        <strong><%= activity.getAction().getDisplayName() %></strong>
                                        <small class="text-muted"><%= activity.getCreatedAt() %></small>
                                    </div>
                                    <p class="mb-0 small"><%= activity.getDescription() %></p>
                                    <% 
                                        Employee activityUser = null;
                                        String activityUserName = "System";
                                        try {
                                            activityUser = employeeDAO.getById(activity.getEmployeeId());
                                            if (activityUser != null) {
                                                activityUserName = activityUser.getName();
                                            }
                                        } catch (Exception e) {
                                            // Handle error silently
                                        }
                                    %>
                                    <small class="text-muted">by <%= activityUserName %></small>
                                </div>
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>