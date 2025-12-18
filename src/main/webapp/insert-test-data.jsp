<%@page import="java.sql.*"%>
<%@page import="com.taskmanagement.config.DatabaseConfig"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Insert Test Data - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <div class="row">
            <div class="col-12">
                <h2><i class="fas fa-database me-2"></i>Insert Test Data</h2>
                
                <%
                    boolean dataInserted = false;
                    String message = "";
                    
                    if ("true".equals(request.getParameter("insert"))) {
                        try (Connection conn = DatabaseConfig.getConnection()) {
                            // Check if data already exists
                            PreparedStatement checkStmt = conn.prepareStatement("SELECT COUNT(*) FROM tasks");
                            ResultSet rs = checkStmt.executeQuery();
                            rs.next();
                            int taskCount = rs.getInt(1);
                            
                            if (taskCount > 0) {
                                message = "Test data already exists. Found " + taskCount + " tasks in database.";
                            } else {
                                // Insert departments
                                String[] deptInserts = {
                                    "INSERT INTO departments (name, description) VALUES ('Engineering', 'Software development and technical operations')",
                                    "INSERT INTO departments (name, description) VALUES ('Marketing', 'Marketing and customer outreach')",
                                    "INSERT INTO departments (name, description) VALUES ('Sales', 'Sales and business development')",
                                    "INSERT INTO departments (name, description) VALUES ('HR', 'Human resources and administration')"
                                };
                                
                                for (String sql : deptInserts) {
                                    PreparedStatement stmt = conn.prepareStatement(sql);
                                    stmt.executeUpdate();
                                    stmt.close();
                                }
                                
                                // Insert employees
                                String[] empInserts = {
                                    "INSERT INTO employees (name, email, password, role, department_id) VALUES ('John Admin', 'admin@company.com', 'password123', 'ADMIN', 1)",
                                    "INSERT INTO employees (name, email, password, role, department_id) VALUES ('Alice Manager', 'alice.manager@company.com', 'password123', 'MANAGER', 1)",
                                    "INSERT INTO employees (name, email, password, role, department_id) VALUES ('Tom Employee', 'tom@company.com', 'password123', 'EMPLOYEE', 1)",
                                    "INSERT INTO employees (name, email, password, role, department_id) VALUES ('Lisa Employee', 'lisa@company.com', 'password123', 'EMPLOYEE', 2)",
                                    "INSERT INTO employees (name, email, password, role, department_id) VALUES ('Mark Employee', 'mark@company.com', 'password123', 'EMPLOYEE', 3)"
                                };
                                
                                for (String sql : empInserts) {
                                    PreparedStatement stmt = conn.prepareStatement(sql);
                                    stmt.executeUpdate();
                                    stmt.close();
                                }
                                
                                // Insert tasks with different statuses and priorities
                                String[] taskInserts = {
                                    "INSERT INTO tasks (title, description, priority, status, due_date, department_id, created_by) VALUES ('Setup CI/CD Pipeline', 'Configure automated build and deployment pipeline', 'HIGH', 'IN_PROGRESS', '2024-12-25', 1, 2)",
                                    "INSERT INTO tasks (title, description, priority, status, due_date, department_id, created_by) VALUES ('Database Optimization', 'Optimize slow queries and add proper indexes', 'MEDIUM', 'PENDING', '2024-12-30', 1, 2)",
                                    "INSERT INTO tasks (title, description, priority, status, due_date, department_id, created_by) VALUES ('API Documentation', 'Complete REST API documentation', 'LOW', 'UNDER_REVIEW', '2024-12-28', 1, 2)",
                                    "INSERT INTO tasks (title, description, priority, status, due_date, department_id, created_by) VALUES ('Security Audit', 'Perform security vulnerability assessment', 'HIGH', 'PENDING', '2024-12-22', 1, 2)",
                                    "INSERT INTO tasks (title, description, priority, status, due_date, department_id, created_by) VALUES ('Campaign Launch', 'Launch Q1 marketing campaign', 'HIGH', 'IN_PROGRESS', '2024-12-31', 2, 2)",
                                    "INSERT INTO tasks (title, description, priority, status, due_date, department_id, created_by) VALUES ('Social Media Content', 'Create social media content', 'MEDIUM', 'COMPLETED', '2024-12-18', 2, 2)",
                                    "INSERT INTO tasks (title, description, priority, status, due_date, department_id, created_by) VALUES ('Market Research', 'Conduct competitor analysis', 'MEDIUM', 'UNDER_REVIEW', '2024-12-27', 2, 2)",
                                    "INSERT INTO tasks (title, description, priority, status, due_date, department_id, created_by) VALUES ('Client Presentation', 'Prepare presentation for major client', 'HIGH', 'IN_PROGRESS', '2024-12-21', 3, 2)",
                                    "INSERT INTO tasks (title, description, priority, status, due_date, department_id, created_by) VALUES ('Lead Generation', 'Generate qualified leads', 'MEDIUM', 'PENDING', '2024-12-29', 3, 2)",
                                    "INSERT INTO tasks (title, description, priority, status, due_date, department_id, created_by) VALUES ('Employee Onboarding', 'Streamline onboarding process', 'HIGH', 'IN_PROGRESS', '2024-12-30', 4, 2)"
                                };
                                
                                for (String sql : taskInserts) {
                                    PreparedStatement stmt = conn.prepareStatement(sql);
                                    stmt.executeUpdate();
                                    stmt.close();
                                }
                                
                                dataInserted = true;
                                message = "Test data inserted successfully! Added 4 departments, 5 employees, and 10 tasks.";
                            }
                            
                        } catch (Exception e) {
                            message = "Error inserting test data: " + e.getMessage();
                            e.printStackTrace();
                        }
                    }
                %>
                
                <% if (dataInserted) { %>
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle me-2"></i>
                        <%= message %>
                    </div>
                <% } else if (!message.isEmpty()) { %>
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i>
                        <%= message %>
                    </div>
                <% } %>
                
                <div class="card">
                    <div class="card-header">
                        <h5><i class="fas fa-plus me-2"></i>Insert Test Data</h5>
                    </div>
                    <div class="card-body">
                        <p>This will insert sample data into the database including:</p>
                        <ul>
                            <li>4 Departments (Engineering, Marketing, Sales, HR)</li>
                            <li>5 Employees (1 Admin, 1 Manager, 3 Employees)</li>
                            <li>10 Tasks with various statuses and priorities</li>
                        </ul>
                        
                        <a href="insert-test-data.jsp?insert=true" class="btn btn-primary">
                            <i class="fas fa-database me-1"></i>Insert Test Data
                        </a>
                        
                        <a href="debug-tasks.jsp" class="btn btn-success ms-2">
                            <i class="fas fa-bug me-1"></i>Debug Tasks
                        </a>
                        
                        <a href="tasks.jsp" class="btn btn-secondary ms-2">
                            <i class="fas fa-tasks me-1"></i>View Tasks
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>