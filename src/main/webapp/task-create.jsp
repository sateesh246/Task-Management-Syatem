<%@page import="com.taskmanagement.dao.DepartmentDAO"%>
<%@page import="com.taskmanagement.dao.EmployeeDAO"%>
<%@page import="com.taskmanagement.dao.TaskDAO"%>
<%@page import="com.taskmanagement.dao.TaskActivityLogDAO"%>
<%@page import="com.taskmanagement.model.Department"%>
<%@page import="com.taskmanagement.model.Employee"%>
<%@page import="com.taskmanagement.model.Task"%>
<%@page import="com.taskmanagement.util.ValidationUtil"%>
<%@page import="java.util.List"%>
<%@page import="java.time.LocalDate"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Task - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <%
        // Initialize DAOs
        DepartmentDAO departmentDAO = new DepartmentDAO();
        EmployeeDAO employeeDAO = new EmployeeDAO();
        TaskDAO taskDAO = new TaskDAO();
        TaskActivityLogDAO activityLogDAO = new TaskActivityLogDAO();
        
        // Get reference data
        List<Department> departments = null;
        List<Employee> employees = null;
        
        try {
            departments = departmentDAO.getAll();
            employees = employeeDAO.getAll(null, null, true);
        } catch (Exception e) {
            // Handle error - create empty lists
            departments = new java.util.ArrayList<>();
            employees = new java.util.ArrayList<>();
        }
        
        // Handle form submission
        String message = "";
        String messageType = "";
        boolean isSubmission = "POST".equals(request.getMethod());
        Task createdTask = null;
        
        if (isSubmission) {
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String priorityStr = request.getParameter("priority");
            String dueDateStr = request.getParameter("dueDate");
            String departmentIdStr = request.getParameter("departmentId");
            
            boolean hasErrors = false;
            
            // Validate inputs
            if (title == null || title.trim().length() < 3 || title.trim().length() > 200) {
                message += "Title is required and must be 3-200 characters. ";
                hasErrors = true;
            }
            
            if (description == null || description.trim().length() < 10 || description.trim().length() > 2000) {
                message += "Description is required and must be 10-2000 characters. ";
                hasErrors = true;
            }
            
            Task.Priority priority = Task.Priority.MEDIUM;
            try {
                if (priorityStr != null && !priorityStr.isEmpty()) {
                    priority = Task.Priority.valueOf(priorityStr);
                }
            } catch (Exception e) {
                message += "Invalid priority selected. ";
                hasErrors = true;
            }
            
            LocalDate dueDate = LocalDate.now().plusDays(7);
            try {
                if (dueDateStr != null && !dueDateStr.isEmpty()) {
                    dueDate = LocalDate.parse(dueDateStr);
                    if (dueDate.isBefore(LocalDate.now())) {
                        message += "Due date must be in the future. ";
                        hasErrors = true;
                    }
                }
            } catch (Exception e) {
                message += "Invalid due date format. ";
                hasErrors = true;
            }
            
            int departmentId = 1;
            try {
                if (departmentIdStr != null && !departmentIdStr.isEmpty()) {
                    departmentId = Integer.parseInt(departmentIdStr);
                }
            } catch (Exception e) {
                message += "Invalid department selected. ";
                hasErrors = true;
            }
            
            if (!hasErrors) {
                try {
                    // Sanitize inputs
                    title = title.trim();
                    description = description.trim();
                    
                    // Create task (using admin user ID = 1)
                    Task newTask = new Task(title, description, priority, dueDate, departmentId, 1);
                    
                    if (taskDAO.create(newTask)) {
                        // Log task creation
                        try {
                            activityLogDAO.logTaskCreation(newTask.getId(), 1, title);
                        } catch (Exception e) {
                            // Log error but continue
                        }
                        
                        message = "Task created successfully! Task ID: " + newTask.getId();
                        messageType = "success";
                        createdTask = newTask;
                        
                        // Redirect to task detail page after 3 seconds
                        response.setHeader("refresh", "3; url=" + request.getContextPath() + "/task-detail.jsp?id=" + newTask.getId());
                    } else {
                        message = "Failed to create task. Please try again.";
                        messageType = "danger";
                    }
                } catch (Exception e) {
                    message = "Error creating task: " + e.getMessage();
                    messageType = "danger";
                }
            } else {
                messageType = "danger";
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
                <a class="nav-link active" href="<%= request.getContextPath() %>/task-create.jsp">
                    <i class="fas fa-plus me-1"></i>Create Task
                </a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <h4 class="mb-0">
                            <i class="fas fa-plus me-2"></i>Create New Task
                        </h4>
                    </div>
                    <div class="card-body">
                        <div class="alert alert-info" role="alert">
                            <i class="fas fa-info-circle me-2"></i>
                            <strong>JSP Direct Access:</strong> This page directly imports and uses Java DAO classes.
                            Found <%= departments.size() %> departments and <%= employees.size() %> employees.
                        </div>

                        <% if (!message.isEmpty()) { %>
                            <div class="alert alert-<%= messageType %>" role="alert">
                                <%= message %>
                                <% if (createdTask != null) { %>
                                    <br><a href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= createdTask.getId() %>">View Created Task</a>
                                <% } %>
                            </div>
                        <% } %>

                        <form method="post" action="task-create.jsp">
                            <div class="row">
                                <div class="col-md-8">
                                    <div class="mb-3">
                                        <label class="form-label">Task Title *</label>
                                        <input type="text" class="form-control" name="title" 
                                               value="<%= request.getParameter("title") != null ? request.getParameter("title") : "" %>" 
                                               required maxlength="200">
                                        <div class="form-text">Enter a clear, descriptive title (3-200 characters)</div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="mb-3">
                                        <label class="form-label">Priority *</label>
                                        <select class="form-select" name="priority" required>
                                            <option value="LOW" <%= "LOW".equals(request.getParameter("priority")) ? "selected" : "" %>>
                                                Low
                                            </option>
                                            <option value="MEDIUM" <%= "MEDIUM".equals(request.getParameter("priority")) || request.getParameter("priority") == null ? "selected" : "" %>>
                                                Medium
                                            </option>
                                            <option value="HIGH" <%= "HIGH".equals(request.getParameter("priority")) ? "selected" : "" %>>
                                                High
                                            </option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Description *</label>
                                <textarea class="form-control" name="description" rows="4" required maxlength="2000"><%= request.getParameter("description") != null ? request.getParameter("description") : "" %></textarea>
                                <div class="form-text">Provide detailed task description (10-2000 characters)</div>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Department *</label>
                                        <select class="form-select" name="departmentId" required>
                                            <option value="">Select Department</option>
                                            <% for (Department dept : departments) { %>
                                                <option value="<%= dept.getId() %>" 
                                                        <%= String.valueOf(dept.getId()).equals(request.getParameter("departmentId")) ? "selected" : "" %>>
                                                    <%= dept.getName() %>
                                                </option>
                                            <% } %>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label">Due Date *</label>
                                        <input type="date" class="form-control" name="dueDate" 
                                               value="<%= request.getParameter("dueDate") != null ? request.getParameter("dueDate") : LocalDate.now().plusDays(7) %>" 
                                               min="<%= LocalDate.now() %>" required>
                                    </div>
                                </div>
                            </div>

                            <% if (!employees.isEmpty()) { %>
                            <div class="mb-3">
                                <label class="form-label">Initial Assignees (Optional)</label>
                                <select class="form-select" name="assignees" multiple size="5">
                                    <% for (Employee emp : employees) { %>
                                        <option value="<%= emp.getId() %>">
                                            <%= emp.getName() %> (<%= emp.getEmail() %>)
                                        </option>
                                    <% } %>
                                </select>
                                <div class="form-text">Hold Ctrl/Cmd to select multiple employees</div>
                            </div>
                            <% } %>

                            <div class="d-flex justify-content-between">
                                <a href="<%= request.getContextPath() %>/tasks.jsp" class="btn btn-secondary">
                                    <i class="fas fa-arrow-left me-1"></i>Back to Tasks
                                </a>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-plus me-1"></i>Create Task
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>