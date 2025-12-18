<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Employee - ${employee.name}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/dashboard.css" rel="stylesheet">
    <style>
        .form-section {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            margin-bottom: 2rem;
        }
        .section-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1rem 1.5rem;
            border-radius: 15px 15px 0 0;
            margin-bottom: 0;
        }
        .required-field::after {
            content: " *";
            color: #dc3545;
        }
        .change-indicator {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 0.5rem;
            margin: 0.5rem 0;
        }
        .employee-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            font-weight: bold;
        }
        .role-change-warning {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 8px;
            padding: 1rem;
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
                <a class="nav-link" href="${pageContext.request.contextPath}/employees">
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
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/employees">Employees</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/employees/view/${employee.id}">${employee.name}</a></li>
                <li class="breadcrumb-item active">Edit</li>
            </ol>
        </nav>

        <!-- Header -->
        <div class="row mb-4">
            <div class="col-12">
                <h2><i class="fas fa-user-edit me-2"></i>Edit Employee</h2>
                <p class="text-muted">Update employee information and settings</p>
            </div>
        </div>

        <!-- Error Messages -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>
                ${errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Employee Edit Form -->
        <form method="post" action="${pageContext.request.contextPath}/employees/edit/${employee.id}" id="employeeEditForm" novalidate>
            <input type="hidden" name="employeeId" value="${employee.id}">
            
            <div class="row">
                <div class="col-lg-8">
                    <!-- Personal Information Section -->
                    <div class="form-section">
                        <h5 class="section-header">
                            <i class="fas fa-user me-2"></i>Personal Information
                        </h5>
                        <div class="p-4">
                            <div class="row">
                                <div class="col-md-2 text-center mb-3">
                                    <div class="employee-avatar">
                                        ${employee.name.substring(0, 1).toUpperCase()}
                                    </div>
                                </div>
                                <div class="col-md-10">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="name" class="form-label required-field">Full Name</label>
                                                <input type="text" 
                                                       class="form-control ${not empty nameError ? 'is-invalid' : ''}" 
                                                       id="name" 
                                                       name="name" 
                                                       value="${employee.name}"
                                                       placeholder="Enter employee's full name"
                                                       maxlength="100"
                                                       required>
                                                <div class="invalid-feedback">${nameError}</div>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <label for="email" class="form-label required-field">Email Address</label>
                                                <input type="email" 
                                                       class="form-control ${not empty emailError ? 'is-invalid' : ''}" 
                                                       id="email" 
                                                       name="email" 
                                                       value="${employee.email}"
                                                       placeholder="employee@company.com"
                                                       maxlength="150"
                                                       required>
                                                <div class="invalid-feedback">${emailError}</div>
                                                <small class="form-text text-muted">
                                                    Changing email will require the user to log in with the new email
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Account Information Section -->
                    <div class="form-section">
                        <h5 class="section-header">
                            <i class="fas fa-key me-2"></i>Account Information
                        </h5>
                        <div class="p-4">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="role" class="form-label required-field">Role</label>
                                        <select class="form-select ${not empty roleError ? 'is-invalid' : ''}" 
                                                id="role" 
                                                name="role" 
                                                data-original-value="${employee.role}"
                                                required>
                                            <c:if test="${currentUser.role == 'ADMIN'}">
                                                <option value="ADMIN" ${employee.role == 'ADMIN' ? 'selected' : ''}>
                                                    Administrator
                                                </option>
                                            </c:if>
                                            <option value="MANAGER" ${employee.role == 'MANAGER' ? 'selected' : ''}>
                                                Manager
                                            </option>
                                            <option value="EMPLOYEE" ${employee.role == 'EMPLOYEE' ? 'selected' : ''}>
                                                Employee
                                            </option>
                                        </select>
                                        <div class="invalid-feedback">${roleError}</div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="isActive" class="form-label">Account Status</label>
                                        <select class="form-select" 
                                                id="isActive" 
                                                name="isActive"
                                                data-original-value="${employee.active}">
                                            <option value="true" ${employee.active ? 'selected' : ''}>
                                                Active
                                            </option>
                                            <option value="false" ${!employee.active ? 'selected' : ''}>
                                                Inactive
                                            </option>
                                        </select>
                                        <small class="form-text text-muted">
                                            Deactivating will reassign active tasks and prevent login
                                        </small>
                                    </div>
                                </div>
                            </div>

                            <!-- Role Change Warning -->
                            <div class="role-change-warning" id="roleChangeWarning" style="display: none;">
                                <h6><i class="fas fa-exclamation-triangle me-2"></i>Role Change Impact</h6>
                                <div id="roleChangeMessage"></div>
                            </div>
                        </div>
                    </div>

                    <!-- Organizational Information Section -->
                    <div class="form-section">
                        <h5 class="section-header">
                            <i class="fas fa-building me-2"></i>Organizational Information
                        </h5>
                        <div class="p-4">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="departmentId" class="form-label required-field">Department</label>
                                        <select class="form-select ${not empty departmentError ? 'is-invalid' : ''}" 
                                                id="departmentId" 
                                                name="departmentId" 
                                                data-original-value="${employee.departmentId}"
                                                required>
                                            <c:forEach var="dept" items="${departments}">
                                                <option value="${dept.id}" 
                                                        ${employee.departmentId == dept.id ? 'selected' : ''}>
                                                    ${dept.name}
                                                </option>
                                            </c:forEach>
                                        </select>
                                        <div class="invalid-feedback">${departmentError}</div>
                                        <small class="form-text text-muted">
                                            Changing department may affect task assignments and reporting
                                        </small>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="managerId" class="form-label">Manager</label>
                                        <select class="form-select" 
                                                id="managerId" 
                                                name="managerId"
                                                data-original-value="${employee.managerId}">
                                            <option value="">No Manager (Top Level)</option>
                                            <c:forEach var="manager" items="${managers}">
                                                <option value="${manager.id}" 
                                                        ${employee.managerId == manager.id ? 'selected' : ''}>
                                                    ${manager.name} (${manager.departmentName})
                                                </option>
                                            </c:forEach>
                                        </select>
                                        <small class="form-text text-muted">
                                            Select reporting manager (optional)
                                        </small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Password Reset Section -->
                    <div class="form-section">
                        <h5 class="section-header">
                            <i class="fas fa-lock me-2"></i>Password Management
                        </h5>
                        <div class="p-4">
                            <div class="form-check mb-3">
                                <input class="form-check-input" type="checkbox" id="resetPassword" name="resetPassword">
                                <label class="form-check-label" for="resetPassword">
                                    Reset password to default
                                </label>
                            </div>
                            
                            <div id="passwordResetInfo" style="display: none;">
                                <div class="alert alert-info">
                                    <i class="fas fa-info-circle me-2"></i>
                                    The password will be reset to a temporary password. The employee will be required to change it on next login.
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Sidebar -->
                <div class="col-lg-4">
                    <!-- Employee Information -->
                    <div class="form-section">
                        <h5 class="section-header">
                            <i class="fas fa-info me-2"></i>Employee Information
                        </h5>
                        <div class="p-4">
                            <div class="mb-3">
                                <strong>Employee ID:</strong><br>
                                <span class="text-muted">#${employee.id}</span>
                            </div>
                            <div class="mb-3">
                                <strong>Created:</strong><br>
                                <span class="text-muted">
                                    <fmt:formatDate value="${employee.createdAt}" pattern="MMM dd, yyyy" />
                                </span>
                            </div>
                            <div class="mb-3">
                                <strong>Last Updated:</strong><br>
                                <span class="text-muted">
                                    <fmt:formatDate value="${employee.updatedAt}" pattern="MMM dd, yyyy HH:mm" />
                                </span>
                            </div>
                            <div class="mb-3">
                                <strong>Current Tasks:</strong><br>
                                <span class="text-muted">${employee.activeTasks} active</span>
                            </div>
                        </div>
                    </div>

                    <!-- Change Summary -->
                    <div class="form-section">
                        <h5 class="section-header">
                            <i class="fas fa-list-alt me-2"></i>Change Summary
                        </h5>
                        <div class="p-4">
                            <div id="changeSummary">
                                <p class="text-muted">No changes made</p>
                            </div>
                        </div>
                    </div>

                    <!-- Impact Assessment -->
                    <div class="form-section">
                        <h5 class="section-header">
                            <i class="fas fa-exclamation-triangle me-2"></i>Impact Assessment
                        </h5>
                        <div class="p-4">
                            <div id="impactAssessment">
                                <p class="text-muted">Make changes to see impact</p>
                            </div>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="form-section">
                        <div class="p-4">
                            <button type="submit" class="btn btn-primary btn-lg w-100 mb-3">
                                <i class="fas fa-save me-2"></i>Save Changes
                            </button>
                            <a href="${pageContext.request.contextPath}/employees/view/${employee.id}" class="btn btn-outline-secondary w-100 mb-2">
                                <i class="fas fa-eye me-2"></i>View Employee
                            </a>
                            <a href="${pageContext.request.contextPath}/employees" class="btn btn-outline-danger w-100">
                                <i class="fas fa-times me-2"></i>Cancel
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <script>
        $(document).ready(function() {
            // Store original values for change detection
            const originalValues = {
                name: $('#name').val(),
                email: $('#email').val(),
                role: $('#role').val(),
                isActive: $('#isActive').val(),
                departmentId: $('#departmentId').val(),
                managerId: $('#managerId').val()
            };

            // Track changes
            $('#employeeEditForm input, #employeeEditForm select').on('change input', function() {
                updateChangeSummary();
                updateImpactAssessment();
                validateField(this);
            });

            // Role change handler
            $('#role').on('change', function() {
                handleRoleChange($(this).val(), originalValues.role);
                filterManagers();
            });

            // Department change handler
            $('#departmentId').on('change', function() {
                filterManagers();
            });

            // Password reset checkbox
            $('#resetPassword').on('change', function() {
                $('#passwordResetInfo').toggle($(this).is(':checked'));
                updateChangeSummary();
            });

            // Form validation
            $('#employeeEditForm').on('submit', function(e) {
                if (!validateForm()) {
                    e.preventDefault();
                    showValidationErrors();
                }
            });

            function validateField(field) {
                const $field = $(field);
                const value = $field.val().trim();
                let isValid = true;

                $field.removeClass('is-valid is-invalid');

                switch (field.id) {
                    case 'name':
                        isValid = value.length >= 2 && value.length <= 100;
                        break;
                    case 'email':
                        isValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
                        break;
                    default:
                        isValid = value !== '';
                }

                if (value !== '') {
                    $field.addClass(isValid ? 'is-valid' : 'is-invalid');
                }

                return isValid;
            }

            function handleRoleChange(newRole, originalRole) {
                const warning = $('#roleChangeWarning');
                const message = $('#roleChangeMessage');

                if (newRole !== originalRole) {
                    let warningText = '';
                    
                    if (originalRole === 'MANAGER' && newRole === 'EMPLOYEE') {
                        warningText = `
                            <p><strong>Downgrading from Manager to Employee:</strong></p>
                            <ul>
                                <li>Will lose ability to create and assign tasks</li>
                                <li>Team members will need a new manager assigned</li>
                                <li>Access to management reports will be revoked</li>
                            </ul>
                        `;
                    } else if (originalRole === 'EMPLOYEE' && newRole === 'MANAGER') {
                        warningText = `
                            <p><strong>Promoting from Employee to Manager:</strong></p>
                            <ul>
                                <li>Will gain ability to create and assign tasks</li>
                                <li>Can manage employees in the same department</li>
                                <li>Access to management reports will be granted</li>
                            </ul>
                        `;
                    } else if (newRole === 'ADMIN') {
                        warningText = `
                            <p><strong>Promoting to Administrator:</strong></p>
                            <ul>
                                <li>Will gain full system access</li>
                                <li>Can manage all employees and departments</li>
                                <li>Access to all system reports and settings</li>
                            </ul>
                        `;
                    } else if (originalRole === 'ADMIN') {
                        warningText = `
                            <p><strong>Removing Administrator privileges:</strong></p>
                            <ul>
                                <li>Will lose system-wide access</li>
                                <li>Access restricted to department/role permissions</li>
                                <li>Cannot manage other administrators</li>
                            </ul>
                        `;
                    }

                    message.html(warningText);
                    warning.show();
                } else {
                    warning.hide();
                }
            }

            function filterManagers() {
                const selectedDept = $('#departmentId').val();
                const selectedRole = $('#role').val();
                const managerSelect = $('#managerId');

                // Reset manager options
                managerSelect.find('option:not(:first)').show();

                // If creating an admin, they typically don't have managers
                if (selectedRole === 'ADMIN') {
                    managerSelect.val('');
                    managerSelect.prop('disabled', true);
                } else {
                    managerSelect.prop('disabled', false);
                }
            }

            function updateChangeSummary() {
                const changes = [];
                
                // Check field changes
                if ($('#name').val() !== originalValues.name) {
                    changes.push('Name updated');
                }
                if ($('#email').val() !== originalValues.email) {
                    changes.push('Email address changed');
                }
                if ($('#role').val() !== originalValues.role) {
                    changes.push('Role changed from ' + originalValues.role + ' to ' + $('#role').val());
                }
                if ($('#isActive').val() !== originalValues.isActive) {
                    const newStatus = $('#isActive').val() === 'true' ? 'Active' : 'Inactive';
                    changes.push('Status changed to ' + newStatus);
                }
                if ($('#departmentId').val() !== originalValues.departmentId) {
                    changes.push('Department changed');
                }
                if ($('#managerId').val() !== originalValues.managerId) {
                    changes.push('Manager assignment changed');
                }
                if ($('#resetPassword').is(':checked')) {
                    changes.push('Password will be reset');
                }

                const summaryDiv = $('#changeSummary');
                if (changes.length > 0) {
                    let html = '<ul class="list-unstyled mb-0">';
                    changes.forEach(change => {
                        html += '<li><i class="fas fa-check text-success me-2"></i>' + change + '</li>';
                    });
                    html += '</ul>';
                    summaryDiv.html(html);
                } else {
                    summaryDiv.html('<p class="text-muted mb-0">No changes made</p>');
                }
            }

            function updateImpactAssessment() {
                const impacts = [];
                
                // Check for significant changes
                if ($('#isActive').val() !== originalValues.isActive && $('#isActive').val() === 'false') {
                    impacts.push({
                        type: 'warning',
                        text: 'Deactivating will reassign ${employee.activeTasks} active tasks'
                    });
                }
                
                if ($('#role').val() !== originalValues.role) {
                    impacts.push({
                        type: 'info',
                        text: 'Role change will affect permissions immediately'
                    });
                }
                
                if ($('#departmentId').val() !== originalValues.departmentId) {
                    impacts.push({
                        type: 'info',
                        text: 'Department change may affect task visibility'
                    });
                }

                const assessmentDiv = $('#impactAssessment');
                if (impacts.length > 0) {
                    let html = '';
                    impacts.forEach(impact => {
                        html += '<div class="alert alert-' + impact.type + ' py-2 mb-2">';
                        html += '<i class="fas fa-info-circle me-2"></i>' + impact.text;
                        html += '</div>';
                    });
                    assessmentDiv.html(html);
                } else {
                    assessmentDiv.html('<p class="text-muted mb-0">No significant impact detected</p>');
                }
            }

            function validateForm() {
                let isValid = true;
                
                $('#employeeEditForm [required]').each(function() {
                    if (!validateField(this)) {
                        isValid = false;
                    }
                });
                
                return isValid;
            }

            function showValidationErrors() {
                $('html, body').animate({
                    scrollTop: $('.is-invalid').first().offset().top - 100
                }, 500);
            }

            // Initialize
            updateChangeSummary();
            updateImpactAssessment();
        });
    </script>
</body>
</html>