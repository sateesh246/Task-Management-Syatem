<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Enterprise Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/login.css" rel="stylesheet">
</head>
<body class="login-page">
    <div class="container-fluid h-100">
        <div class="row h-100">
            <!-- Left side - Branding -->
            <div class="col-lg-6 d-none d-lg-flex login-brand-section">
                <div class="d-flex flex-column justify-content-center align-items-center text-white">
                    <div class="brand-logo mb-4">
                        <i class="fas fa-tasks fa-5x"></i>
                    </div>
                    <h1 class="brand-title">Enterprise Task Management</h1>
                    <p class="brand-subtitle">Streamline your workflow, boost productivity</p>
                    <div class="feature-list mt-4">
                        <div class="feature-item">
                            <i class="fas fa-check-circle me-2"></i>
                            Role-based access control
                        </div>
                        <div class="feature-item">
                            <i class="fas fa-check-circle me-2"></i>
                            Advanced workflow management
                        </div>
                        <div class="feature-item">
                            <i class="fas fa-check-circle me-2"></i>
                            Real-time collaboration
                        </div>
                        <div class="feature-item">
                            <i class="fas fa-check-circle me-2"></i>
                            Comprehensive reporting
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Right side - Login Form -->
            <div class="col-lg-6 d-flex align-items-center justify-content-center">
                <div class="login-form-container">
                    <div class="text-center mb-4">
                        <h2 class="login-title">Welcome Back</h2>
                        <p class="login-subtitle">Please sign in to your account</p>
                    </div>
                    
                    <!-- Success Message -->
                    <c:if test="${not empty param.message}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fas fa-check-circle me-2"></i>
                            ${param.message}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    
                    <!-- Error Message -->
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i>
                            ${errorMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    
                    <form method="post" action="${pageContext.request.contextPath}/login" class="login-form">
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
                                       value="${email}" 
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
                                <button class="btn btn-outline-secondary" 
                                        type="button" 
                                        id="togglePassword">
                                    <i class="fas fa-eye"></i>
                                </button>
                            </div>
                        </div>
                        
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="rememberMe">
                            <label class="form-check-label" for="rememberMe">
                                Remember me
                            </label>
                        </div>
                        
                        <button type="submit" class="btn btn-primary btn-login w-100">
                            <i class="fas fa-sign-in-alt me-2"></i>
                            Sign In
                        </button>
                    </form>
                    
                    <!-- Demo Credentials -->
                    <div class="demo-credentials mt-4">
                        <h6 class="text-muted mb-3">Demo Credentials:</h6>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="demo-card">
                                    <strong>Admin</strong><br>
                                    <small>admin@company.com</small><br>
                                    <small>password123</small>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="demo-card">
                                    <strong>Manager</strong><br>
                                    <small>alice.manager@company.com</small><br>
                                    <small>password123</small>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="demo-card">
                                    <strong>Employee</strong><br>
                                    <small>tom@company.com</small><br>
                                    <small>password123</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Toggle password visibility
        document.getElementById('togglePassword').addEventListener('click', function() {
            const passwordField = document.getElementById('password');
            const toggleIcon = this.querySelector('i');
            
            if (passwordField.type === 'password') {
                passwordField.type = 'text';
                toggleIcon.classList.remove('fa-eye');
                toggleIcon.classList.add('fa-eye-slash');
            } else {
                passwordField.type = 'password';
                toggleIcon.classList.remove('fa-eye-slash');
                toggleIcon.classList.add('fa-eye');
            }
        });
        
        // Auto-fill demo credentials
        document.querySelectorAll('.demo-card').forEach(card => {
            card.addEventListener('click', function() {
                const email = this.querySelector('small').textContent;
                document.getElementById('email').value = email;
                document.getElementById('password').value = 'password123';
            });
        });
        
        // Form validation
        document.querySelector('.login-form').addEventListener('submit', function(e) {
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            
            if (!email || !password) {
                e.preventDefault();
                alert('Please fill in all fields');
                return false;
            }
            
            // Show loading state
            const submitBtn = this.querySelector('button[type="submit"]');
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Signing In...';
            submitBtn.disabled = true;
        });
    </script>
</body>
</html>