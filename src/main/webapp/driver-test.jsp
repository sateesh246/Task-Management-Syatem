<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MySQL Driver Test</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-4">
        <div class="card">
            <div class="card-header bg-primary text-white">
                <h4><i class="fas fa-database me-2"></i>MySQL Driver Loading Test</h4>
            </div>
            <div class="card-body">
                <%
                    StringBuilder results = new StringBuilder();
                    boolean driverLoaded = false;
                    
                    // Test 1: Try to load MySQL driver explicitly
                    results.append("<h5>1. MySQL Driver Loading Test</h5>");
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        results.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>MySQL Driver loaded successfully: com.mysql.cj.jdbc.Driver</div>");
                        driverLoaded = true;
                    } catch (ClassNotFoundException e) {
                        results.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>MySQL Driver NOT found: " + e.getMessage() + "</div>");
                    }
                    
                    // Test 2: Try old driver as fallback
                    if (!driverLoaded) {
                        results.append("<h5>2. Fallback Driver Test</h5>");
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            results.append("<div class='alert alert-warning'><i class='fas fa-exclamation-triangle me-2'></i>Old MySQL Driver loaded: com.mysql.jdbc.Driver</div>");
                            driverLoaded = true;
                        } catch (ClassNotFoundException e) {
                            results.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>Old MySQL Driver also NOT found: " + e.getMessage() + "</div>");
                        }
                    }
                    
                    // Test 3: Check available drivers
                    results.append("<h5>3. Available JDBC Drivers</h5>");
                    results.append("<div class='card'><div class='card-body'>");
                    java.util.Enumeration<java.sql.Driver> drivers = java.sql.DriverManager.getDrivers();
                    int driverCount = 0;
                    while (drivers.hasMoreElements()) {
                        java.sql.Driver driver = drivers.nextElement();
                        results.append("<p><strong>Driver " + (++driverCount) + ":</strong> " + driver.getClass().getName() + "</p>");
                    }
                    if (driverCount == 0) {
                        results.append("<p class='text-muted'>No JDBC drivers found in DriverManager</p>");
                    }
                    results.append("</div></div>");
                    
                    // Test 4: Check classpath for MySQL JARs
                    results.append("<h5>4. Classpath Analysis</h5>");
                    results.append("<div class='card'><div class='card-body'>");
                    String classpath = System.getProperty("java.class.path");
                    if (classpath.contains("mysql")) {
                        results.append("<div class='alert alert-success'>MySQL JAR found in classpath</div>");
                    } else {
                        results.append("<div class='alert alert-warning'>MySQL JAR not found in system classpath</div>");
                    }
                    results.append("<small class='text-muted'>Note: Web application JARs are loaded separately from system classpath</small>");
                    results.append("</div></div>");
                    
                    // Test 5: Try database connection
                    if (driverLoaded) {
                        results.append("<h5>5. Database Connection Test</h5>");
                        try {
                            java.sql.Connection conn = java.sql.DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/task_management",
                                "root", 
                                "root"
                            );
                            if (conn != null && !conn.isClosed()) {
                                results.append("<div class='alert alert-success'><i class='fas fa-check me-2'></i>Database connection: SUCCESS</div>");
                                conn.close();
                            } else {
                                results.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>Database connection: FAILED (null or closed)</div>");
                            }
                        } catch (java.sql.SQLException e) {
                            results.append("<div class='alert alert-danger'><i class='fas fa-times me-2'></i>Database connection error: " + e.getMessage() + "</div>");
                        }
                    }
                %>

                <!-- Test Results -->
                <%= results.toString() %>

                <!-- System Information -->
                <div class="mt-4">
                    <h5>System Information</h5>
                    <div class="card">
                        <div class="card-body">
                            <p><strong>Java Version:</strong> <%= System.getProperty("java.version") %></p>
                            <p><strong>Server Info:</strong> <%= application.getServerInfo() %></p>
                            <p><strong>Context Path:</strong> <%= request.getContextPath() %></p>
                            <p><strong>Web App Path:</strong> <%= application.getRealPath("/") %></p>
                        </div>
                    </div>
                </div>

                <!-- Navigation -->
                <div class="mt-4">
                    <a href="<%= request.getContextPath() %>/" class="btn btn-primary">Back to Home</a>
                    <a href="<%= request.getContextPath() %>/simple-test.jsp" class="btn btn-success">Full Database Test</a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>