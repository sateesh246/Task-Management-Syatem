<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enterprise Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container-fluid vh-100 d-flex align-items-center justify-content-center">
        <div class="row w-100">
            <div class="col-md-6 offset-md-3">
                <div class="card shadow-lg">
                    <div class="card-body text-center p-5">
                        <div class="mb-4">
                            <i class="fas fa-tasks fa-4x text-primary mb-3"></i>
                            <h1 class="display-4 fw-bold text-primary">Task Management System</h1>
                            <p class="lead text-muted">Enterprise-grade task and project management solution</p>
                        </div>
                        
                        <div class="d-grid gap-3">
                            <div class="row">
                                <div class="col-md-4">
                                    <h6 class="text-center mb-3">Servlet-based</h6>
                                    <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-primary btn-lg w-100 mb-2">
                                        <i class="fas fa-tachometer-alt me-2"></i>Dashboard
                                    </a>
                                    <a href="<%= request.getContextPath() %>/tasks" class="btn btn-outline-primary btn-lg w-100 mb-2">
                                        <i class="fas fa-tasks me-2"></i>Tasks
                                    </a>
                                    <a href="<%= request.getContextPath() %>/test" class="btn btn-outline-secondary w-100">
                                        <i class="fas fa-cog me-2"></i>System Status
                                    </a>
                                </div>
                                <div class="col-md-4">
                                    <h6 class="text-center mb-3">JSP Direct Access</h6>
                                    <a href="<%= request.getContextPath() %>/dashboard.jsp" class="btn btn-warning btn-lg w-100 mb-2">
                                        <i class="fas fa-tachometer-alt me-2"></i>Dashboard
                                    </a>
                                    <a href="<%= request.getContextPath() %>/tasks.jsp" class="btn btn-outline-warning btn-lg w-100 mb-2">
                                        <i class="fas fa-tasks me-2"></i>Tasks
                                    </a>
                                    <a href="<%= request.getContextPath() %>/simple-test.jsp" class="btn btn-outline-secondary w-100">
                                        <i class="fas fa-database me-2"></i>DB Test
                                    </a>
                                </div>
                                <div class="col-md-4">
                                    <h6 class="text-center mb-3">Static (HTML-only)</h6>
                                    <a href="<%= request.getContextPath() %>/static-dashboard.html" class="btn btn-success btn-lg w-100 mb-2">
                                        <i class="fas fa-tachometer-alt me-2"></i>Dashboard
                                    </a>
                                    <a href="<%= request.getContextPath() %>/static-tasks.html" class="btn btn-outline-success btn-lg w-100 mb-2">
                                        <i class="fas fa-tasks me-2"></i>Tasks
                                    </a>
                                    <a href="<%= request.getContextPath() %>/login.jsp" class="btn btn-outline-secondary w-100">
                                        <i class="fas fa-file-alt me-2"></i>Other JSPs
                                    </a>
                                </div>
                            </div>
                            
                            <div class="row mt-4">
                                <div class="col-md-4">
                                    <div class="text-center">
                                        <i class="fas fa-users fa-2x text-info mb-2"></i>
                                        <h6>Team Management</h6>
                                        <small class="text-muted">Manage teams and assignments</small>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="text-center">
                                        <i class="fas fa-chart-line fa-2x text-success mb-2"></i>
                                        <h6>Progress Tracking</h6>
                                        <small class="text-muted">Real-time project insights</small>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="text-center">
                                        <i class="fas fa-bell fa-2x text-warning mb-2"></i>
                                        <h6>Notifications</h6>
                                        <small class="text-muted">Stay updated on tasks</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <hr class="my-4">
                        
                        <!-- Test Pages -->
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <a href="<%= request.getContextPath() %>/simple-test.jsp" class="btn btn-outline-success w-100">
                                    <i class="fas fa-database me-2"></i>Database Connection Test
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="<%= request.getContextPath() %>/test-enum-fix.jsp" class="btn btn-outline-info w-100">
                                    <i class="fas fa-check-circle me-2"></i>JSP Fix Verification
                                </a>
                            </div>
                        </div>
                        
                        <div class="alert alert-info small">
                            <i class="fas fa-info-circle me-1"></i>
                            <strong>Three Access Methods:</strong><br>
                            • <strong>Servlet-based:</strong> Full functionality via servlets with database connectivity<br>
                            • <strong>JSP Direct:</strong> JSP pages that directly import and use Java DAO classes (like your example)<br>
                            • <strong>Static:</strong> HTML-only pages that work even if Java fails to deploy<br>
                            No authentication required for any method.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>