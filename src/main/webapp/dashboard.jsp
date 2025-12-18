<%@page import="com.taskmanagement.dao.TaskDAO"%>
<%@page import="com.taskmanagement.dao.EmployeeDAO"%>
<%@page import="com.taskmanagement.dao.DepartmentDAO"%>
<%@page import="com.taskmanagement.model.Task"%>
<%@page import="com.taskmanagement.model.Employee"%>
<%@page import="com.taskmanagement.model.Department"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Task Management System</title>
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
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
    </style>
</head>
<body class="bg-light">
    <%
        // Initialize DAOs
        TaskDAO taskDAO = new TaskDAO();
        EmployeeDAO employeeDAO = new EmployeeDAO();
        DepartmentDAO departmentDAO = new DepartmentDAO();
        
        // Get system statistics
        Map<String, Integer> taskCounts = taskDAO.getTaskCountByStatus(null, null);
        List<Task> recentTasks = taskDAO.getTasks(new HashMap<>(), 0, 10);
        List<Task> overdueTasks = taskDAO.getOverdueTasks();
        List<Department> departments = departmentDAO.getAllWithStats();
        List<Employee> allEmployees = employeeDAO.getAll(null, null, true);
        
        // Calculate metrics
        int totalTasks = taskCounts.values().stream().mapToInt(Integer::intValue).sum();
        int completedTasks = taskCounts.getOrDefault("COMPLETED", 0);
        int inProgressTasks = taskCounts.getOrDefault("IN_PROGRESS", 0);
        int pendingTasks = taskCounts.getOrDefault("PENDING", 0);
        double completionRate = totalTasks > 0 ? (double) completedTasks / totalTasks * 100 : 0;
        
        // Count employees by role
        long managerCount = allEmployees.stream().filter(Employee::isManager).count();
        long employeeCount = allEmployees.stream().filter(Employee::isEmployee).count();
        long adminCount = allEmployees.stream().filter(Employee::isAdmin).count();
    %>

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="<%= request.getContextPath() %>/">
                <i class="fas fa-tasks me-2"></i>Task Management System
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="<%= request.getContextPath() %>/dashboard.jsp">
                            <i class="fas fa-tachometer-alt me-1"></i>Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/tasks.jsp">
                            <i class="fas fa-tasks me-1"></i>Tasks
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/profile.jsp">
                            <i class="fas fa-user me-1"></i>Profile
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/test">
                            <i class="fas fa-heartbeat me-1"></i>System Status
                        </a>
                    </li>
                </ul>
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="btn btn-success" href="<%= request.getContextPath() %>/task-create.jsp">
                            <i class="fas fa-plus me-1"></i>New Task
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <div class="row">
            <div class="col-12">
                <div class="alert alert-success" role="alert">
                    <i class="fas fa-check-circle me-2"></i>
                    <strong>JSP Direct Access:</strong> This dashboard directly imports and uses Java DAO classes.
                    System loaded with <%= totalTasks %> total tasks across <%= departments.size() %> departments.
                </div>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card dashboard-card stat-card">
                    <div class="card-body text-center">
                        <i class="fas fa-tasks fa-2x mb-2"></i>
                        <h3><%= totalTasks %></h3>
                        <p class="mb-0">Total Tasks</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card dashboard-card stat-card">
                    <div class="card-body text-center">
                        <i class="fas fa-check-circle fa-2x mb-2"></i>
                        <h3><%= completedTasks %></h3>
                        <p class="mb-0">Completed</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card dashboard-card stat-card">
                    <div class="card-body text-center">
                        <i class="fas fa-clock fa-2x mb-2"></i>
                        <h3><%= inProgressTasks %></h3>
                        <p class="mb-0">In Progress</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card dashboard-card stat-card">
                    <div class="card-body text-center">
                        <i class="fas fa-exclamation-triangle fa-2x mb-2"></i>
                        <h3><%= overdueTasks.size() %></h3>
                        <p class="mb-0">Overdue</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="row">
            <div class="col-md-8">
                <div class="card dashboard-card">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="fas fa-list me-2"></i>Recent Tasks
                        </h5>
                    </div>
                    <div class="card-body">
                        <% if (recentTasks.isEmpty()) { %>
                            <p class="text-muted">No tasks found.</p>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Task</th>
                                            <th>Status</th>
                                            <th>Priority</th>
                                            <th>Due Date</th>
                                            <th>Department</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Task task : recentTasks) { %>
                                            <tr>
                                                <td>
                                                    <strong><%= task.getTitle() %></strong><br>
                                                    <small class="text-muted">
                                                        <%= task.getDescription().length() > 50 ? 
                                                            task.getDescription().substring(0, 50) + "..." : 
                                                            task.getDescription() %>
                                                    </small>
                                                </td>
                                                <td>
                                                    <%
                                                        String dashTaskStatusClass = "primary";
                                                        if (task.getStatus() == Task.Status.COMPLETED) {
                                                            dashTaskStatusClass = "success";
                                                        } else if (task.getStatus() == Task.Status.IN_PROGRESS) {
                                                            dashTaskStatusClass = "warning";
                                                        } else if (task.getStatus() == Task.Status.CANCELLED) {
                                                            dashTaskStatusClass = "danger";
                                                        }
                                                    %>
                                                    <span class="badge bg-<%= dashTaskStatusClass %>">
                                                        <%= task.getStatus().toString().replace("_", " ") %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <%
                                                        String dashTaskPriorityClass = "success";
                                                        if (task.getPriority() == Task.Priority.HIGH) {
                                                            dashTaskPriorityClass = "danger";
                                                        } else if (task.getPriority() == Task.Priority.MEDIUM) {
                                                            dashTaskPriorityClass = "warning";
                                                        }
                                                    %>
                                                    <span class="badge bg-<%= dashTaskPriorityClass %>">
                                                        <%= task.getPriority() %>
                                                    </span>
                                                </td>
                                                <td><%= task.getDueDate() %></td>
                                                <td>
                                                    <% 
                                                        String deptName = "Unknown";
                                                        for (Department dept : departments) {
                                                            if (dept.getId() == task.getDepartmentId()) {
                                                                deptName = dept.getName();
                                                                break;
                                                            }
                                                        }
                                                    %>
                                                    <%= deptName %>
                                                </td>
                                                <td>
                                                    <div class="btn-group btn-group-sm">
                                                        <a href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= task.getId() %>" 
                                                           class="btn btn-outline-primary">
                                                            <i class="fas fa-eye"></i>
                                                        </a>
                                                        <a href="<%= request.getContextPath() %>/task-edit.jsp?id=<%= task.getId() %>" 
                                                           class="btn btn-outline-success">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                    </div>
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

            <div class="col-md-4">
                <!-- System Overview -->
                <div class="card dashboard-card mb-3">
                    <div class="card-header">
                        <h5 class="mb-0">
                            <i class="fas fa-chart-pie me-2"></i>System Overview
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <div class="d-flex justify-content-between">
                                <span>Completion Rate</span>
                                <span><%= Math.round(completionRate) %>%</span>
                            </div>
                            <div class="progress">
                                <div class="progress-bar bg-success" style="width: 75%"></div>
                            </div>
                        </div>
                        
                        <hr>
                        
                        <div class="row text-center">
                            <div class="col-4">
                                <h6><%= departments.size() %></h6>
                                <small class="text-muted">Departments</small>
                            </div>
                            <div class="col-4">
                                <h6><%= allEmployees.size() %></h6>
                                <small class="text-muted">Employees</small>
                            </div>
                            <div class="col-4">
                                <h6><%= adminCount %></h6>
                                <small class="text-muted">Admins</small>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Departments -->
                <div class="card dashboard-card mb-3">
                    <div class="card-header">
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
                                        <strong><%= dept.getName() %></strong><br>
                                        <small class="text-muted"><%= dept.getDescription() %></small>
                                    </div>
                                    <span class="badge bg-primary"><%= dept.getEmployeeCount() %> emp</span>
                                </div>
                                <% if (!departments.get(departments.indexOf(dept)).equals(departments.get(departments.size() - 1))) { %>
                                    <hr>
                                <% } %>
                            <% } %>
                        <% } %>
                    </div>
                </div>

                <!-- Overdue Tasks -->
                <% if (!overdueTasks.isEmpty()) { %>
                    <div class="card dashboard-card">
                        <div class="card-header bg-danger text-white">
                            <h5 class="mb-0">
                                <i class="fas fa-exclamation-triangle me-2"></i>Overdue Tasks
                            </h5>
                        </div>
                        <div class="card-body">
                            <% for (int i = 0; i < Math.min(5, overdueTasks.size()); i++) { 
                                Task overdueTask = overdueTasks.get(i);
                            %>
                                <div class="mb-2">
                                    <a href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= overdueTask.getId() %>" 
                                       class="text-decoration-none">
                                        <strong><%= overdueTask.getTitle() %></strong>
                                    </a><br>
                                    <small class="text-muted">Due: <%= overdueTask.getDueDate() %></small>
                                </div>
                                <% if (i < Math.min(4, overdueTasks.size() - 1)) { %>
                                    <hr>
                                <% } %>
                            <% } %>
                            <% if (overdueTasks.size() > 5) { %>
                                <div class="text-center mt-2">
                                    <a href="<%= request.getContextPath() %>/tasks.jsp?status=overdue" class="btn btn-sm btn-outline-danger">
                                        View All <%= overdueTasks.size() %> Overdue Tasks
                                    </a>
                                </div>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>