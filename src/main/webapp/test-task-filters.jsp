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
    <title>Test Task Filters - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <%
        // Initialize DAOs
        TaskDAO taskDAO = new TaskDAO();
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
    %>

    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <h2><i class="fas fa-vial me-2"></i>Task Filter Test</h2>
                <div class="alert alert-info">
                    <strong>Filter Test Results:</strong>
                    <ul class="mb-0 mt-2">
                        <li>Status Filter: <%= statusFilter != null ? statusFilter : "None" %></li>
                        <li>Priority Filter: <%= priorityFilter != null ? priorityFilter : "None" %></li>
                        <li>Department Filter: <%= departmentFilter != null ? departmentFilter : "None" %></li>
                        <li>Search Filter: <%= search != null ? search : "None" %></li>
                        <li>Total Filters Applied: <%= filters.size() %></li>
                        <li>Tasks Found: <%= tasks.size() %></li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- Test Form -->
        <div class="card mb-4">
            <div class="card-header">
                <h5><i class="fas fa-filter me-2"></i>Test Filters</h5>
            </div>
            <div class="card-body">
                <form method="get" action="test-task-filters.jsp">
                    <div class="row">
                        <div class="col-md-3">
                            <label class="form-label">Status</label>
                            <select class="form-select" name="status">
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
                            <select class="form-select" name="priority">
                                <option value="">All Priorities</option>
                                <option value="HIGH" <%= "HIGH".equals(priorityFilter) ? "selected" : "" %>>High</option>
                                <option value="MEDIUM" <%= "MEDIUM".equals(priorityFilter) ? "selected" : "" %>>Medium</option>
                                <option value="LOW" <%= "LOW".equals(priorityFilter) ? "selected" : "" %>>Low</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Department</label>
                            <select class="form-select" name="departmentId">
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
                            <input type="text" class="form-control" name="search" value="<%= search != null ? search : "" %>" placeholder="Search tasks...">
                        </div>
                    </div>
                    <div class="row mt-3">
                        <div class="col-12">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-search me-1"></i>Test Filters
                            </button>
                            <a href="test-task-filters.jsp" class="btn btn-secondary ms-2">
                                <i class="fas fa-times me-1"></i>Clear All
                            </a>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Results -->
        <div class="card">
            <div class="card-header">
                <h5><i class="fas fa-list me-2"></i>Filter Results (<%= tasks.size() %> tasks)</h5>
            </div>
            <div class="card-body">
                <% if (tasks.isEmpty()) { %>
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        No tasks found with the current filters.
                    </div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Title</th>
                                    <th>Status</th>
                                    <th>Priority</th>
                                    <th>Department</th>
                                    <th>Due Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Task task : tasks) { %>
                                    <tr>
                                        <td><%= task.getId() %></td>
                                        <td><%= task.getTitle() %></td>
                                        <td>
                                            <span class="badge bg-primary"><%= task.getStatus() %></span>
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
                                            <span class="badge bg-<%= priorityClass %>"><%= task.getPriority() %></span>
                                        </td>
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
                                        <td><%= task.getDueDate() %></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>
        </div>

        <div class="mt-4">
            <a href="tasks.jsp" class="btn btn-success">
                <i class="fas fa-arrow-left me-1"></i>Back to Tasks
            </a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>