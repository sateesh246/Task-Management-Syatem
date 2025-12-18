<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Management - Enterprise Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/dashboard.css" rel="stylesheet">
    <style>
        .employee-card {
            transition: all 0.3s ease;
            border: none;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .employee-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        .role-badge {
            font-size: 0.75rem;
            padding: 0.25rem 0.5rem;
        }
        .status-indicator {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
        }
        .status-active {
            background-color: #28a745;
        }
        .status-inactive {
            background-color: #dc3545;
        }
        .employee-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/dashboard">
                <i class="fas fa-tasks me-2"></i>Task Management
            </a>
            
            <div class="navbar-nav me-auto">
                <a class="nav-link" href="${pageContext.request.contextPath}/dashboard">
                    <i class="fas fa-tachometer-alt me-1"></i>Dashboard
                </a>
                <a class="nav-link" href="${pageContext.request.contextPath}/tasks">
                    <i class="fas fa-list me-1"></i>Tasks
                </a>
                <a class="nav-link active" href="${pageContext.request.contextPath}/employees">
                    <i class="fas fa-users me-1"></i>Employees
                </a>
            </div>
            
            <div class="navbar-nav">
                <div class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
                        <i class="fas fa-user-circle me-1"></i>${currentUser.name}
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><h6 class="dropdown-header">${currentUser.role}</h6></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">
                            <i class="fas fa-sign-out-alt me-2"></i>Logout
                        </a></li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container-fluid mt-4">
        <!-- Header -->
        <div class="row mb-4">
            <div class="col-md-6">
                <h2><i class="fas fa-users me-2"></i>Employee Management</h2>
                <p class="text-muted">Manage system users and their roles</p>
            </div>
            <div class="col-md-6 text-end">
                <a href="${pageContext.request.contextPath}/employees/create" class="btn btn-primary">
                    <i class="fas fa-user-plus me-2"></i>Add New Employee
                </a>
            </div>
        </div>

        <!-- Success/Error Messages -->
        <c:if test="${not empty param.success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>
                <c:choose>
                    <c:when test="${param.success == 'employee_created'}">Employee created successfully!</c:when>
                    <c:when test="${param.success == 'employee_updated'}">Employee updated successfully!</c:when>
                    <c:when test="${param.success == 'employee_deactivated'}">Employee deactivated successfully!</c:when>
                    <c:when test="${param.success == 'employee_activated'}">Employee activated successfully!</c:when>
                    <c:otherwise>Operation completed successfully!</c:otherwise>
                </c:choose>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>
                <c:choose>
                    <c:when test="${param.error == 'deactivation_failed'}">Failed to deactivate employee!</c:when>
                    <c:when test="${param.error == 'activation_failed'}">Failed to activate employee!</c:when>
                    <c:when test="${param.error == 'employee_not_found'}">Employee not found!</c:when>
                    <c:when test="${param.error == 'password_reset_failed'}">Failed to reset password!</c:when>
                    <c:otherwise>An error occurred. Please try again.</c:otherwise>
                </c:choose>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Filters -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0">
                    <i class="fas fa-filter me-2"></i>Filters & Search
                </h5>
            </div>
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/employees" class="row g-3">
                    <div class="col-md-3">
                        <label for="role" class="form-label">Role</label>
                        <select class="form-select" id="role" name="role">
                            <option value="ALL" ${roleFilter == null || roleFilter == 'ALL' ? 'selected' : ''}>All Roles</option>
                            <option value="ADMIN" ${roleFilter == 'ADMIN' ? 'selected' : ''}>Admin</option>
                            <option value="MANAGER" ${roleFilter == 'MANAGER' ? 'selected' : ''}>Manager</option>
                            <option value="EMPLOYEE" ${roleFilter == 'EMPLOYEE' ? 'selected' : ''}>Employee</option>
                        </select>
                    </div>
                    
                    <div class="col-md-3">
                        <label for="department" class="form-label">Department</label>
                        <select class="form-select" id="department" name="department">
                            <option value="ALL" ${departmentFilter == null || departmentFilter == 'ALL' ? 'selected' : ''}>All Departments</option>
                            <c:forEach var="dept" items="${departments}">
                                <option value="${dept.id}" ${departmentFilter == dept.id ? 'selected' : ''}>
                                    ${dept.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="col-md-2">
                        <label for="status" class="form-label">Status</label>
                        <select class="form-select" id="status" name="status">
                            <option value="active" ${statusFilter != 'inactive' ? 'selected' : ''}>Active</option>
                            <option value="inactive" ${statusFilter == 'inactive' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>
                    
                    <div class="col-md-3">
                        <label for="search" class="form-label">Search</label>
                        <input type="text" class="form-control" id="search" name="search" 
                               placeholder="Name or email..." value="${searchQuery}">
                    </div>
                    
                    <div class="col-md-1 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Employee Statistics -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card stat-card stat-card-primary">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="card-title text-muted">Total Employees</h6>
                                <h2 class="mb-0">${employees.size()}</h2>
                            </div>
                            <div class="stat-icon">
                                <i class="fas fa-users"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card stat-card-success">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="card-title text-muted">Active</h6>
                                <h2 class="mb-0">
                                    <c:set var="activeCount" value="0"/>
                                    <c:forEach var="emp" items="${employees}">
                                        <c:if test="${emp.active}">
                                            <c:set var="activeCount" value="${activeCount + 1}"/>
                                        </c:if>
                                    </c:forEach>
                                    ${activeCount}
                                </h2>
                            </div>
                            <div class="stat-icon">
                                <i class="fas fa-user-check"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card stat-card-warning">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="card-title text-muted">Managers</h6>
                                <h2 class="mb-0">
                                    <c:set var="managerCount" value="0"/>
                                    <c:forEach var="emp" items="${employees}">
                                        <c:if test="${emp.role == 'MANAGER'}">
                                            <c:set var="managerCount" value="${managerCount + 1}"/>
                                        </c:if>
                                    </c:forEach>
                                    ${managerCount}
                                </h2>
                            </div>
                            <div class="stat-icon">
                                <i class="fas fa-user-tie"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card stat-card-info">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="card-title text-muted">Admins</h6>
                                <h2 class="mb-0">
                                    <c:set var="adminCount" value="0"/>
                                    <c:forEach var="emp" items="${employees}">
                                        <c:if test="${emp.role == 'ADMIN'}">
                                            <c:set var="adminCount" value="${adminCount + 1}"/>
                                        </c:if>
                                    </c:forEach>
                                    ${adminCount}
                                </h2>
                            </div>
                            <div class="stat-icon">
                                <i class="fas fa-user-shield"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Employee List -->
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                    <i class="fas fa-list me-2"></i>Employee List
                </h5>
                <div class="btn-group" role="group">
                    <input type="radio" class="btn-check" name="viewMode" id="cardView" autocomplete="off" checked>
                    <label class="btn btn-outline-primary btn-sm" for="cardView">
                        <i class="fas fa-th-large"></i> Cards
                    </label>
                    
                    <input type="radio" class="btn-check" name="viewMode" id="tableView" autocomplete="off">
                    <label class="btn btn-outline-primary btn-sm" for="tableView">
                        <i class="fas fa-table"></i> Table
                    </label>
                </div>
            </div>
            
            <div class="card-body">
                <!-- Card View -->
                <div id="cardViewContent">
                    <c:choose>
                        <c:when test="${not empty employees}">
                            <div class="row g-4">
                                <c:forEach var="employee" items="${employees}">
                                    <div class="col-lg-4 col-md-6">
                                        <div class="card employee-card h-100">
                                            <div class="card-body">
                                                <div class="d-flex align-items-center mb-3">
                                                    <div class="employee-avatar me-3">
                                                        ${employee.name.substring(0, 1).toUpperCase()}
                                                    </div>
                                                    <div class="flex-grow-1">
                                                        <h6 class="card-title mb-1">
                                                            ${employee.name}
                                                            <span class="status-indicator ${employee.active ? 'status-active' : 'status-inactive'} ms-2"></span>
                                                        </h6>
                                                        <p class="card-text text-muted mb-1">${employee.email}</p>
                                                        <span class="badge role-badge bg-${employee.role == 'ADMIN' ? 'danger' : (employee.role == 'MANAGER' ? 'warning' : 'info')}">
                                                            ${employee.role}
                                                        </span>
                                                    </div>
                                                </div>
                                                
                                                <div class="mb-3">
                                                    <small class="text-muted">
                                                        <i class="fas fa-building me-1"></i>
                                                        ${employee.departmentName}
                                                    </small>
                                                    <c:if test="${not empty employee.managerName}">
                                                        <br>
                                                        <small class="text-muted">
                                                            <i class="fas fa-user-tie me-1"></i>
                                                            Reports to: ${employee.managerName}
                                                        </small>
                                                    </c:if>
                                                </div>
                                                
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <small class="text-muted">
                                                        <i class="fas fa-calendar me-1"></i>
                                                        Joined: <fmt:formatDate value="${employee.createdAt}" pattern="MMM yyyy" />
                                                    </small>
                                                    
                                                    <div class="btn-group" role="group">
                                                        <a href="${pageContext.request.contextPath}/employees/view/${employee.id}" 
                                                           class="btn btn-sm btn-outline-primary" title="View Details">
                                                            <i class="fas fa-eye"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/employees/edit/${employee.id}" 
                                                           class="btn btn-sm btn-outline-secondary" title="Edit">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                        <div class="btn-group" role="group">
                                                            <button class="btn btn-sm btn-outline-danger dropdown-toggle" 
                                                                    type="button" data-bs-toggle="dropdown" title="Actions">
                                                                <i class="fas fa-cog"></i>
                                                            </button>
                                                            <ul class="dropdown-menu">
                                                                <li>
                                                                    <form method="post" action="${pageContext.request.contextPath}/employees" class="d-inline">
                                                                        <input type="hidden" name="action" value="resetPassword">
                                                                        <input type="hidden" name="employeeId" value="${employee.id}">
                                                                        <button type="submit" class="dropdown-item" 
                                                                               onclick="return confirm('Reset password for ${employee.name}?')">
                                                                            <i class="fas fa-key me-2"></i>Reset Password
                                                                        </button>
                                                                    </form>
                                                                </li>
                                                                <li><hr class="dropdown-divider"></li>
                                                                <li>
                                                                    <c:choose>
                                                                        <c:when test="${employee.active}">
                                                                            <form method="post" action="${pageContext.request.contextPath}/employees" class="d-inline">
                                                                                <input type="hidden" name="action" value="deactivate">
                                                                                <input type="hidden" name="employeeId" value="${employee.id}">
                                                                                <button type="submit" class="dropdown-item text-danger" 
                                                                                       onclick="return confirm('Deactivate ${employee.name}? This will reassign their active tasks.')">
                                                                                    <i class="fas fa-user-slash me-2"></i>Deactivate
                                                                                </button>
                                                                            </form>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <form method="post" action="${pageContext.request.contextPath}/employees" class="d-inline">
                                                                                <input type="hidden" name="action" value="activate">
                                                                                <input type="hidden" name="employeeId" value="${employee.id}">
                                                                                <button type="submit" class="dropdown-item text-success" 
                                                                                       onclick="return confirm('Activate ${employee.name}?')">
                                                                                    <i class="fas fa-user-check me-2"></i>Activate
                                                                                </button>
                                                                            </form>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5">
                                <i class="fas fa-users-slash fa-3x text-muted mb-3"></i>
                                <h5 class="text-muted">No employees found</h5>
                                <p class="text-muted">Try adjusting your filters or add a new employee.</p>
                                <a href="${pageContext.request.contextPath}/employees/create" class="btn btn-primary">
                                    <i class="fas fa-user-plus me-2"></i>Add New Employee
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                
                <!-- Table View (Hidden by default) -->
                <div id="tableViewContent" style="display: none;">
                    <c:if test="${not empty employees}">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>Employee</th>
                                        <th>Role</th>
                                        <th>Department</th>
                                        <th>Manager</th>
                                        <th>Status</th>
                                        <th>Joined</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="employee" items="${employees}">
                                        <tr class="${employee.active ? '' : 'table-secondary'}">
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="employee-avatar me-3" style="width: 40px; height: 40px; font-size: 1rem;">
                                                        ${employee.name.substring(0, 1).toUpperCase()}
                                                    </div>
                                                    <div>
                                                        <strong>${employee.name}</strong>
                                                        <br>
                                                        <small class="text-muted">${employee.email}</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <span class="badge role-badge bg-${employee.role == 'ADMIN' ? 'danger' : (employee.role == 'MANAGER' ? 'warning' : 'info')}">
                                                    ${employee.role}
                                                </span>
                                            </td>
                                            <td>${employee.departmentName}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty employee.managerName}">
                                                        ${employee.managerName}
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">-</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <span class="status-indicator ${employee.active ? 'status-active' : 'status-inactive'} me-2"></span>
                                                ${employee.active ? 'Active' : 'Inactive'}
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${employee.createdAt}" pattern="MMM dd, yyyy" />
                                            </td>
                                            <td>
                                                <div class="btn-group" role="group">
                                                    <a href="${pageContext.request.contextPath}/employees/view/${employee.id}" 
                                                       class="btn btn-sm btn-outline-primary">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/employees/edit/${employee.id}" 
                                                       class="btn btn-sm btn-outline-secondary">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // View mode toggle
        document.getElementById('cardView').addEventListener('change', function() {
            if (this.checked) {
                document.getElementById('cardViewContent').style.display = 'block';
                document.getElementById('tableViewContent').style.display = 'none';
            }
        });
        
        document.getElementById('tableView').addEventListener('change', function() {
            if (this.checked) {
                document.getElementById('cardViewContent').style.display = 'none';
                document.getElementById('tableViewContent').style.display = 'block';
            }
        });
        
        // Auto-submit form on filter change
        document.querySelectorAll('select[name="role"], select[name="department"], select[name="status"]').forEach(select => {
            select.addEventListener('change', function() {
                this.form.submit();
            });
        });
    </script>
</body>
</html>