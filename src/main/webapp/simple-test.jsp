<%@page import="com.taskmanagement.config.DatabaseConfig"%>
<%@page import="com.taskmanagement.dao.TaskDAO"%>
<%@page import="com.taskmanagement.dao.EmployeeDAO"%>
<%@page import="com.taskmanagement.dao.DepartmentDAO"%>
<%@page import="com.taskmanagement.model.Task"%>
<%@page import="com.taskmanagement.model.Employee"%>
<%@page import="com.taskmanagement.model.Department"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Database Connection Test - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <div class="card">
            <div class="card-header bg-primary text-white">
                <h4><i class="fas fa-database me-2"></i>MySQL Database Connection Test</h4>
            </div>
            <div class="card-body">
                <%
                    StringBuilder results = new StringBuilder();
                    int successCount = 0;
                    int totalTests = 0;
                    
                    // Test 1: Database Connection
                    totalTests++;
                    results.append("<h5>1. Database Connection Test</h5>");
                    try {
                        boolean connected = DatabaseConfig.testConnection();
                        if (connected) {
                            results.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>Database connection: SUCCESS</div>");
                            successCount++;
                        } else {
                            results.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>Database connection: FAILED</div>");
                        }
                    } catch (Exception e) {
                        results.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>Database connection error: " + e.getMessage() + "</div>");
                    }
                    
                    // Test 2: Raw Connection Test
                    totalTests++;
                    results.append("<h5>2. Raw Connection Test</h5>");
                    try {
                        Connection conn = DatabaseConfig.getConnection();
                        if (conn != null && !conn.isClosed()) {
                            results.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>Raw connection: SUCCESS</div>");
                            conn.close();
                            successCount++;
                        } else {
                            results.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>Raw connection: FAILED</div>");
                        }
                    } catch (Exception e) {
                        results.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>Raw connection error: " + e.getMessage() + "</div>");
                    }
                    
                    // Test 3: Department Data from MySQL
                    totalTests++;
                    results.append("<h5>3. Department Data Test</h5>");
                    try {
                        DepartmentDAO departmentDAO = new DepartmentDAO();
                        List<Department> departments = departmentDAO.getAll();
                        results.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>Departments loaded: " + departments.size() + " records</div>");
                        
                        if (!departments.isEmpty()) {
                            results.append("<div class='card mt-2'><div class='card-body'>");
                            results.append("<h6>Sample Department Data:</h6>");
                            for (int i = 0; i < Math.min(3, departments.size()); i++) {
                                Department dept = departments.get(i);
                                results.append("<p><strong>ID:</strong> " + dept.getId() + 
                                             " | <strong>Name:</strong> " + dept.getName() + 
                                             " | <strong>Description:</strong> " + dept.getDescription() + "</p>");
                            }
                            results.append("</div></div>");
                        }
                        successCount++;
                    } catch (Exception e) {
                        results.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>Department data error: " + e.getMessage() + "</div>");
                    }
                    
                    // Test 4: Employee Data from MySQL
                    totalTests++;
                    results.append("<h5>4. Employee Data Test</h5>");
                    try {
                        EmployeeDAO employeeDAO = new EmployeeDAO();
                        List<Employee> employees = employeeDAO.getAll(null, null, true);
                        results.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>Employees loaded: " + employees.size() + " records</div>");
                        
                        if (!employees.isEmpty()) {
                            results.append("<div class='card mt-2'><div class='card-body'>");
                            results.append("<h6>Sample Employee Data:</h6>");
                            for (int i = 0; i < Math.min(3, employees.size()); i++) {
                                Employee emp = employees.get(i);
                                results.append("<p><strong>ID:</strong> " + emp.getId() + 
                                             " | <strong>Name:</strong> " + emp.getName() + 
                                             " | <strong>Email:</strong> " + emp.getEmail() + 
                                             " | <strong>Role:</strong> " + emp.getRole() + "</p>");
                            }
                            results.append("</div></div>");
                        }
                        successCount++;
                    } catch (Exception e) {
                        results.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>Employee data error: " + e.getMessage() + "</div>");
                    }
                    
                    // Test 5: Task Data from MySQL
                    totalTests++;
                    results.append("<h5>5. Task Data Test</h5>");
                    try {
                        TaskDAO taskDAO = new TaskDAO();
                        Map<String, Object> filters = new HashMap<>();
                        List<Task> tasks = taskDAO.getTasks(filters, 0, 10);
                        results.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>Tasks loaded: " + tasks.size() + " records</div>");
                        
                        if (!tasks.isEmpty()) {
                            results.append("<div class='card mt-2'><div class='card-body'>");
                            results.append("<h6>Sample Task Data:</h6>");
                            for (int i = 0; i < Math.min(3, tasks.size()); i++) {
                                Task task = tasks.get(i);
                                results.append("<p><strong>ID:</strong> " + task.getId() + 
                                             " | <strong>Title:</strong> " + task.getTitle() + 
                                             " | <strong>Status:</strong> " + task.getStatus() + 
                                             " | <strong>Priority:</strong> " + task.getPriority() + "</p>");
                            }
                            results.append("</div></div>");
                        }
                        successCount++;
                    } catch (Exception e) {
                        results.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>Task data error: " + e.getMessage() + "</div>");
                    }
                    
                    // Test 6: Task Count Statistics
                    totalTests++;
                    results.append("<h5>6. Task Statistics Test</h5>");
                    try {
                        TaskDAO taskDAO = new TaskDAO();
                        Map<String, Integer> taskCounts = taskDAO.getTaskCountByStatus(null, null);
                        results.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>Task statistics loaded successfully</div>");
                        
                        results.append("<div class='card mt-2'><div class='card-body'>");
                        results.append("<h6>Task Count by Status:</h6>");
                        for (Map.Entry<String, Integer> entry : taskCounts.entrySet()) {
                            results.append("<p><strong>" + entry.getKey() + ":</strong> " + entry.getValue() + " tasks</p>");
                        }
                        results.append("</div></div>");
                        successCount++;
                    } catch (Exception e) {
                        results.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>Task statistics error: " + e.getMessage() + "</div>");
                    }
                %>

                <!-- Test Results Summary -->
                <div class="row mb-4">
                    <div class="col-md-4">
                        <div class="card bg-<%= successCount == totalTests ? "success" : successCount > 0 ? "warning" : "danger" %> text-white">
                            <div class="card-body text-center">
                                <h2><%= successCount %>/<%= totalTests %></h2>
                                <p class="mb-0">Tests Passed</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card bg-info text-white">
                            <div class="card-body text-center">
                                <h2><%= (int)((double)successCount/totalTests * 100) %>%</h2>
                                <p class="mb-0">Success Rate</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card bg-secondary text-white">
                            <div class="card-body text-center">
                                <h2><%= new java.util.Date() %></h2>
                                <p class="mb-0">Test Time</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Detailed Results -->
                <%= results.toString() %>

                <!-- System Information -->
                <div class="mt-4">
                    <h5>System Information</h5>
                    <div class="card">
                        <div class="card-body">
                            <p><strong>Java Version:</strong> <%= System.getProperty("java.version") %></p>
                            <p><strong>Server Info:</strong> <%= application.getServerInfo() %></p>
                            <p><strong>Context Path:</strong> <%= request.getContextPath() %></p>
                            <p><strong>Database URL:</strong> jdbc:mysql://localhost:3306/task_management</p>
                            <p><strong>MySQL JAR:</strong> src/main/webapp/WEB-INF/lib/mysql-connector-java-8.0.28.jar</p>
                        </div>
                    </div>
                </div>

                <!-- Navigation -->
                <div class="mt-4">
                    <h5>Test Other Pages</h5>
                    <div class="btn-group" role="group">
                        <a href="<%= request.getContextPath() %>/" class="btn btn-outline-primary">Home</a>
                        <a href="<%= request.getContextPath() %>/dashboard.jsp" class="btn btn-outline-success">Dashboard JSP</a>
                        <a href="<%= request.getContextPath() %>/tasks.jsp" class="btn btn-outline-success">Tasks JSP</a>
                        <a href="<%= request.getContextPath() %>/task-create.jsp" class="btn btn-outline-success">Create Task JSP</a>
                        <a href="<%= request.getContextPath() %>/test" class="btn btn-outline-secondary">Servlet Test</a>
                    </div>
                </div>

                <% if (successCount == totalTests) { %>
                    <div class="alert alert-success mt-4">
                        <h5><i class="fas fa-check-circle me-2"></i>All Tests Passed!</h5>
                        <p class="mb-0">Your JSP pages are properly connected to MySQL database through DAO and Model classes. 
                        The complete data flow is working: <strong>MySQL → DAO → Model → JSP</strong></p>
                    </div>
                <% } else { %>
                    <div class="alert alert-warning mt-4">
                        <h5><i class="fas fa-exclamation-triangle me-2"></i>Some Tests Failed</h5>
                        <p class="mb-0">Please check the database connection and ensure MySQL is running with the task_management database.</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>