<%@page import="com.taskmanagement.dao.EmployeeDAO"%>
<%@page import="com.taskmanagement.model.Employee"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <%
        String errorMessage = "";
        String email = "";
        
        // Handle login form submission
        if ("POST".equals(request.getMethod())) {
            email = request.getParameter("email");
            String password = request.getParameter("password");
            
            if (email != null && password != null && !email.trim().isEmpty() && !password.trim().isEmpty()) {
                try {
                    EmployeeDAO employeeDAO = new EmployeeDAO();
                               Employee employee = employeeDAO.authenticate(email.trim(), password);
                    if (employee != null && employee.isActive()) {
                        // Login successful - store user in session
                        session.setAttribute("loggedInUser", employee);
                        session.setAttribute("userRole", employee.getRole().toString());
                        session.setAttribute("userId", employee.getId());
                        session.setAttribute("userName", employee.getName());
                        
                        // Redirect based on role
                        String redirectUrl = "";
                        switch (employee.getRole()) {
                            case ADMIN:
                                redirectUrl = request.getContextPath() + "/admin-dashboard.jsp";
                                break;
                            case MANAGER:
                                redirectUrl = request.getContextPath() + "/manager-dashboard.jsp";
                                break;
                            case EMPLOYEE:
                                redirectUrl = request.getContextPath() + "/employee-dashboard.jsp";
                                break;
                            default:
                                redirectUrl = request.getContextPath() + "/dashboard.jsp";
                        }
                        response.sendRedirect(redirectUrl);
                        return;
                    } else {
                        errorMessage = "Invalid email or password. Please try again.";
                    }
                } catch (Exception e) {
                    errorMessage = "Login error: " + e.getMessage();
                    e.printStackTrace();
                }
            } else {
                errorMessage = "Please enter both email and password.";
            }
        }
    %>

    <div class="container-fluid vh-100 d-flex align-items-center justify-content-center">
        <div class="row w-100">
            <div class="col-md-6 offset-md-3 col-lg-4 offset-lg-4">
                <div class="card shadow-lg">
                    <div class="card-body p-5">
                        <div class="text-center mb-4">
                            <i class="fas fa-tasks fa-3x text-primary mb-3"></i>
                            <h2 class="card-title">Task Management System</h2>
                            <p class="text-muted">Please sign in to continue</p>
                        </div>
                        
                        <% if (!errorMessage.isEmpty()) { %>
                            <div class="alert alert-danger" role="alert">
                                <i class="fas fa-exclamation-circle me-2"></i>
                                <%= errorMessage %>
                            </div>
                        <% } %>
                        
                        <form method="post" action="simple-login.jsp">
                            <div class="mb-3">
                                <label for="email" class="form-label">Email Address</label>
                                <div class="input-group">
                                    <span class="input-group-text">
                                        <i class="fas fa-envelope"></i>
                                    </span>
                                    <input type="email" 
                                           class="form-control" 
                                           id="email" 
                                           name="email" 
                                           value="<%= email %>" 
                                           placeholder="Enter your email"
                                           required>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="password" class="form-label">Password</label>
                                <div class="input-group">
                                    <span class="input-group-text">
                                        <i class="fas fa-lock"></i>
                                    </span>
                                    <input type="password" 
                                           class="form-control" 
                                           id="password" 
                                           name="password" 
                                           placeholder="Enter your password"
                                           required>
                                </div>
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-100 mb-3">
                                <i class="fas fa-sign-in-alt me-2"></i>
                                Sign In
                            </button>
                        </form>
                        
                        <!-- Demo Credentials -->
                        <div class="mt-4">
                            <h6 class="text-muted mb-3">Demo Credentials (Click to use):</h6>
                            <div class="row g-2">
                                <div class="col-12">
                                    <div class="card bg-light demo-card" style="cursor: pointer;" onclick="fillCredentials('admin@company.com')">
                                        <div class="card-body py-2">
                                            <strong class="text-danger">Admin:</strong> admin@company.com / password123
                                        </div>
                                    </div>
                                </div>
                                <div class="col-12">
                                    <div class="card bg-light demo-card" style="cursor: pointer;" onclick="fillCredentials('alice.manager@company.com')">
                                        <div class="card-body py-2">
                                            <strong class="text-warning">Manager:</strong> alice.manager@company.com / password123
                                        </div>
                                    </div>
                                </div>
                                <div class="col-12">
                                    <div class="card bg-light demo-card" style="cursor: pointer;" onclick="fillCredentials('tom@company.com')">
                                        <div class="card-body py-2">
                                            <strong class="text-success">Employee:</strong> tom@company.com / password123
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="text-center mt-4">
                            <a href="<%= request.getContextPath() %>/" class="btn btn-outline-secondary">
                                <i class="fas fa-home me-1"></i>Back to Home
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function fillCredentials(email) {
            document.getElementById('email').value = email;
            document.getElementById('password').value = 'password123';
        }
    </script>
</body>
</html>