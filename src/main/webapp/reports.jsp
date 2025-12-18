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
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports & Analytics - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .report-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            transition: all 0.3s ease;
            height: 100%;
        }
        .report-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
        }
        .report-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            color: white;
            margin: 0 auto 1rem;
        }
        .report-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
        .report-success { background: linear-gradient(135deg, #56ab2f 0%, #a8e6cf 100%); }
        .report-info { background: linear-gradient(135deg, #3498db 0%, #85c1e9 100%); }
        .report-warning { background: linear-gradient(135deg, #f39c12 0%, #f7dc6f 100%); }
        .report-danger { background: linear-gradient(135deg, #e74c3c 0%, #f1948a 100%); }
        .report-secondary { background: linear-gradient(135deg, #6c757d 0%, #adb5bd 100%); }
        
        .quick-stats {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 2rem;
            margin-bottom: 2rem;
        }
        .stat-item {
            text-align: center;
            padding: 1rem;
        }
        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            display: block;
        }
        .stat-label {
            font-size: 0.9rem;
            opacity: 0.9;
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
        
        // Get comprehensive statistics
        Map<String, Object> filters = new HashMap<>();
        List<Task> allTasks = taskDAO.getTasks(filters, 0, 1000);
        List<Employee> allEmployees = employeeDAO.getAll(null, null, true);
        List<Department> departments = departmentDAO.getAll();
        Map<String, Integer> taskCounts = taskDAO.getTaskCountByStatus(null, null);
        
        // Calculate statistics
        int totalTasks = allTasks.size();
        int completedTasks = taskCounts.getOrDefault("COMPLETED", 0);
        int inProgressTasks = taskCounts.getOrDefault("IN_PROGRESS", 0);
        int pendingTasks = taskCounts.getOrDefault("PENDING", 0);
        int totalEmployees = allEmployees.size();
        int totalDepartments = departments.size();
        
        // Calculate completion rate
        double completionRate = totalTasks > 0 ? (double) completedTasks / totalTasks * 100 : 0;
        
        // Count overdue tasks
        java.time.LocalDate today = java.time.LocalDate.now();
        int overdueTasks = 0;
        for (Task task : allTasks) {
            if (task.getDueDate() != null && task.getDueDate().isBefore(today) && 
                task.getStatus() != Task.Status.COMPLETED && task.getStatus() != Task.Status.CANCELLED) {
                overdueTasks++;
            }
        }
        
        // Count employees by role
        long adminCount = allEmployees.stream().filter(e -> e.getRole() == Employee.Role.ADMIN).count();
        long managerCount = allEmployees.stream().filter(e -> e.getRole() == Employee.Role.MANAGER).count();
        long employeeCount = allEmployees.stream().filter(e -> e.getRole() == Employee.Role.EMPLOYEE).count();
    %>

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-info">
        <div class="container-fluid">
            <a class="navbar-brand" href="<%= request.getContextPath() %>/">
                <i class="fas fa-chart-bar me-2"></i>Reports & Analytics
            </a>
            <div class="navbar-nav me-auto">
                <a class="nav-link" href="<%= request.getContextPath() %>/dashboard.jsp">
                    <i class="fas fa-tachometer-alt me-1"></i>Dashboard
                </a>
                <a class="nav-link active" href="<%= request.getContextPath() %>/reports.jsp">
                    <i class="fas fa-chart-bar me-1"></i>Reports
                </a>
                <a class="nav-link" href="<%= request.getContextPath() %>/tasks.jsp">
                    <i class="fas fa-tasks me-1"></i>Tasks
                </a>
            </div>
            <div class="navbar-nav">
                <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/index.html">
                    <i class="fas fa-home me-1"></i>Home
                </a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <!-- Page Header -->
        <div class="row">
            <div class="col-12">
                <div class="alert alert-info" role="alert">
                    <i class="fas fa-chart-bar me-2"></i>
                    <strong>Reports & Analytics:</strong> Comprehensive system overview and performance metrics.
                </div>
            </div>
        </div>

        <!-- Quick Stats -->
        <div class="quick-stats">
            <div class="row">
                <div class="col-md-2 stat-item">
                    <span class="stat-number"><%= totalTasks %></span>
                    <span class="stat-label">Total Tasks</span>
                </div>
                <div class="col-md-2 stat-item">
                    <span class="stat-number"><%= completedTasks %></span>
                    <span class="stat-label">Completed</span>
                </div>
                <div class="col-md-2 stat-item">
                    <span class="stat-number"><%= Math.round(completionRate) %>%</span>
                    <span class="stat-label">Completion Rate</span>
                </div>
                <div class="col-md-2 stat-item">
                    <span class="stat-number"><%= totalEmployees %></span>
                    <span class="stat-label">Employees</span>
                </div>
                <div class="col-md-2 stat-item">
                    <span class="stat-number"><%= totalDepartments %></span>
                    <span class="stat-label">Departments</span>
                </div>
                <div class="col-md-2 stat-item">
                    <span class="stat-number"><%= overdueTasks %></span>
                    <span class="stat-label">Overdue</span>
                </div>
            </div>
        </div>

        <!-- Report Categories -->
        <div class="row">
            <div class="col-lg-4 col-md-6 mb-4">
                <div class="report-card">
                    <div class="card-body text-center p-4">
                        <div class="report-icon report-primary">
                            <i class="fas fa-tasks"></i>
                        </div>
                        <h5 class="card-title">Task Status Report</h5>
                        <p class="card-text">Detailed breakdown of task statuses across all departments and projects.</p>
                        <div class="row text-center mt-3">
                            <div class="col-6">
                                <strong class="text-success"><%= completedTasks %></strong>
                                <br><small class="text-muted">Completed</small>
                            </div>
                            <div class="col-6">
                                <strong class="text-warning"><%= inProgressTasks %></strong>
                                <br><small class="text-muted">In Progress</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 col-md-6 mb-4">
                <div class="report-card">
                    <div class="card-body text-center p-4">
                        <div class="report-icon report-success">
                            <i class="fas fa-users"></i>
                        </div>
                        <h5 class="card-title">Team Performance</h5>
                        <p class="card-text">Employee productivity metrics and team performance analysis.</p>
                        <div class="row text-center mt-3">
                            <div class="col-4">
                                <strong class="text-danger"><%= adminCount %></strong>
                                <br><small class="text-muted">Admins</small>
                            </div>
                            <div class="col-4">
                                <strong class="text-warning"><%= managerCount %></strong>
                                <br><small class="text-muted">Managers</small>
                            </div>
                            <div class="col-4">
                                <strong class="text-success"><%= employeeCount %></strong>
                                <br><small class="text-muted">Employees</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 col-md-6 mb-4">
                <div class="report-card">
                    <div class="card-body text-center p-4">
                        <div class="report-icon report-info">
                            <i class="fas fa-building"></i>
                        </div>
                        <h5 class="card-title">Department Overview</h5>
                        <p class="card-text">Department-wise task distribution and completion rates.</p>
                        <div class="text-center mt-3">
                            <strong class="text-primary"><%= totalDepartments %></strong>
                            <br><small class="text-muted">Active Departments</small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 col-md-6 mb-4">
                <div class="report-card">
                    <div class="card-body text-center p-4">
                        <div class="report-icon report-warning">
                            <i class="fas fa-clock"></i>
                        </div>
                        <h5 class="card-title">Time Tracking</h5>
                        <p class="card-text">Work session analysis and time spent on various tasks and projects.</p>
                        <div class="text-center mt-3">
                            <strong class="text-info">Available</strong>
                            <br><small class="text-muted">Time Reports</small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 col-md-6 mb-4">
                <div class="report-card">
                    <div class="card-body text-center p-4">
                        <div class="report-icon report-danger">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        <h5 class="card-title">Overdue Tasks</h5>
                        <p class="card-text">Critical tasks that are past their due dates and require immediate attention.</p>
                        <div class="text-center mt-3">
                            <strong class="text-danger"><%= overdueTasks %></strong>
                            <br><small class="text-muted">Overdue Tasks</small>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 col-md-6 mb-4">
                <div class="report-card">
                    <div class="card-body text-center p-4">
                        <div class="report-icon report-secondary">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <h5 class="card-title">Productivity Trends</h5>
                        <p class="card-text">Historical data and trends showing productivity patterns over time.</p>
                        <div class="text-center mt-3">
                            <strong class="text-success"><%= Math.round(completionRate) %>%</strong>
                            <br><small class="text-muted">Overall Rate</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Detailed Statistics -->
        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-chart-bar me-2"></i>System Statistics
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h6>Task Status Breakdown</h6>
                                <div class="progress mb-3">
                                    <%
                                        int completedPercent = totalTasks > 0 ? (completedTasks * 100 / totalTasks) : 0;
                                        int inProgressPercent = totalTasks > 0 ? (inProgressTasks * 100 / totalTasks) : 0;
                                        int pendingPercent = totalTasks > 0 ? (pendingTasks * 100 / totalTasks) : 0;
                                    %>
                                    <div class="progress-bar bg-success" style="width: <%= completedPercent %>%">
                                        Completed (<%= completedTasks %>)
                                    </div>
                                    <div class="progress-bar bg-warning" style="width: <%= inProgressPercent %>%">
                                        In Progress (<%= inProgressTasks %>)
                                    </div>
                                    <div class="progress-bar bg-info" style="width: <%= pendingPercent %>%">
                                        Pending (<%= pendingTasks %>)
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <h6>Department Distribution</h6>
                                <% for (Department dept : departments) { %>
                                    <div class="d-flex justify-content-between">
                                        <span><%= dept.getName() %></span>
                                        <span class="badge bg-primary">ID: <%= dept.getId() %></span>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-header bg-dark text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-tools me-2"></i>Report Actions
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/dashboard.jsp" class="btn btn-primary">
                                        <i class="fas fa-tachometer-alt me-2"></i>Back to Dashboard
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/tasks.jsp" class="btn btn-success">
                                        <i class="fas fa-tasks me-2"></i>View All Tasks
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/simple-test.jsp" class="btn btn-info">
                                        <i class="fas fa-database me-2"></i>Database Test
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <button class="btn btn-warning" onclick="window.print()">
                                        <i class="fas fa-print me-2"></i>Print Report
                                    </button>
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