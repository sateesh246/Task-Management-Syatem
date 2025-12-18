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
    <title>Tasks - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .task-card {
            transition: transform 0.2s;
            border-left: 4px solid #007bff;
            margin-bottom: 15px;
        }
        .task-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
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
        
        // Get filter parameters
        String statusFilter = request.getParameter("status");
        String priorityFilter = request.getParameter("priority");
        String departmentFilter = request.getParameter("departmentId");
        String search = request.getParameter("search");
        
        // Build filters
        Map<String, Object> filters = new HashMap<>();
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            filters.put("status", statusFilter.trim());
        }
        if (priorityFilter != null && !priorityFilter.trim().isEmpty()) {
            filters.put("priority", priorityFilter.trim());
        }
        if (departmentFilter != null && !departmentFilter.trim().isEmpty()) {
            try {
                filters.put("departmentId", Integer.parseInt(departmentFilter.trim()));
            } catch (NumberFormatException e) {
                // Ignore invalid department ID
            }
        }
        if (search != null && !search.trim().isEmpty()) {
            filters.put("search", search.trim());
        }
        
        // Get tasks
        List<Task> tasks = taskDAO.getTasks(filters, 0, 50);
        
        // Get reference data
        List<Department> departments = departmentDAO.getAll();
        List<Employee> employees = employeeDAO.getAll(null, null, true);
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
                        <a class="nav-link" href="<%= request.getContextPath() %>/dashboard">
                            <i class="fas fa-tachometer-alt me-1"></i>Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="<%= request.getContextPath() %>/tasks.jsp">
                            <i class="fas fa-tasks me-1"></i>Tasks
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
                    <strong>JSP Direct Access:</strong> This page directly imports and uses Java DAO classes without servlets.
                    Found <%= tasks.size() %> tasks
                    <%
                        int activeFilters = 0;
                        if (statusFilter != null && !statusFilter.trim().isEmpty()) activeFilters++;
                        if (priorityFilter != null && !priorityFilter.trim().isEmpty()) activeFilters++;
                        if (departmentFilter != null && !departmentFilter.trim().isEmpty()) activeFilters++;
                        if (search != null && !search.trim().isEmpty()) activeFilters++;
                        
                        if (activeFilters > 0) {
                    %>
                        with <%= activeFilters %> active filter<%= activeFilters > 1 ? "s" : "" %>
                    <% } %>
                    .
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="get" action="tasks.jsp" id="filterForm">
                    <div class="row">
                        <div class="col-md-3">
                            <label class="form-label">Status</label>
                            <select class="form-select filter-select" name="status">
                                <option value="">All Statuses</option>
                                <option value="PENDING" <%= "PENDING".equals(statusFilter) ? "selected" : "" %>>Pending</option>
                                <option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(statusFilter) ? "selected" : "" %>>In Progress</option>
                                <option value="UNDER_REVIEW" <%= "UNDER_REVIEW".equals(statusFilter) ? "selected" : "" %>>Under Review</option>
                                <option value="COMPLETED" <%= "COMPLETED".equals(statusFilter) ? "selected" : "" %>>Completed</option>
                                <option value="CANCELLED" <%= "CANCELLED".equals(statusFilter) ? "selected" : "" %>>Cancelled</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Priority</label>
                            <select class="form-select filter-select" name="priority">
                                <option value="">All Priorities</option>
                                <option value="HIGH" <%= "HIGH".equals(priorityFilter) ? "selected" : "" %>>High</option>
                                <option value="MEDIUM" <%= "MEDIUM".equals(priorityFilter) ? "selected" : "" %>>Medium</option>
                                <option value="LOW" <%= "LOW".equals(priorityFilter) ? "selected" : "" %>>Low</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Department</label>
                            <select class="form-select filter-select" name="departmentId">
                                <option value="">All Departments</option>
                                <% for (Department dept : departments) { %>
                                    <option value="<%= dept.getId() %>" <%= String.valueOf(dept.getId()).equals(departmentFilter) ? "selected" : "" %>>
                                        <%= dept.getName() %>
                                    </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Search</label>
                            <div class="input-group">
                                <input type="text" class="form-control" name="search" value="<%= search != null ? search : "" %>" placeholder="Search tasks...">
                                <button class="btn btn-primary" type="submit">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="row mt-3">
                        <div class="col-12">
                            <button type="submit" class="btn btn-primary me-2">
                                <i class="fas fa-filter me-1"></i>Apply Filters
                            </button>
                            <button type="button" class="btn btn-secondary me-2" onclick="clearFilters()">
                                <i class="fas fa-times me-1"></i>Clear Filters
                            </button>
                            
                            <!-- Active Filters Display -->
                            <% if (activeFilters > 0) { %>
                                <div class="d-inline-block">
                                    <span class="text-muted me-2">Active filters:</span>
                                    <% if (statusFilter != null && !statusFilter.trim().isEmpty()) { %>
                                        <span class="badge bg-info me-1">Status: <%= statusFilter %></span>
                                    <% } %>
                                    <% if (priorityFilter != null && !priorityFilter.trim().isEmpty()) { %>
                                        <span class="badge bg-warning me-1">Priority: <%= priorityFilter %></span>
                                    <% } %>
                                    <% if (departmentFilter != null && !departmentFilter.trim().isEmpty()) { %>
                                        <span class="badge bg-success me-1">Department: 
                                            <% 
                                                String selectedDeptName = "Unknown";
                                                for (Department dept : departments) {
                                                    if (String.valueOf(dept.getId()).equals(departmentFilter)) {
                                                        selectedDeptName = dept.getName();
                                                        break;
                                                    }
                                                }
                                            %>
                                            <%= selectedDeptName %>
                                        </span>
                                    <% } %>
                                    <% if (search != null && !search.trim().isEmpty()) { %>
                                        <span class="badge bg-secondary me-1">Search: "<%= search %>"</span>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Tasks Grid -->
        <div class="row">
            <% if (tasks.isEmpty()) { %>
                <div class="col-12">
                    <div class="alert alert-info text-center">
                        <i class="fas fa-info-circle fa-2x mb-2"></i>
                        <h5>No tasks found</h5>
                        <p>Try adjusting your filters or <a href="<%= request.getContextPath() %>/task-create.jsp">create a new task</a>.</p>
                    </div>
                </div>
            <% } else { %>
                <% for (Task task : tasks) { %>
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card task-card priority-<%= task.getPriority().name().toLowerCase() %> h-100">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <h5 class="card-title"><%= task.getTitle() %></h5>
                                    <%
                                        String taskPriorityClass = "success";
                                        if (task.getPriority() == Task.Priority.HIGH) {
                                            taskPriorityClass = "danger";
                                        } else if (task.getPriority() == Task.Priority.MEDIUM) {
                                            taskPriorityClass = "warning";
                                        }
                                    %>
                                    <span class="badge bg-<%= taskPriorityClass %>">
                                        <%= task.getPriority() %>
                                    </span>
                                </div>
                                <p class="card-text text-muted">
                                    <%= task.getDescription().length() > 100 ? 
                                        task.getDescription().substring(0, 100) + "..." : 
                                        task.getDescription() %>
                                </p>
                                <div class="mb-3">
                                    <small class="text-muted">
                                        <i class="fas fa-calendar me-1"></i>Due: <%= task.getDueDate() %>
                                        <br>
                                        <i class="fas fa-building me-1"></i>
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
                                    </small>
                                </div>
                                <div class="d-flex justify-content-between align-items-center">
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
                                    <span class="badge bg-<%= taskStatusClass %>">
                                        <%= task.getStatus().toString().replace("_", " ") %>
                                    </span>
                                    <div class="btn-group btn-group-sm">
                                        <a href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= task.getId() %>" class="btn btn-outline-primary">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="<%= request.getContextPath() %>/task-edit.jsp?id=<%= task.getId() %>" class="btn btn-outline-success">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto-submit form when filter dropdowns change
        document.addEventListener('DOMContentLoaded', function() {
            const filterSelects = document.querySelectorAll('.filter-select');
            
            filterSelects.forEach(function(select) {
                select.addEventListener('change', function() {
                    // Small delay to allow user to see the selection
                    setTimeout(function() {
                        document.getElementById('filterForm').submit();
                    }, 100);
                });
            });
        });
        
        // Clear all filters
        function clearFilters() {
            const form = document.getElementById('filterForm');
            const selects = form.querySelectorAll('select');
            const inputs = form.querySelectorAll('input[type="text"]');
            
            selects.forEach(function(select) {
                select.selectedIndex = 0;
            });
            
            inputs.forEach(function(input) {
                input.value = '';
            });
            
            form.submit();
        }
        
        // Show loading indicator when form is submitted
        document.getElementById('filterForm').addEventListener('submit', function() {
            const submitBtn = this.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Loading...';
                submitBtn.disabled = true;
            }
        });
    </script>
</body>
</html>