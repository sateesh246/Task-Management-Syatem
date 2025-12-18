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
    // Check if user is logged in and is admin
    Employee loggedInUser = (Employee) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    
    if (loggedInUser.getRole() != Employee.Role.ADMIN) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.css" rel="stylesheet">
    <style>
        .dashboard-card {
            transition: transform 0.2s;
            border: none;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
        }
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
        }
        .activity-item {
            border-left: 4px solid #007bff;
            padding-left: 15px;
            margin-bottom: 15px;
        }
        .priority-high { border-left-color: #dc3545; }
        .priority-medium { border-left-color: #ffc107; }
        .priority-low { border-left-color: #28a745; }
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
        
        // Get comprehensive data for admin dashboard
        Map<String, Object> filters = new HashMap<>();
        List<Task> allTasks = taskDAO.getTasks(filters, 0, 100);
        List<Task> recentTasks = taskDAO.getTasks(filters, 0, 10);
        List<Employee> allEmployees = employeeDAO.getAll(null, null, true);
        List<Department> departments = departmentDAO.getAll();
        Map<String, Integer> taskCounts = taskDAO.getTaskCountByStatus(null, null);
        List<TaskActivityLog> recentActivity = activityLogDAO.getRecentSystemActivity(10);
        
        // Calculate statistics
        int totalTasks = allTasks.size();
        int completedTasks = taskCounts.getOrDefault("COMPLETED", 0);
        int inProgressTasks = taskCounts.getOrDefault("IN_PROGRESS", 0);
        int pendingTasks = taskCounts.getOrDefault("PENDING", 0);
        int overdueTasks = 0;
        
        // Count overdue tasks
        java.time.LocalDate today = java.time.LocalDate.now();
        for (Task task : allTasks) {
            if (task.getDueDate() != null && task.getDueDate().isBefore(today) && 
                task.getStatus() != Task.Status.COMPLETED && task.getStatus() != Task.Status.CANCELLED) {
                overdueTasks++;
            }
        }
        
        // Calculate completion rate
        double completionRate = totalTasks > 0 ? (double) completedTasks / totalTasks * 100 : 0;
        
        // Count employees by role
        long adminCount = allEmployees.stream().filter(e -> e.getRole() == Employee.Role.ADMIN).count();
        long managerCount = allEmployees.stream().filter(e -> e.getRole() == Employee.Role.MANAGER).count();
        long employeeCount = allEmployees.stream().filter(e -> e.getRole() == Employee.Role.EMPLOYEE).count();
    %>

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="<%= request.getContextPath() %>/">
                <i class="fas fa-tasks me-2"></i>Task Management System
            </a>
            <div class="navbar-nav me-auto">
                <a class="nav-link active" href="<%= request.getContextPath() %>/admin-dashboard.jsp">
                    <i class="fas fa-tachometer-alt me-1"></i>Admin Dashboard
                </a>
                <a class="nav-link" href="<%= request.getContextPath() %>/tasks.jsp">
                    <i class="fas fa-tasks me-1"></i>All Tasks
                </a>
                <a class="nav-link" href="<%= request.getContextPath() %>/task-create.jsp">
                    <i class="fas fa-plus me-1"></i>Create Task
                </a>
                <a class="nav-link" href="<%= request.getContextPath() %>/profile.jsp?userId=<%= loggedInUser.getId() %>">
                    <i class="fas fa-user me-1"></i>My Profile
                </a>
            </div>
            <div class="navbar-nav">
                <span class="navbar-text me-3">
                    <i class="fas fa-user-shield me-1"></i>Welcome, <%= loggedInUser.getName() %> (Admin)
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
                    <i class="fas fa-crown me-2"></i>
                    <strong>Admin Dashboard:</strong> Welcome <%= loggedInUser.getName() %>! You have full administrative access to manage the entire system.
                </div>
            </div>
        </div>

        <!-- Key Statistics Cards -->
        <div class="row mb-4">
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card stat-card">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-uppercase mb-1">Total Tasks</div>
                                <div class="h5 mb-0 font-weight-bold"><%= totalTasks %></div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-tasks fa-2x"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card stat-card" style="background: linear-gradient(135deg, #28a745 0%, #20c997 100%);">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-uppercase mb-1">Completed</div>
                                <div class="h5 mb-0 font-weight-bold"><%= completedTasks %></div>
                                <div class="small">(<%= Math.round(completionRate) %>% completion rate)</div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-check-circle fa-2x"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card stat-card" style="background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-uppercase mb-1">In Progress</div>
                                <div class="h5 mb-0 font-weight-bold"><%= inProgressTasks %></div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-spinner fa-2x"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-md-6 mb-4">
                <div class="card stat-card" style="background: linear-gradient(135deg, #dc3545 0%, #e83e8c 100%);">
                    <div class="card-body">
                        <div class="row no-gutters align-items-center">
                            <div class="col mr-2">
                                <div class="text-xs font-weight-bold text-uppercase mb-1">Overdue</div>
                                <div class="h5 mb-0 font-weight-bold"><%= overdueTasks %></div>
                            </div>
                            <div class="col-auto">
                                <i class="fas fa-exclamation-triangle fa-2x"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Team Overview -->
        <div class="row mb-4">
            <div class="col-xl-4 col-lg-6 mb-4">
                <div class="card dashboard-card">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-users me-2"></i>Team Overview
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row text-center">
                            <div class="col-4">
                                <div class="border-end">
                                    <h4 class="text-danger"><%= adminCount %></h4>
                                    <small class="text-muted">Admins</small>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="border-end">
                                    <h4 class="text-warning"><%= managerCount %></h4>
                                    <small class="text-muted">Managers</small>
                                </div>
                            </div>
                            <div class="col-4">
                                <h4 class="text-success"><%= employeeCount %></h4>
                                <small class="text-muted">Employees</small>
                            </div>
                        </div>
                        <hr>
                        <div class="text-center">
                            <h5 class="text-primary"><%= allEmployees.size() %></h5>
                            <small class="text-muted">Total Team Members</small>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-4 col-lg-6 mb-4">
                <div class="card dashboard-card">
                    <div class="card-header bg-success text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-building me-2"></i>Departments
                        </h5>
                    </div>
                    <div class="card-body">
                        <% if (departments.isEmpty()) { %>
                            <p class="text-muted">No departments found.</p>
                        <% } else { %>
                            <% for (Department dept : departments) { %>
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <div>
                                        <strong><%= dept.getName() %></strong>
                                        <br><small class="text-muted"><%= dept.getDescription() %></small>
                                    </div>
                                    <span class="badge bg-primary">ID: <%= dept.getId() %></span>
                                </div>
                                <% if (!departments.get(departments.size()-1).equals(dept)) { %>
                                    <hr>
                                <% } %>
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-4 col-lg-12 mb-4">
                <div class="card dashboard-card">
                    <div class="card-header bg-info text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-chart-pie me-2"></i>Task Status Distribution
                        </h5>
                    </div>
                    <div class="card-body">
                        <% for (Map.Entry<String, Integer> entry : taskCounts.entrySet()) { %>
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span><%= entry.getKey().replace("_", " ") %></span>
                                <div>
                                    <span class="badge bg-secondary me-2"><%= entry.getValue() %></span>
                                    <div class="progress" style="width: 100px; height: 8px;">
                                        <%
                                            int progressWidth = totalTasks > 0 ? (entry.getValue() * 100 / totalTasks) : 0;
                                        %>
                                        <div class="progress-bar" style="width: <%= progressWidth %>%"></div>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Tasks and Activity -->
        <div class="row">
            <div class="col-xl-8 mb-4">
                <div class="card dashboard-card">
                    <div class="card-header bg-warning text-dark">
                        <h5 class="mb-0">
                            <i class="fas fa-tasks me-2"></i>Recent Tasks
                        </h5>
                    </div>
                    <div class="card-body">
                        <% if (recentTasks.isEmpty()) { %>
                            <p class="text-muted">No tasks found.</p>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th>ID</th>
                                            <th>Title</th>
                                            <th>Status</th>
                                            <th>Priority</th>
                                            <th>Due Date</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Task task : recentTasks) { %>
                                            <tr>
                                                <td><%= task.getId() %></td>
                                                <td>
                                                    <a href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= task.getId() %>" class="text-decoration-none">
                                                        <%= task.getTitle() %>
                                                    </a>
                                                </td>
                                                <td>
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
                                                    <span class="badge bg-<%= statusClass %>">
                                                        <%= task.getStatus().toString().replace("_", " ") %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <%
                                                        String priorityClass = "success";
                                                        if (task.getPriority() == Task.Priority.HIGH) {
                                                            priorityClass = "danger";
                                                        } else if (task.getPriority() == Task.Priority.MEDIUM) {
                                                            priorityClass = "warning";
                                                        }
                                                    %>
                                                    <span class="badge bg-<%= priorityClass %>">
                                                        <%= task.getPriority() %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <%= task.getDueDate() %>
                                                    <% if (task.getDueDate() != null && task.getDueDate().isBefore(today) && 
                                                           task.getStatus() != Task.Status.COMPLETED) { %>
                                                        <i class="fas fa-exclamation-triangle text-danger ms-1" title="Overdue"></i>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <a href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= task.getId() %>" class="btn btn-sm btn-outline-primary">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-4 mb-4">
                <div class="card dashboard-card">
                    <div class="card-header bg-secondary text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-history me-2"></i>Recent Activity
                        </h5>
                    </div>
                    <div class="card-body" style="max-height: 400px; overflow-y: auto;">
                        <% if (recentActivity.isEmpty()) { %>
                            <p class="text-muted">No recent activity.</p>
                        <% } else { %>
                            <% for (TaskActivityLog activity : recentActivity) { %>
                                <div class="activity-item">
                                    <div class="d-flex justify-content-between">
                                        <strong><%= activity.getAction().toString().replace("_", " ") %></strong>
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

        <!-- Admin Actions -->
        <div class="row">
            <div class="col-12">
                <div class="card dashboard-card">
                    <div class="card-header bg-dark text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-tools me-2"></i>Administrative Actions
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/task-create.jsp" class="btn btn-primary">
                                        <i class="fas fa-plus me-2"></i>Create New Task
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/tasks.jsp" class="btn btn-success">
                                        <i class="fas fa-list me-2"></i>Manage All Tasks
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/reports.jsp" class="btn btn-info">
                                        <i class="fas fa-chart-bar me-2"></i>View Reports
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/simple-test.jsp" class="btn btn-warning">
                                        <i class="fas fa-database me-2"></i>System Health
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
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
</body>
</html>