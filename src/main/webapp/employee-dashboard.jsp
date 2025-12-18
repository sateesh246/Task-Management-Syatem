<%@page import="com.taskmanagement.dao.TaskDAO"%>
<%@page import="com.taskmanagement.dao.EmployeeDAO"%>
<%@page import="com.taskmanagement.dao.DepartmentDAO"%>
<%@page import="com.taskmanagement.dao.WorkSessionDAO"%>
<%@page import="com.taskmanagement.dao.TaskActivityLogDAO"%>
<%@page import="com.taskmanagement.model.Employee"%>
<%@page import="com.taskmanagement.model.Task"%>
<%@page import="com.taskmanagement.model.Department"%>
<%@page import="com.taskmanagement.model.WorkSession"%>
<%@page import="com.taskmanagement.model.TaskActivityLog"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Check if user is logged in and is employee
    Employee loggedInUser = (Employee) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    
    if (loggedInUser.getRole() != Employee.Role.EMPLOYEE) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Dashboard - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .dashboard-card {
            transition: transform 0.2s;
            border: none;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
        }
        .employee-stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
        }
        .task-card {
            border-left: 4px solid #007bff;
            transition: all 0.3s ease;
        }
        .task-card:hover {
            border-left-color: #28a745;
            background-color: #f8f9fa;
        }
        .priority-high { border-left-color: #dc3545 !important; }
        .priority-medium { border-left-color: #ffc107 !important; }
        .priority-low { border-left-color: #28a745 !important; }
        .progress-circle {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            font-weight: bold;
        }
    </style>
</head>
<body class="bg-light">
    <%
        // Initialize DAOs
        TaskDAO taskDAO = new TaskDAO();
        EmployeeDAO employeeDAO = new EmployeeDAO();
        DepartmentDAO departmentDAO = new DepartmentDAO();
        WorkSessionDAO workSessionDAO = new WorkSessionDAO();
        TaskActivityLogDAO activityLogDAO = new TaskActivityLogDAO();
        
        // Get employee's department
        Department empDept = null;
        try {
            empDept = departmentDAO.getById(loggedInUser.getDepartmentId());
        } catch (Exception e) {
            // Handle error
        }
        
        // Get data for employee dashboard (employee-specific)
        List<Task> myTasks = taskDAO.getTasksAssignedToEmployee(loggedInUser.getId(), 0, 50);
        List<WorkSession> myWorkSessions = workSessionDAO.getSessionsForEmployee(loggedInUser.getId(), 10);
        List<TaskActivityLog> myActivity = activityLogDAO.getActivityLogForEmployee(loggedInUser.getId(), 10);
        
        // Calculate employee statistics
        int totalMyTasks = myTasks.size();
        int completedMyTasks = 0;
        int inProgressMyTasks = 0;
        int pendingMyTasks = 0;
        int overdueMyTasks = 0;
        
        java.time.LocalDate today = java.time.LocalDate.now();
        
        for (Task task : myTasks) {
            switch (task.getStatus()) {
                case COMPLETED:
                    completedMyTasks++;
                    break;
                case IN_PROGRESS:
                    inProgressMyTasks++;
                    break;
                case PENDING:
                    pendingMyTasks++;
                    break;
            }
            
            // Check if overdue
            if (task.getDueDate() != null && task.getDueDate().isBefore(today) && 
                task.getStatus() != Task.Status.COMPLETED && task.getStatus() != Task.Status.CANCELLED) {
                overdueMyTasks++;
            }
        }
        
        // Calculate personal completion rate
        double myCompletionRate = totalMyTasks > 0 ? (double) completedMyTasks / totalMyTasks * 100 : 0;
        
        // Get urgent tasks (high priority or due soon)
        List<Task> urgentTasks = new java.util.ArrayList<>();
        for (Task task : myTasks) {
            if (task.getPriority() == Task.Priority.HIGH || 
                (task.getDueDate() != null && task.getDueDate().isBefore(today.plusDays(3)) && 
                 task.getStatus() != Task.Status.COMPLETED)) {
                urgentTasks.add(task);
            }
        }
        
        // Calculate total work time
        int totalWorkMinutes = 0;
        try {
            totalWorkMinutes = workSessionDAO.getTotalWorkTimeMinutes(0, loggedInUser.getId());
        } catch (Exception e) {
            // Calculate manually if method fails
            for (WorkSession workSession : myWorkSessions) {
                if (workSession.getDurationMinutes() != null) {
                    totalWorkMinutes += workSession.getDurationMinutes();
                }
            }
        }
        
        int totalWorkHours = totalWorkMinutes / 60;
    %>

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-success">
        <div class="container-fluid">
            <a class="navbar-brand" href="<%= request.getContextPath() %>/">
                <i class="fas fa-tasks me-2"></i>Task Management System
            </a>
            <div class="navbar-nav me-auto">
                <a class="nav-link active" href="<%= request.getContextPath() %>/employee-dashboard.jsp">
                    <i class="fas fa-tachometer-alt me-1"></i>My Dashboard
                </a>
                <a class="nav-link" href="<%= request.getContextPath() %>/tasks.jsp">
                    <i class="fas fa-tasks me-1"></i>My Tasks
                </a>
                <a class="nav-link" href="<%= request.getContextPath() %>/task-create.jsp">
                    <i class="fas fa-plus me-1"></i>Request Task
                </a>
                <a class="nav-link" href="<%= request.getContextPath() %>/profile.jsp?userId=<%= loggedInUser.getId() %>">
                    <i class="fas fa-user me-1"></i>My Profile
                </a>
            </div>
            <div class="navbar-nav">
                <span class="navbar-text me-3">
                    <i class="fas fa-user me-1"></i>Welcome, <%= loggedInUser.getName() %> (Employee)
                </span>
                <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/index.html">
                    <i class="fas fa-sign-out-alt me-1"></i>Logout
                </a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <!-- Welcome Alert -->
        <div class="row">
            <div class="col-12">
                <div class="alert alert-success" role="alert">
                    <i class="fas fa-user me-2"></i>
                    <strong>Employee Dashboard:</strong> Welcome <%= loggedInUser.getName() %>! 
                    You're part of the <strong><%= empDept != null ? empDept.getName() : "Unknown" %></strong> department.
                    You have <%= totalMyTasks %> tasks assigned to you.
                </div>
            </div>
        </div>

        <!-- Personal Statistics -->
        <div class="row mb-4">
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card employee-stat-card">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-uppercase mb-1">My Tasks</div>
                                <div class="h5 mb-0 font-weight-bold"><%= totalMyTasks %></div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-tasks fa-2x"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card employee-stat-card" style="background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-uppercase mb-1">Completed</div>
                                <div class="h5 mb-0 font-weight-bold"><%= completedMyTasks %></div>
                                <div class="small">(<%= Math.round(myCompletionRate) %>% rate)</div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-check-circle fa-2x"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card employee-stat-card" style="background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%); color: #333;">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-uppercase mb-1">Work Hours</div>
                                <div class="h5 mb-0 font-weight-bold"><%= totalWorkHours %>h</div>
                                <div class="small">(<%= totalWorkMinutes %> minutes)</div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-clock fa-2x"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card employee-stat-card" style="background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%); color: #333;">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-uppercase mb-1">Urgent Tasks</div>
                                <div class="h5 mb-0 font-weight-bold"><%= urgentTasks.size() %></div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-exclamation-triangle fa-2x"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Urgent Tasks Alert -->
        <% if (!urgentTasks.isEmpty()) { %>
        <div class="row mb-4">
            <div class="col-12">
                <div class="card dashboard-card border-danger">
                    <div class="card-header bg-danger text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-exclamation-triangle me-2"></i>Urgent Tasks Requiring Attention (<%= urgentTasks.size() %>)
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <% for (Task task : urgentTasks) { %>
                                <div class="col-md-6 col-lg-4 mb-3">
                                    <div class="card border-danger">
                                        <div class="card-body">
                                            <h6 class="card-title text-danger"><%= task.getTitle() %></h6>
                                            <p class="card-text small">
                                                <%= task.getDescription().length() > 60 ? 
                                                    task.getDescription().substring(0, 60) + "..." : 
                                                    task.getDescription() %>
                                            </p>
                                            <div class="d-flex justify-content-between align-items-center">
                                                <div>
                                                    <span class="badge bg-<%= task.getPriority() == Task.Priority.HIGH ? "danger" : "warning" %>">
                                                        <%= task.getPriority() %>
                                                    </span>
                                                    <br><small class="text-muted">Due: <%= task.getDueDate() %></small>
                                                </div>
                                                <a href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= task.getId() %>" class="btn btn-sm btn-danger">
                                                    Work On It
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <% } %>

        <!-- Main Content Row -->
        <div class="row">
            <!-- Personal Progress -->
            <div class="col-xl-4 col-lg-6 mb-4">
                <div class="card dashboard-card">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-chart-pie me-2"></i>My Progress
                        </h5>
                    </div>
                    <div class="card-body text-center">
                        <div class="progress-circle bg-light mx-auto mb-3">
                            <%= Math.round(myCompletionRate) %>%
                        </div>
                        <h6>Task Completion Rate</h6>
                        <p class="text-muted"><%= completedMyTasks %> of <%= totalMyTasks %> tasks completed</p>
                        
                        <hr>
                        
                        <div class="row text-center">
                            <div class="col-4">
                                <h6 class="text-success"><%= completedMyTasks %></h6>
                                <small class="text-muted">Completed</small>
                            </div>
                            <div class="col-4">
                                <h6 class="text-warning"><%= inProgressMyTasks %></h6>
                                <small class="text-muted">In Progress</small>
                            </div>
                            <div class="col-4">
                                <h6 class="text-info"><%= pendingMyTasks %></h6>
                                <small class="text-muted">Pending</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Recent Work Sessions -->
            <div class="col-xl-4 col-lg-6 mb-4">
                <div class="card dashboard-card">
                    <div class="card-header bg-warning text-dark">
                        <h5 class="mb-0">
                            <i class="fas fa-clock me-2"></i>Recent Work Sessions
                        </h5>
                    </div>
                    <div class="card-body" style="max-height: 350px; overflow-y: auto;">
                        <% if (myWorkSessions.isEmpty()) { %>
                            <p class="text-muted">No work sessions recorded yet.</p>
                            <small class="text-muted">Start working on tasks to track your time!</small>
                        <% } else { %>
                            <% for (WorkSession workSession : myWorkSessions) { %>
                                <div class="border-start border-warning border-3 ps-3 mb-3">
                                    <div class="d-flex justify-content-between">
                                        <strong class="small">Task ID: <%= workSession.getTaskId() %></strong>
                                        <small class="text-muted">
                                            <%= workSession.getDurationMinutes() != null ? workSession.getDurationMinutes() + " min" : "Active" %>
                                        </small>
                                    </div>
                                    <p class="mb-1 small">Started: <%= workSession.getStartTime() %></p>
                                    <% if (workSession.getEndTime() != null) { %>
                                        <p class="mb-1 small">Ended: <%= workSession.getEndTime() %></p>
                                    <% } %>
                                    <% if (workSession.getNotes() != null && !workSession.getNotes().isEmpty()) { %>
                                        <p class="mb-0 small text-muted"><%= workSession.getNotes() %></p>
                                    <% } %>
                                </div>
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <!-- My Recent Activity -->
            <div class="col-xl-4 col-lg-12 mb-4">
                <div class="card dashboard-card">
                    <div class="card-header bg-info text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-history me-2"></i>My Recent Activity
                        </h5>
                    </div>
                    <div class="card-body" style="max-height: 350px; overflow-y: auto;">
                        <% if (myActivity.isEmpty()) { %>
                            <p class="text-muted">No recent activity recorded.</p>
                        <% } else { %>
                            <% for (TaskActivityLog activity : myActivity) { %>
                                <div class="border-start border-info border-3 ps-3 mb-3">
                                    <div class="d-flex justify-content-between">
                                        <strong class="small"><%= activity.getAction().toString().replace("_", " ") %></strong>
                                        <small class="text-muted"><%= activity.getCreatedAt() %></small>
                                    </div>
                                    <p class="mb-0 small"><%= activity.getDescription() %></p>
                                </div>
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- My Tasks -->
        <div class="row">
            <div class="col-12">
                <div class="card dashboard-card">
                    <div class="card-header bg-secondary text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-tasks me-2"></i>My Tasks (<%= totalMyTasks %>)
                        </h5>
                    </div>
                    <div class="card-body">
                        <% if (myTasks.isEmpty()) { %>
                            <div class="text-center py-5">
                                <i class="fas fa-tasks fa-3x text-muted mb-3"></i>
                                <h5 class="text-muted">No tasks assigned yet</h5>
                                <p class="text-muted">Check back later or contact your manager for task assignments.</p>
                            </div>
                        <% } else { %>
                            <div class="row">
                                <% 
                                int displayCount = 0;
                                for (Task task : myTasks) { 
                                    if (displayCount >= 9) break;
                                    displayCount++;
                                %>
                                    <div class="col-md-6 col-lg-4 mb-3">
                                        <div class="card task-card priority-<%= task.getPriority().name().toLowerCase() %>">
                                            <div class="card-body">
                                                <h6 class="card-title"><%= task.getTitle() %></h6>
                                                <p class="card-text small text-muted">
                                                    <%= task.getDescription().length() > 80 ? 
                                                        task.getDescription().substring(0, 80) + "..." : 
                                                        task.getDescription() %>
                                                </p>
                                                <div class="d-flex justify-content-between align-items-center mb-2">
                                                    <div>
                                                        <%
                                                            String taskStatusClass = "primary";
                                                            if (task.getStatus() == Task.Status.COMPLETED) {
                                                                taskStatusClass = "success";
                                                            } else if (task.getStatus() == Task.Status.IN_PROGRESS) {
                                                                taskStatusClass = "warning";
                                                            } else if (task.getStatus() == Task.Status.CANCELLED) {
                                                                taskStatusClass = "danger";
                                                            }
                                                        %>
                                                        <span class="badge bg-<%= taskStatusClass %> small">
                                                            <%= task.getStatus().toString().replace("_", " ") %>
                                                        </span>
                                                    </div>
                                                    <div>
                                                        <%
                                                            String taskPriorityClass = "success";
                                                            if (task.getPriority() == Task.Priority.HIGH) {
                                                                taskPriorityClass = "danger";
                                                            } else if (task.getPriority() == Task.Priority.MEDIUM) {
                                                                taskPriorityClass = "warning";
                                                            }
                                                        %>
                                                        <span class="badge bg-<%= taskPriorityClass %> small">
                                                            <%= task.getPriority() %>
                                                        </span>
                                                    </div>
                                                </div>
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <small class="text-muted">Due: <%= task.getDueDate() %></small>
                                                    <a href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= task.getId() %>" class="btn btn-sm btn-outline-primary">
                                                        <i class="fas fa-arrow-right"></i>
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                            
                            <% if (myTasks.size() > 9) { %>
                                <div class="text-center mt-3">
                                    <a href="<%= request.getContextPath() %>/tasks.jsp" class="btn btn-primary">
                                        View All My Tasks (<%= myTasks.size() %>)
                                    </a>
                                </div>
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Employee Actions -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="card dashboard-card">
                    <div class="card-header bg-dark text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-tools me-2"></i>Quick Actions
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/tasks.jsp" class="btn btn-primary">
                                        <i class="fas fa-tasks me-2"></i>View All My Tasks
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/task-create.jsp" class="btn btn-success">
                                        <i class="fas fa-plus me-2"></i>Request New Task
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/profile.jsp" class="btn btn-info">
                                        <i class="fas fa-user me-2"></i>My Profile
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/dashboard.jsp" class="btn btn-warning">
                                        <i class="fas fa-tachometer-alt me-2"></i>General Dashboard
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>