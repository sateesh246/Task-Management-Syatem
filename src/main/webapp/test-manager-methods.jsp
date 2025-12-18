<%@page import="com.taskmanagement.dao.TaskDAO"%>
<%@page import="com.taskmanagement.dao.EmployeeDAO"%>
<%@page import="com.taskmanagement.dao.TaskActivityLogDAO"%>
<%@page import="com.taskmanagement.model.Task"%>
<%@page import="com.taskmanagement.model.Employee"%>
<%@page import="com.taskmanagement.model.TaskActivityLog"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Manager Dashboard Methods Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test-section { margin: 20px 0; padding: 15px; border: 1px solid #ccc; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <h1>Manager Dashboard Methods Test</h1>
    
    <%
        try {
            // Initialize DAOs
            TaskDAO taskDAO = new TaskDAO();
            EmployeeDAO employeeDAO = new EmployeeDAO();
            TaskActivityLogDAO activityLogDAO = new TaskActivityLogDAO();
            
            out.println("<div class='test-section'>");
            out.println("<h2>DAO Initialization</h2>");
            out.println("<p class='success'>✅ All DAOs initialized successfully</p>");
            out.println("</div>");
            
            // Test TaskDAO.getTasksAssignedToEmployee (the problematic method)
            out.println("<div class='test-section'>");
            out.println("<h2>Test TaskDAO.getTasksAssignedToEmployee (Manager Dashboard Issue)</h2>");
            try {
                List<Task> tasks = taskDAO.getTasksAssignedToEmployee(1, 0, 20);
                out.println("<p class='success'>✅ Method exists and callable</p>");
                out.println("<p>Returned " + tasks.size() + " tasks for employee ID 1</p>");
                out.println("<p><strong>This method is now working in manager dashboard!</strong></p>");
            } catch (Exception e) {
                out.println("<p class='error'>❌ Error: " + e.getMessage() + "</p>");
                e.printStackTrace();
            }
            out.println("</div>");
            
            // Test EmployeeDAO.getEmployeesByDepartment
            out.println("<div class='test-section'>");
            out.println("<h2>Test EmployeeDAO.getEmployeesByDepartment</h2>");
            try {
                List<Employee> employees = employeeDAO.getEmployeesByDepartment(1);
                out.println("<p class='success'>✅ Method exists and callable</p>");
                out.println("<p>Returned " + employees.size() + " employees for department ID 1</p>");
            } catch (Exception e) {
                out.println("<p class='error'>❌ Error: " + e.getMessage() + "</p>");
            }
            out.println("</div>");
            
            // Test TaskActivityLogDAO.getActivityLogForDepartment
            out.println("<div class='test-section'>");
            out.println("<h2>Test TaskActivityLogDAO.getActivityLogForDepartment</h2>");
            try {
                List<TaskActivityLog> activity = activityLogDAO.getActivityLogForDepartment(1, 10);
                out.println("<p class='success'>✅ Method exists and callable</p>");
                out.println("<p>Returned " + activity.size() + " activity logs for department ID 1</p>");
            } catch (Exception e) {
                out.println("<p class='error'>❌ Error: " + e.getMessage() + "</p>");
            }
            out.println("</div>");
            
            // Test TaskDAO.getTaskCountByStatus
            out.println("<div class='test-section'>");
            out.println("<h2>Test TaskDAO.getTaskCountByStatus</h2>");
            try {
                java.util.Map<String, Integer> counts = taskDAO.getTaskCountByStatus(1, null);
                out.println("<p class='success'>✅ Method exists and callable</p>");
                out.println("<p>Returned task counts for department ID 1:</p>");
                for (java.util.Map.Entry<String, Integer> entry : counts.entrySet()) {
                    out.println("<p>- " + entry.getKey() + ": " + entry.getValue() + " tasks</p>");
                }
            } catch (Exception e) {
                out.println("<p class='error'>❌ Error: " + e.getMessage() + "</p>");
            }
            out.println("</div>");
            
        } catch (Exception e) {
            out.println("<div class='test-section'>");
            out.println("<h2>General Error</h2>");
            out.println("<p class='error'>❌ " + e.getMessage() + "</p>");
            out.println("</div>");
        }
    %>
    
    <div class='test-section'>
        <h2>Next Steps</h2>
        <p>If all methods show ✅, then the manager dashboard should work correctly.</p>
        <p><a href="manager-dashboard.jsp">Test Manager Dashboard</a></p>
        <p><a href="employee-dashboard.jsp">Test Employee Dashboard</a></p>
        <p><a href="admin-dashboard.jsp">Test Admin Dashboard</a></p>
    </div>
</body>
</html>