<%@page import="com.taskmanagement.dao.TaskDAO"%>
<%@page import="com.taskmanagement.dao.EmployeeDAO"%>
<%@page import="com.taskmanagement.dao.DepartmentDAO"%>
<%@page import="com.taskmanagement.model.Employee"%>
<%@page import="com.taskmanagement.model.Task"%>
<%@page import="com.taskmanagement.model.Department"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    EmployeeDAO employeeDAO = new EmployeeDAO();
    DepartmentDAO departmentDAO = new DepartmentDAO();
    
    // Get task details
    Task task = taskDAO.getById(taskId);
    if (task == null) {
        response.sendRedirect(request.getContextPath() + "/tasks.jsp");
        return;
    }
    
    // Get all employees and departments for dropdowns
    List<Employee> allEmployees = employeeDAO.getAll(null, null, true);
    List<Department> departments = departmentDAO.getAll();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Task #<%= task.getId() %> - <%= task.getTitle() %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .form-section {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            margin-bottom: 2rem;
        }
        .section-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1rem 1.5rem;
            border-radius: 15px 15px 0 0;
            margin-bottom: 0;
        }
        .required-field::after {
            content: " *";
            color: #dc3545;
        }
        .version-warning {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1rem;
        }
        .change-indicator {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 0.5rem;
            margin: 0.5rem 0;
        }
    </style>
