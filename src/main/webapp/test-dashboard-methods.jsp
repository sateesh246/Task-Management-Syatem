<%@page import="com.taskmanagement.dao.TaskDAO"%>
<%@page import="com.taskmanagement.dao.EmployeeDAO"%>
<%@page import="com.taskmanagement.dao.WorkSessionDAO"%>
<%@page import="com.taskmanagement.dao.TaskActivityLogDAO"%>
<%@page import="com.taskmanagement.model.Task"%>
<%@page import="com.taskmanagement.model.Employee"%>
<%@page import="com.taskmanagement.model.WorkSession"%>
<%@page import="com.taskmanagement.model.TaskActivityLog"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard Methods Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test-section { margin: 20px 0; padding: 15px; border: 1px solid #ccc; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <h1>Dashboard Methods Test</h1>
    
    <%
        try {
            // Initialize DAOs
            TaskDAO taskDAO = new TaskDAO();
            EmployeeDAO employeeDAO = new EmployeeDAO();
            WorkSessionDAO workSessionDAO = new WorkSessionDAO();
            TaskActivityLogDAO activityLogDAO = new TaskActivityLogDAO();
            
            out.println("<div class='test-section'>");
            out.println("<h2>DAO Initialization</h2>");
            out.println("<p class='success'>✅ All DAOs initialized successfully</p>");
            out.println("</div>");
            
            // Test TaskDAO.getTasksAssignedToEmployee
            out.println("<div class='test-section'>");
            out.println("<h2>Test TaskDAO.getTasksAssignedToEmployee</h2>");
            try {
                List<Task> tasks = taskDAO.getTasksAssignedToEmployee(1, 0, 10);
                out.println("<p class='success'>✅ Method exists and callable</p>");
                out.println("<p>Returned " + tasks.size() + " tasks for employee ID 1</p>");
            } catch (Exception e) {
                out.println("<p class='error'>❌ Error: " + e.getMessage() + "</p>");
            }
            out.println("</div>");
            
            // Test WorkSessionDAO.getSessionsForEmployee
            out.println("<div class='test-section'>");
            out.println("<h2>Test WorkSessionDAO.getSessionsForEmployee</h2>");
            try {
                List<WorkSession> sessions = workSessionDAO.getSessionsForEmployee(1, 10);
                out.println("<p class='success'>✅ Method exists and callable</p>");
                out.println("<p>Returned " + sessions.size() + " sessions for employee ID 1</p>");
            } catch (Exception e) {
                out.println("<p class='error'>❌ Error: " + e.getMessage() + "</p>");
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
            
            // Test TaskActivityLogDAO.getActivityLogForEmployee
            out.println("<div class='test-section'>");
            out.println("<h2>Test TaskActivityLogDAO.getActivityLogForEmployee</h2>");
            try {
                List<TaskActivityLog> activity = activityLogDAO.getActivityLogForEmployee(1, 10);
                out.println("<p class='success'>✅ Method exists and callable</p>");
                out.println("<p>Returned " + activity.size() + " activity logs for employee ID 1</p>");
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
            
        } catch (Exception e) {
            out.println("<div class='test-section'>");
            out.println("<h2>General Error</h2>");
            out.println("<p class='error'>❌ " + e.getMessage() + "</p>");
            out.println("</div>");
        }
    %>
    
    <div class='test-section'>
        <h2>Next Steps</h2>
        <p>If all methods show ✅, then the DAO methods are working correctly.</p>
        <p>If you see ❌ errors, those need to be fixed first.</p>
        <p><a href="employee-dashboard.jsp">Test Employee Dashboard</a></p>
        <p><a href="manager-dashboard.jsp">Test Manager Dashboard</a></p>
        <p><a href="admin-dashboard.jsp">Test Admin Dashboard</a></p>
    </div>
</body>
</html>