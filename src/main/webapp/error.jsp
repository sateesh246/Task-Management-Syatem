<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Enterprise Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .error-container {
            background: white;
            border-radius: 20px;
            padding: 3rem;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
            width: 90%;
        }
        
        .error-icon {
            font-size: 4rem;
            color: #dc3545;
            margin-bottom: 1.5rem;
        }
        
        .error-title {
            font-size: 2rem;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 1rem;
        }
        
        .error-message {
            color: #6c757d;
            font-size: 1.1rem;
            margin-bottom: 2rem;
            line-height: 1.6;
        }
        
        .btn-home {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            padding: 0.75rem 2rem;
            font-weight: 600;
            border-radius: 10px;
            transition: all 0.3s ease;
        }
        
        .btn-home:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }
        
        .error-details {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 1rem;
            margin-top: 1.5rem;
            text-align: left;
            font-family: monospace;
            font-size: 0.9rem;
            color: #495057;
            max-height: 200px;
            overflow-y: auto;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        
        <h1 class="error-title">
            <c:choose>
                <c:when test="${pageContext.errorData.statusCode == 404}">
                    Page Not Found
                </c:when>
                <c:when test="${pageContext.errorData.statusCode == 403}">
                    Access Denied
                </c:when>
                <c:when test="${pageContext.errorData.statusCode == 500}">
                    Internal Server Error
                </c:when>
                <c:otherwise>
                    Something Went Wrong
                </c:otherwise>
            </c:choose>
        </h1>
        
        <p class="error-message">
            <c:choose>
                <c:when test="${not empty errorMessage}">
                    ${errorMessage}
                </c:when>
                <c:when test="${pageContext.errorData.statusCode == 404}">
                    The page you're looking for doesn't exist or has been moved.
                </c:when>
                <c:when test="${pageContext.errorData.statusCode == 403}">
                    You don't have permission to access this resource.
                </c:when>
                <c:when test="${pageContext.errorData.statusCode == 500}">
                    We're experiencing technical difficulties. Please try again later.
                </c:when>
                <c:otherwise>
                    An unexpected error occurred. Please try again or contact support if the problem persists.
                </c:otherwise>
            </c:choose>
        </p>
        
        <div class="d-flex gap-2 justify-content-center">
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary btn-home">
                <i class="fas fa-home me-2"></i>
                Go to Dashboard
            </a>
            
            <button onclick="history.back()" class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left me-2"></i>
                Go Back
            </button>
        </div>
        
        <!-- Error Details (for development) -->
        <c:if test="${not empty pageContext.errorData.throwable}">
            <details class="mt-3">
                <summary class="btn btn-link btn-sm">Show Technical Details</summary>
                <div class="error-details">
                    <strong>Request URI:</strong> ${pageContext.errorData.requestURI}<br>
                    <strong>Status Code:</strong> ${pageContext.errorData.statusCode}<br>
                    <strong>Exception:</strong> ${pageContext.errorData.throwable.class.name}<br>
                    <strong>Message:</strong> ${pageContext.errorData.throwable.message}<br>
                    <br>
                    <strong>Stack Trace:</strong><br>
                    <c:forEach var="trace" items="${pageContext.errorData.throwable.stackTrace}">
                        ${trace}<br>
                    </c:forEach>
                </div>
            </details>
        </c:if>
        
        <div class="mt-4">
            <small class="text-muted">
                <i class="fas fa-clock me-1"></i>
                Error occurred at: <span id="errorTime"></span>
            </small>
        </div>
    </div>
    
    <script>
        // Display current time
        document.getElementById('errorTime').textContent = new Date().toLocaleString();
        
        // Auto-redirect after 30 seconds for certain errors
        <c:if test="${pageContext.errorData.statusCode == 500}">
        setTimeout(function() {
            if (confirm('Would you like to return to the dashboard?')) {
                window.location.href = '${pageContext.request.contextPath}/dashboard';
            }
        }, 30000);
        </c:if>
    </script>
</body>
</html>