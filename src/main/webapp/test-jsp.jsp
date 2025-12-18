<%@page import="com.taskmanagement.dao.TaskDAO"%>
<%@page import="com.taskmanagement.dao.EmployeeDAO"%>
<%@page import="com.taskmanagement.dao.DepartmentDAO"%>
<%@page import="com.taskmanagement.model.Task"%>
<%@page import="com.taskmanagement.model.Employee"%>
<%@page import="com.taskmanagement.model.Department"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JSP Test - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <div class="card">
            <div class="card-header">
                <h4><i class="fas fa-vial me-2"></i>JSP Direct Access Test</h4>
            </div>
            <div class="card-body">
                <div class="alert alert-info">
                    <i class="fas fa-info-circle me-2"></i>
                    Testing direct Java class imports and DAO access in JSP
                </div>

                <%
                    StringBuilder testResults = new StringBuilder();
                    int testsPassed = 0;
                    int totalTests = 0;
                    
                    // Test 1: TaskDAO
                    totalTests++;
                    try {
                        TaskDAO taskDAO = new TaskDAO();
                        testResults.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>TaskDAO instantiation: SUCCESS</div>");
                        testsPassed++;
                        
                        // Try to get tasks
                        try {
                            java.util.Map<String, Object> filters = new java.util.HashMap<>();
                            List<Task> tasks = taskDAO.getTasks(filters, 0, 5);
                            testResults.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>TaskDAO.getTasks(): SUCCESS - Found " + tasks.size() + " tasks</div>");
                            testsPassed++;
                            totalTests++;
                        } catch (Exception e) {
                            testResults.append("<div class='alert alert-warning'><i class='fas fa-exclamation-triangle me-2'></i>TaskDAO.getTasks(): ERROR - " + e.getMessage() + "</div>");
                            totalTests++;
                        }
                    } catch (Exception e) {
                        testResults.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>TaskDAO instantiation: ERROR - " + e.getMessage() + "</div>");
                        totalTests++;
                    }
                    
                    // Test 2: EmployeeDAO
                    totalTests++;
                    try {
                        EmployeeDAO employeeDAO = new EmployeeDAO();
                        testResults.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>EmployeeDAO instantiation: SUCCESS</div>");
                        testsPassed++;
                        
                        // Try to get employees
                        try {
                            List<Employee> employees = employeeDAO.getAll(null, null, true);
                            testResults.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>EmployeeDAO.getAll(): SUCCESS - Found " + employees.size() + " employees</div>");
                            testsPassed++;
                            totalTests++;
                        } catch (Exception e) {
                            testResults.append("<div class='alert alert-warning'><i class='fas fa-exclamation-triangle me-2'></i>EmployeeDAO.getAll(): ERROR - " + e.getMessage() + "</div>");
                            totalTests++;
                        }
                    } catch (Exception e) {
                        testResults.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>EmployeeDAO instantiation: ERROR - " + e.getMessage() + "</div>");
                        totalTests++;
                    }
                    
                    // Test 3: DepartmentDAO
                    totalTests++;
                    try {
                        DepartmentDAO departmentDAO = new DepartmentDAO();
                        testResults.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>DepartmentDAO instantiation: SUCCESS</div>");
                        testsPassed++;
                        
                        // Try to get departments
                        try {
                            List<Department> departments = departmentDAO.getAll();
                            testResults.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>DepartmentDAO.getAll(): SUCCESS - Found " + departments.size() + " departments</div>");
                            testsPassed++;
                            totalTests++;
                        } catch (Exception e) {
                            testResults.append("<div class='alert alert-warning'><i class='fas fa-exclamation-triangle me-2'></i>DepartmentDAO.getAll(): ERROR - " + e.getMessage() + "</div>");
                            totalTests++;
                        }
                    } catch (Exception e) {
                        testResults.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>DepartmentDAO instantiation: ERROR - " + e.getMessage() + "</div>");
                        totalTests++;
                    }
                %>

                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="card bg-primary text-white">
                            <div class="card-body text-center">
                                <h3><%= testsPassed %></h3>
                                <p class="mb-0">Tests Passed</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card bg-secondary text-white">
                            <div class="card-body text-center">
                                <h3><%= totalTests %></h3>
                                <p class="mb-0">Total Tests</p>
                            </div>
                        </div>
                    </div>
                </div>

                <h5>Test Results:</h5>
                <%= testResults.toString() %>

                <div class="mt-4">
                    <h5>System Information:</h5>
                    <ul class="list-group">
                        <li class="list-group-item">
                            <strong>Java Version:</strong> <%= System.getProperty("java.version") %>
                        </li>
                        <li class="list-group-item">
                            <strong>Server Info:</strong> <%= application.getServerInfo() %>
                        </li>
                        <li class="list-group-item">
                            <strong>Context Path:</strong> <%= request.getContextPath() %>
                        </li>
                        <li class="list-group-item">
                            <strong>Current Time:</strong> <%= new java.util.Date() %>
                        </li>
                    </ul>
                </div>

                <div class="mt-4">
                    <h5>Navigation Links:</h5>
                    <div class="btn-group" role="group">
                        <a href="<%= request.getContextPath() %>/" class="btn btn-outline-primary">Home</a>
                        <a href="<%= request.getContextPath() %>/dashboard.jsp" class="btn btn-outline-primary">Dashboard JSP</a>
                        <a href="<%= request.getContextPath() %>/tasks.jsp" class="btn btn-outline-primary">Tasks JSP</a>
                        <a href="<%= request.getContextPath() %>/task-create.jsp" class="btn btn-outline-primary">Create Task JSP</a>
                        <a href="<%= request.getContextPath() %>/test" class="btn btn-outline-secondary">System Test</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>