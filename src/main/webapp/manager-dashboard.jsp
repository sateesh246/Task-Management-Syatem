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
    // Check if user is logged in and is manager
    Employee loggedInUser = (Employee) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    
    if (loggedInUser.getRole() != Employee.Role.MANAGER) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manager Dashboard - Task Management System</title>
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
        .manager-stat-card {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            border-radius: 15px;
        }
        .team-member-card {
            border-left: 4px solid #007bff;
            transition: all 0.3s ease;
        }
        .team-member-card:hover {
            border-left-color: #28a745;
            background-color: #f8f9fa;
        }
        .task-priority-high { border-left: 4px solid #dc3545; }
        .task-priority-medium { border-left: 4px solid #ffc107; }
        .task-priority-low { border-left: 4px solid #28a745; }
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
        
        // Get manager's department
        Department managerDept = null;
        try {
            managerDept = departmentDAO.getById(loggedInUser.getDepartmentId());
        } catch (Exception e) {
            // Handle error
        }
        
        // Get data for manager dashboard (department-specific)
        Map<String, Object> filters = new HashMap<>();
        filters.put("departmentId", loggedInUser.getDepartmentId());
        
        List<Task> departmentTasks = taskDAO.getTasks(filters, 0, 50);
                                                                       List<Task> myTasks = taskDAO.getTasksAssignedToEmployee(loggedInUser.getId(), 0, 20);
        List<Employee> teamMembers = employeeDAO.getEmployeesByDepartment(loggedInUser.getDepartmentId());
        Map<String, Integer> deptTaskCounts = taskDAO.getTaskCountByStatus(loggedInUser.getDepartmentId(), null);
        List<TaskActivityLog> deptActivity = activityLogDAO.getActivityLogForDepartment(loggedInUser.getDepartmentId(), 10);
        
        // Calculate department statistics
        int totalDeptTasks = departmentTasks.size();
        int completedDeptTasks = deptTaskCounts.getOrDefault("COMPLETED", 0);
        int inProgressDeptTasks = deptTaskCounts.getOrDefault("IN_PROGRESS", 0);
        int pendingDeptTasks = deptTaskCounts.getOrDefault("PENDING", 0);
        
        // Calculate team productivity
        double deptCompletionRate = totalDeptTasks > 0 ? (double) completedDeptTasks / totalDeptTasks * 100 : 0;
        
        // Count overdue tasks in department
        java.time.LocalDate today = java.time.LocalDate.now();
        int overdueDeptTasks = 0;
        for (Task task : departmentTasks) {
            if (task.getDueDate() != null && task.getDueDate().isBefore(today) && 
                task.getStatus() != Task.Status.COMPLETED && task.getStatus() != Task.Status.CANCELLED) {
                overdueDeptTasks++;
            }
        }
        
        // Get tasks requiring manager approval
        List<Task> tasksForReview = new java.util.ArrayList<>();
        for (Task task : departmentTasks) {
            if (task.getStatus() == Task.Status.UNDER_REVIEW) {
                tasksForReview.add(task);
            }
        }
    %>

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-warning">
        <div class="container-fluid">
            <a class="navbar-brand text-dark" href="<%= request.getContextPath() %>/">
                <i class="fas fa-tasks me-2"></i>Task Management System
            </a>
            <div class="navbar-nav me-auto">
                <a class="nav-link active text-dark" href="<%= request.getContextPath() %>/manager-dashboard.jsp">
                    <i class="fas fa-tachometer-alt me-1"></i>Manager Dashboard
                </a>
                <a class="nav-link text-dark" href="<%= request.getContextPath() %>/tasks.jsp">
                    <i class="fas fa-tasks me-1"></i>Department Tasks
                </a>
                <a class="nav-link text-dark" href="<%= request.getContextPath() %>/task-create.jsp">
                    <i class="fas fa-plus me-1"></i>Create Task
                </a>
                <a class="nav-link text-dark" href="<%= request.getContextPath() %>/profile.jsp?userId=<%= loggedInUser.getId() %>">
                    <i class="fas fa-user me-1"></i>My Profile
                </a>
            </div>
            <div class="navbar-nav">
                <span class="navbar-text me-3 text-dark">
                    <i class="fas fa-user-tie me-1"></i>Welcome, <%= loggedInUser.getName() %> (Manager)
                </span>
                <a class="btn btn-outline-dark" href="<%= request.getContextPath() %>/index.html">
                    <i class="fas fa-sign-out-alt me-1"></i>Logout
                </a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <!-- Welcome Alert -->
        <div class="row">
            <div class="col-12">
                <div class="alert alert-warning" role="alert">
                    <i class="fas fa-user-tie me-2"></i>
                    <strong>Manager Dashboard:</strong> Welcome <%= loggedInUser.getName() %>! 
                    You're managing the <strong><%= managerDept != null ? managerDept.getName() : "Unknown" %></strong> department 
                    with <%= teamMembers.size() %> team members.
                </div>
            </div>
        </div>

        <!-- Department Statistics -->
        <div class="row mb-4">
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card manager-stat-card">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-uppercase mb-1">Department Tasks</div>
                                <div class="h5 mb-0 font-weight-bold"><%= totalDeptTasks %></div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-tasks fa-2x"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card manager-stat-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-uppercase mb-1">Team Members</div>
                                <div class="h5 mb-0 font-weight-bold"><%= teamMembers.size() %></div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-users fa-2x"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card manager-stat-card" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-uppercase mb-1">Completion Rate</div>
                                <div class="h5 mb-0 font-weight-bold"><%= Math.round(deptCompletionRate) %>%</div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-chart-line fa-2x"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card manager-stat-card" style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-uppercase mb-1">Pending Review</div>
                                <div class="h5 mb-0 font-weight-bold"><%= tasksForReview.size() %></div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-clipboard-check fa-2x"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tasks Requiring Review -->
        <% if (!tasksForReview.isEmpty()) { %>
        <div class="row mb-4">
            <div class="col-12">
                <div class="card dashboard-card border-warning">
                    <div class="card-header bg-warning text-dark">
                        <h5 class="mb-0">
                            <i class="fas fa-exclamation-triangle me-2"></i>Tasks Requiring Your Review (<%= tasksForReview.size() %>)
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <% for (Task task : tasksForReview) { %>
                                <div class="col-md-6 col-lg-4 mb-3">
                                    <div class="card border-warning">
                                        <div class="card-body">
                                            <h6 class="card-title"><%= task.getTitle() %></h6>
                                            <p class="card-text small text-muted">
                                                <%= task.getDescription().length() > 80 ? 
                                                    task.getDescription().substring(0, 80) + "..." : 
                                                    task.getDescription() %>
                                            </p>
                                            <div class="d-flex justify-content-between align-items-center">
                                                <small class="text-muted">Due: <%= task.getDueDate() %></small>
                                                <a href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= task.getId() %>" class="btn btn-sm btn-warning">
                                                    Review
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
            <!-- Team Members -->
            <div class="col-xl-4 col-lg-6 mb-4">
                <div class="card dashboard-card">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-users me-2"></i>My Team (<%= teamMembers.size() %>)
                        </h5>
                    </div>
                    <div class="card-body" style="max-height: 400px; overflow-y: auto;">
                        <% if (teamMembers.isEmpty()) { %>
                            <p class="text-muted">No team members found.</p>
                        <% } else { %>
                            <% for (Employee member : teamMembers) { %>
                                <div class="team-member-card card mb-2">
                                    <div class="card-body py-2">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div>
                                                <strong><%= member.getName() %></strong>
                                                <br><small class="text-muted"><%= member.getEmail() %></small>
                                            </div>
                                            <div class="text-end">
                                                <span class="badge bg-<%= member.getRole() == Employee.Role.MANAGER ? "warning" : "success" %>">
                                                    <%= member.getRole() %>
                                                </span>
                                                <br><small class="text-muted">ID: <%= member.getId() %></small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <!-- Department Task Status -->
            <div class="col-xl-4 col-lg-6 mb-4">
                <div class="card dashboard-card">
                    <div class="card-header bg-success text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-chart-pie me-2"></i>Department Task Status
                        </h5>
                    </div>
                    <div class="card-body">
                        <% for (Map.Entry<String, Integer> entry : deptTaskCounts.entrySet()) { %>
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div>
                                    <strong><%= entry.getKey().replace("_", " ") %></strong>
                                    <br><small class="text-muted"><%= entry.getValue() %> tasks</small>
                                </div>
                                <div class="text-end">
                                    <span class="badge bg-primary"><%= entry.getValue() %></span>
                                    <div class="progress mt-1" style="width: 100px; height: 8px;">
                                        <%
                                            int deptProgressWidth = totalDeptTasks > 0 ? (entry.getValue() * 100 / totalDeptTasks) : 0;
                                        %>
                                        <div class="progress-bar bg-success" style="width: <%= deptProgressWidth %>%"></div>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                        
                        <hr>
                        <div class="text-center">
                            <h6 class="text-primary">Overall Progress</h6>
                            <div class="progress mb-2">
                                <div class="progress-bar bg-success" style="width: <%= Math.round(deptCompletionRate) %>%">
                                    <%= Math.round(deptCompletionRate) %>%
                                </div>
                            </div>
                            <small class="text-muted"><%= completedDeptTasks %> of <%= totalDeptTasks %> tasks completed</small>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Recent Department Activity -->
            <div class="col-xl-4 col-lg-12 mb-4">
                <div class="card dashboard-card">
                    <div class="card-header bg-info text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-history me-2"></i>Recent Department Activity
                        </h5>
                    </div>
                    <div class="card-body" style="max-height: 400px; overflow-y: auto;">
                        <% if (deptActivity.isEmpty()) { %>
                            <p class="text-muted">No recent activity in your department.</p>
                        <% } else { %>
                            <% for (TaskActivityLog activity : deptActivity) { %>
                                <div class="border-start border-primary border-3 ps-3 mb-3">
                                    <div class="d-flex justify-content-between">
                                        <strong class="small"><%= activity.getAction().toString().replace("_", " ") %></strong>
                                        <small class="text-muted"><%= activity.getCreatedAt() %></small>
                                    </div>
                                    <p class="mb-1 small"><%= activity.getDescription() %></p>
                                    <small class="text-muted">Employee ID: <%= activity.getEmployeeId() %></small>
                                </div>
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Department Tasks -->
        <div class="row">
            <div class="col-12">
                <div class="card dashboard-card">
                    <div class="card-header bg-secondary text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-tasks me-2"></i>Recent Department Tasks
                        </h5>
                    </div>
                    <div class="card-body">
                        <% if (departmentTasks.isEmpty()) { %>
                            <p class="text-muted">No tasks found for your department.</p>
                        <% } else { %>
                            <div class="row">
                                <% 
                                int displayCount = 0;
                                for (Task task : departmentTasks) { 
                                    if (displayCount >= 6) break;
                                    displayCount++;
                                %>
                                    <div class="col-md-6 col-lg-4 mb-3">
                                        <div class="card task-priority-<%= task.getPriority().name().toLowerCase() %>">
                                            <div class="card-body">
                                                <h6 class="card-title"><%= task.getTitle() %></h6>
                                                <p class="card-text small text-muted">
                                                    <%= task.getDescription().length() > 60 ? 
                                                        task.getDescription().substring(0, 60) + "..." : 
                                                        task.getDescription() %>
                                                </p>
                                                <div class="d-flex justify-content-between align-items-center">
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
                                                    <a href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= task.getId() %>" class="btn btn-sm btn-outline-primary">
                                                        View
                                                    </a>
                                                </div>
                                                <small class="text-muted">Due: <%= task.getDueDate() %></small>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                            
                            <% if (departmentTasks.size() > 6) { %>
                                <div class="text-center mt-3">
                                    <a href="<%= request.getContextPath() %>/tasks.jsp" class="btn btn-primary">
                                        View All Department Tasks (<%= departmentTasks.size() %>)
                                    </a>
                                </div>
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Manager Actions -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="card dashboard-card">
                    <div class="card-header bg-dark text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-tools me-2"></i>Manager Actions
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/task-create.jsp" class="btn btn-primary">
                                        <i class="fas fa-plus me-2"></i>Create Task
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/tasks.jsp" class="btn btn-success">
                                        <i class="fas fa-list me-2"></i>Manage Tasks
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/reports.jsp" class="btn btn-info">
                                        <i class="fas fa-chart-bar me-2"></i>Department Reports
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