</head>
<body class="bg-light">
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="<%= request.getContextPath() %>/">
                <i class="fas fa-tasks me-2"></i>Task Management System
            </a>
            <div class="navbar-nav me-auto">
                <a class="nav-link" href="<%= request.getContextPath() %>/dashboard.jsp">
                    <i class="fas fa-tachometer-alt me-1"></i>Dashboard
                </a>
                <a class="nav-link" href="<%= request.getContextPath() %>/tasks.jsp">
                    <i class="fas fa-tasks me-1"></i>Tasks
                </a>
                <a class="nav-link active" href="#">
                    <i class="fas fa-edit me-1"></i>Edit Task
                </a>
            </div>
            <div class="navbar-nav">
                <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= task.getId() %>">
                    <i class="fas fa-eye me-1"></i>View Task
                </a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <!-- Page Header -->
        <div class="row">
            <div class="col-12">
                <div class="alert alert-info" role="alert">
                    <i class="fas fa-edit me-2"></i>
                    <strong>Edit Task:</strong> Modify task details and settings for Task #<%= task.getId() %> - <%= task.getTitle() %>
                </div>
            </div>
        </div>

        <!-- Version Warning -->
        <div class="version-warning">
            <i class="fas fa-info-circle me-2"></i>
            <strong>Version Control:</strong> This task is currently at version <%= task.getVersion() %>. 
            Changes will increment the version number to prevent conflicts.
        </div>

        <!-- Edit Form -->
        <form action="<%= request.getContextPath() %>/tasks/<%= task.getId() %>" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="taskId" value="<%= task.getId() %>">
            <input type="hidden" name="currentVersion" value="<%= task.getVersion() %>">

            <!-- Basic Information Section -->
            <div class="form-section">
                <h5 class="section-header">
                    <i class="fas fa-info-circle me-2"></i>Basic Information
                </h5>
                <div class="p-4">
                    <div class="row">
                        <div class="col-md-8">
                            <div class="mb-3">
                                <label for="title" class="form-label required-field">Task Title</label>
                                <input type="text" class="form-control" id="title" name="title" 
                                       value="<%= task.getTitle() %>" required maxlength="200">
                                <div class="form-text">Enter a clear, descriptive title for the task</div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label for="priority" class="form-label required-field">Priority</label>
                                <select class="form-select" id="priority" name="priority" required>
                                    <option value="LOW" <%= task.getPriority() == Task.Priority.LOW ? "selected" : "" %>>Low</option>
                                    <option value="MEDIUM" <%= task.getPriority() == Task.Priority.MEDIUM ? "selected" : "" %>>Medium</option>
                                    <option value="HIGH" <%= task.getPriority() == Task.Priority.HIGH ? "selected" : "" %>>High</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="description" class="form-label required-field">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="4" 
                                  required maxlength="1000"><%= task.getDescription() %></textarea>
                        <div class="form-text">Provide detailed information about the task requirements</div>
                    </div>

                    <div class="row">
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label for="status" class="form-label required-field">Status</label>
                                <select class="form-select" id="status" name="status" required>
                                    <option value="PENDING" <%= task.getStatus() == Task.Status.PENDING ? "selected" : "" %>>Pending</option>
                                    <option value="IN_PROGRESS" <%= task.getStatus() == Task.Status.IN_PROGRESS ? "selected" : "" %>>In Progress</option>
                                    <option value="UNDER_REVIEW" <%= task.getStatus() == Task.Status.UNDER_REVIEW ? "selected" : "" %>>Under Review</option>
                                    <option value="COMPLETED" <%= task.getStatus() == Task.Status.COMPLETED ? "selected" : "" %>>Completed</option>
                                    <option value="CANCELLED" <%= task.getStatus() == Task.Status.CANCELLED ? "selected" : "" %>>Cancelled</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label for="dueDate" class="form-label required-field">Due Date</label>
                                <input type="date" class="form-control" id="dueDate" name="dueDate" 
                                       value="<%= task.getDueDate() %>" required>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label for="departmentId" class="form-label required-field">Department</label>
                                <select class="form-select" id="departmentId" name="departmentId" required>
                                    <option value="">Select Department</option>
                                    <% for (Department dept : departments) { %>
                                        <option value="<%= dept.getId() %>" 
                                                <%= task.getDepartmentId() == dept.getId() ? "selected" : "" %>>
                                            <%= dept.getName() %>
                                        </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Task Information Section -->
            <div class="form-section">
                <h5 class="section-header">
                    <i class="fas fa-clipboard me-2"></i>Task Information
                </h5>
                <div class="p-4">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="change-indicator">
                                <strong>Created:</strong> <%= task.getCreatedAt() %>
                                <br><strong>Created By:</strong> <%= task.getCreatedByName() %>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="change-indicator">
                                <strong>Last Updated:</strong> <%= task.getUpdatedAt() != null ? task.getUpdatedAt() : "Never" %>
                                <br><strong>Current Version:</strong> <%= task.getVersion() %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="form-section">
                <div class="p-4">
                    <div class="row">
                        <div class="col-md-6">
                            <button type="submit" class="btn btn-primary btn-lg me-3">
                                <i class="fas fa-save me-2"></i>Save Changes
                            </button>
                            <a href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= task.getId() %>" 
                               class="btn btn-secondary btn-lg">
                                <i class="fas fa-times me-2"></i>Cancel
                            </a>
                        </div>
                        <div class="col-md-6 text-end">
                            <a href="<%= request.getContextPath() %>/tasks.jsp" class="btn btn-outline-primary">
                                <i class="fas fa-list me-2"></i>Back to Tasks
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </form>

        <!-- Help Section -->
        <div class="form-section">
            <h5 class="section-header">
                <i class="fas fa-question-circle me-2"></i>Help & Guidelines
            </h5>
            <div class="p-4">
                <div class="row">
                    <div class="col-md-6">
                        <h6>Editing Guidelines:</h6>
                        <ul class="list-unstyled">
                            <li><i class="fas fa-check text-success me-2"></i>All required fields must be filled</li>
                            <li><i class="fas fa-check text-success me-2"></i>Title should be clear and descriptive</li>
                            <li><i class="fas fa-check text-success me-2"></i>Set appropriate priority level</li>
                            <li><i class="fas fa-check text-success me-2"></i>Choose realistic due dates</li>
                        </ul>
                    </div>
                    <div class="col-md-6">
                        <h6>Status Meanings:</h6>
                        <ul class="list-unstyled">
                            <li><span class="badge bg-info me-2">PENDING</span>Task is waiting to be started</li>
                            <li><span class="badge bg-warning me-2">IN_PROGRESS</span>Task is currently being worked on</li>
                            <li><span class="badge bg-primary me-2">UNDER_REVIEW</span>Task is completed and awaiting review</li>
                            <li><span class="badge bg-success me-2">COMPLETED</span>Task is finished and approved</li>
                            <li><span class="badge bg-danger me-2">CANCELLED</span>Task has been cancelled</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Form validation
        document.querySelector('form').addEventListener('submit', function(e) {
            const title = document.getElementById('title').value.trim();
            const description = document.getElementById('description').value.trim();
            const dueDate = document.getElementById('dueDate').value;
            
            if (!title || !description || !dueDate) {
                e.preventDefault();
                alert('Please fill in all required fields.');
                return false;
            }
            
            // Check if due date is in the past
            const today = new Date().toISOString().split('T')[0];
            if (dueDate < today) {
                if (!confirm('The due date is in the past. Are you sure you want to continue?')) {
                    e.preventDefault();
                    return false;
                }
            }
        });
        
        // Auto-resize textarea
        document.getElementById('description').addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = this.scrollHeight + 'px';
        });
    </script>
</body>
</html>