<%@page import="com.taskmanagement.dao.TaskDAO"%>
<%@page import="com.taskmanagement.dao.DepartmentDAO"%>
<%@page import="com.taskmanagement.model.Task"%>
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
    <title>Debug Tasks - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <%
        // Initialize DAOs
        TaskDAO taskDAO = new TaskDAO();
        DepartmentDAO departmentDAO = new DepartmentDAO();
        
        // Get all tasks without filters
        Map<String, Object> noFilters = new HashMap<>();
        List<Task> allTasks = taskDAO.getTasks(noFilters, 0, 100);
        
        // Get all departments
        List<Department> departments = departmentDAO.getAll();
        
        // Test specific filters
        Map<String, Object> statusFilter = new HashMap<>();
        statusFilter.put("status", "PENDING");
        List<Task> pendingTasks = taskDAO.getTasks(statusFilter, 0, 100);
        
        Map<String, Object> priorityFilter = new HashMap<>();
        priorityFilter.put("priority", "HIGH");
        List<Task> highPriorityTasks = taskDAO.getTasks(priorityFilter, 0, 100);
    %>

    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <h2><i class="fas fa-bug me-2"></i>Task Debug Information</h2>
                
                <!-- Summary -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card bg-primary text-white">
                            <div class="card-body">
                                <h5>Total Tasks</h5>
                                <h3><%= allTasks.size() %></h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-warning text-white">
                            <div class="card-body">
                                <h5>Pending Tasks</h5>
                                <h3><%= pendingTasks.size() %></h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-danger text-white">
                            <div class="card-body">
                                <h5>High Priority</h5>
                                <h3><%= highPriorityTasks.size() %></h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-success text-white">
                            <div class="card-body">
                                <h5>Departments</h5>
                                <h3><%= departments.size() %></h3>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- All Tasks -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5><i class="fas fa-list me-2"></i>All Tasks (<%= allTasks.size() %>)</h5>
                    </div>
                    <div class="card-body">
                        <% if (allTasks.isEmpty()) { %>
                            <div class="alert alert-warning">
                                <i class="fas fa-exclamation-triangle me-2"></i>
                                No tasks found in database. You may need to add some test data.
                            </div>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-sm">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Title</th>
                                            <th>Status</th>
                                            <th>Priority</th>
                                            <th>Dept ID</th>
                                            <th>Due Date</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Task task : allTasks) { %>
                                            <tr>
                                                <td><%= task.getId() %></td>
                                                <td><%= task.getTitle() %></td>
                                                <td><%= task.getStatus() %></td>
                                                <td><%= task.getPriority() %></td>
                                                <td><%= task.getDepartmentId() %></td>
                                                <td><%= task.getDueDate() %></td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- Departments -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5><i class="fas fa-building me-2"></i>Departments (<%= departments.size() %>)</h5>
                    </div>
                    <div class="card-body">
                        <% if (departments.isEmpty()) { %>
                            <div class="alert alert-warning">
                                <i class="fas fa-exclamation-triangle me-2"></i>
                                No departments found in database.
                            </div>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-sm">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Name</th>
                                            <th>Description</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Department dept : departments) { %>
                                            <tr>
                                                <td><%= dept.getId() %></td>
                                                <td><%= dept.getName() %></td>
                                                <td><%= dept.getDescription() != null ? dept.getDescription() : "N/A" %></td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- Filter Tests -->
                <div class="card">
                    <div class="card-header">
                        <h5><i class="fas fa-filter me-2"></i>Filter Test Results</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h6>Status Filter Test (PENDING)</h6>
                                <p>Found <%= pendingTasks.size() %> pending tasks</p>
                                <% if (!pendingTasks.isEmpty()) { %>
                                    <ul>
                                        <% for (Task task : pendingTasks) { %>
                                            <li><%= task.getTitle() %> (Status: <%= task.getStatus() %>)</li>
                                        <% } %>
                                    </ul>
                                <% } %>
                            </div>
                            <div class="col-md-6">
                                <h6>Priority Filter Test (HIGH)</h6>
                                <p>Found <%= highPriorityTasks.size() %> high priority tasks</p>
                                <% if (!highPriorityTasks.isEmpty()) { %>
                                    <ul>
                                        <% for (Task task : highPriorityTasks) { %>
                                            <li><%= task.getTitle() %> (Priority: <%= task.getPriority() %>)</li>
                                        <% } %>
                                    </ul>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="mt-4">
                    <a href="tasks.jsp" class="btn btn-primary me-2">
                        <i class="fas fa-arrow-left me-1"></i>Back to Tasks
                    </a>
                    <a href="test-task-filters.jsp" class="btn btn-success">
                        <i class="fas fa-vial me-1"></i>Test Filters
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>