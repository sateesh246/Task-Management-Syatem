<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create New Employee - Enterprise Task Management System</title>
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
        .password-strength {
            height: 5px;
            border-radius: 3px;
            margin-top: 5px;
            transition: all 0.3s ease;
        }
        .strength-weak { background-color: #dc3545; }
        .strength-medium { background-color: #ffc107; }
        .strength-strong { background-color: #28a745; }
        .role-info {
            background: #f8f9fa;
            border-left: 4px solid #0d6efd;
            padding: 1rem;
            margin-top: 1rem;
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
                <li class="breadcrumb-item active">Create New Employee</li>
            </ol>
        </nav>

        <!-- Header -->
        <div class="row mb-4">
            <div class="col-12">
                <h2><i class="fas fa-user-plus me-2"></i>Create New Employee</h2>
                <p class="text-muted">Add a new employee to the system with appropriate role and permissions</p>
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

        <!-- Employee Creation Form -->
        <form method="post" action="${pageContext.request.contextPath}/employees/create" id="employeeCreateForm" novalidate>
            <div class="row">
                <div class="col-lg-8">
                    <!-- Personal Information Section -->
                    <div class="form-section">
                        <h5 class="section-header">
                            <i class="fas fa-user me-2"></i>Personal Information
                        </h5>
                        <div class="p-4">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="name" class="form-label required-field">Full Name</label>
                                        <input type="text" 
                                               class="form-control ${not empty nameError ? 'is-invalid' : ''}" 
                                               id="name" 
                                               name="name" 
                                               value="${formName}"
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
                                               value="${formEmail}"
                                               placeholder="employee@company.com"
                                               maxlength="150"
                                               required>
                                        <div class="invalid-feedback">${emailError}</div>
                                        <small class="form-text text-muted">
                                            This will be used for login and notifications
                                        </small>
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
                                        <label for="password" class="form-label required-field">Password</label>
                                        <div class="input-group">
                                            <input type="password" 
                                                   class="form-control ${not empty passwordError ? 'is-invalid' : ''}" 
                                                   id="password" 
                                                   name="password" 
                                                   placeholder="Enter secure password"
                                                   minlength="8"
                                                   required>
                                            <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <div class="invalid-feedback">${passwordError}</div>
                                        </div>
                                        <div class="password-strength" id="passwordStrength"></div>
                                        <small class="form-text text-muted">
                                            Minimum 8 characters with uppercase, lowercase, number, and special character
                                        </small>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="confirmPassword" class="form-label required-field">Confirm Password</label>
                                        <input type="password" 
                                               class="form-control ${not empty confirmPasswordError ? 'is-invalid' : ''}" 
                                               id="confirmPassword" 
                                               name="confirmPassword" 
                                               placeholder="Confirm password"
                                               required>
                                        <div class="invalid-feedback">${confirmPasswordError}</div>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="role" class="form-label required-field">Role</label>
                                        <select class="form-select ${not empty roleError ? 'is-invalid' : ''}" 
                                                id="role" 
                                                name="role" 
                                                required>
                                            <option value="">Select Role</option>
                                            <c:if test="${currentUser.role == 'ADMIN'}">
                                                <option value="ADMIN" ${formRole == 'ADMIN' ? 'selected' : ''}>
                                                    Administrator
                                                </option>
                                            </c:if>
                                            <option value="MANAGER" ${formRole == 'MANAGER' ? 'selected' : ''}>
                                                Manager
                                            </option>
                                            <option value="EMPLOYEE" ${formRole == 'EMPLOYEE' ? 'selected' : ''}>
                                                Employee
                                            </option>
                                        </select>
                                        <div class="invalid-feedback">${roleError}</div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="isActive" class="form-label">Account Status</label>
                                        <select class="form-select" id="isActive" name="isActive">
                                            <option value="true" ${formIsActive != 'false' ? 'selected' : ''}>
                                                Active
                                            </option>
                                            <option value="false" ${formIsActive == 'false' ? 'selected' : ''}>
                                                Inactive
                                            </option>
                                        </select>
                                        <small class="form-text text-muted">
                                            Inactive employees cannot log in
                                        </small>
                                    </div>
                                </div>
                            </div>

                            <!-- Role Information -->
                            <div class="role-info" id="roleInfo" style="display: none;">
                                <h6><i class="fas fa-info-circle me-2"></i>Role Permissions</h6>
                                <div id="roleDescription"></div>
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
                                                required>
                                            <option value="">Select Department</option>
                                            <c:forEach var="dept" items="${departments}">
                                                <option value="${dept.id}" 
                                                        ${formDepartmentId == dept.id ? 'selected' : ''}>
                                                    ${dept.name}
                                                </option>
                                            </c:forEach>
                                        </select>
                                        <div class="invalid-feedback">${departmentError}</div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="managerId" class="form-label">Manager</label>
                                        <select class="form-select" id="managerId" name="managerId">
                                            <option value="">No Manager (Top Level)</option>
                                            <c:forEach var="manager" items="${managers}">
                                                <option value="${manager.id}" 
                                                        ${formManagerId == manager.id ? 'selected' : ''}>
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
                </div>

                <!-- Right Sidebar -->
                <div class="col-lg-4">
                    <!-- Employee Summary -->
                    <div class="form-section">
                        <h5 class="section-header">
                            <i class="fas fa-eye me-2"></i>Employee Summary
                        </h5>
                        <div class="p-4">
                            <div class="mb-3">
                                <strong>Name:</strong><br>
                                <span id="summaryName" class="text-muted">Not entered</span>
                            </div>
                            <div class="mb-3">
                                <strong>Email:</strong><br>
                                <span id="summaryEmail" class="text-muted">Not entered</span>
                            </div>
                            <div class="mb-3">
                                <strong>Role:</strong><br>
                                <span id="summaryRole" class="text-muted">Not selected</span>
                            </div>
                            <div class="mb-3">
                                <strong>Department:</strong><br>
                                <span id="summaryDepartment" class="text-muted">Not selected</span>
                            </div>
                            <div class="mb-3">
                                <strong>Manager:</strong><br>
                                <span id="summaryManager" class="text-muted">None</span>
                            </div>
                            <div class="mb-3">
                                <strong>Status:</strong><br>
                                <span id="summaryStatus" class="text-muted">Active</span>
                            </div>
                        </div>
                    </div>

                    <!-- Security Guidelines -->
                    <div class="form-section">
                        <h5 class="section-header">
                            <i class="fas fa-shield-alt me-2"></i>Security Guidelines
                        </h5>
                        <div class="p-4">
                            <ul class="list-unstyled mb-0">
                                <li class="mb-2">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Use strong, unique passwords
                                </li>
                                <li class="mb-2">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Assign minimum required permissions
                                </li>
                                <li class="mb-2">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Verify email address accuracy
                                </li>
                                <li class="mb-2">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Set appropriate reporting structure
                                </li>
                                <li class="mb-0">
                                    <i class="fas fa-check text-success me-2"></i>
                                    Review role permissions carefully
                                </li>
                            </ul>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="form-section">
                        <div class="p-4">
                            <button type="submit" class="btn btn-primary btn-lg w-100 mb-3">
                                <i class="fas fa-user-plus me-2"></i>Create Employee
                            </button>
                            <button type="button" class="btn btn-outline-secondary w-100 mb-2" onclick="generatePassword()">
                                <i class="fas fa-random me-2"></i>Generate Password
                            </button>
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
            // Real-time form validation and summary updates
            $('#employeeCreateForm input, #employeeCreateForm select').on('input change', function() {
                validateField(this);
                updateSummary();
            });

            // Password strength indicator
            $('#password').on('input', function() {
                updatePasswordStrength($(this).val());
            });

            // Password confirmation validation
            $('#confirmPassword').on('input', function() {
                validatePasswordConfirmation();
            });

            // Role change handler
            $('#role').on('change', function() {
                updateRoleInfo($(this).val());
                filterManagers();
            });

            // Department change handler
            $('#departmentId').on('change', function() {
                filterManagers();
            });

            // Toggle password visibility
            $('#togglePassword').on('click', function() {
                const passwordField = $('#password');
                const icon = $(this).find('i');
                
                if (passwordField.attr('type') === 'password') {
                    passwordField.attr('type', 'text');
                    icon.removeClass('fa-eye').addClass('fa-eye-slash');
                } else {
                    passwordField.attr('type', 'password');
                    icon.removeClass('fa-eye-slash').addClass('fa-eye');
                }
            });

            // Form submission validation
            $('#employeeCreateForm').on('submit', function(e) {
                if (!validateForm()) {
                    e.preventDefault();
                    showValidationErrors();
                }
            });

            // Initialize
            updateSummary();
            updateRoleInfo($('#role').val());
        });

        function validateField(field) {
            const $field = $(field);
            const value = $field.val().trim();
            let isValid = true;

            // Remove existing validation classes
            $field.removeClass('is-valid is-invalid');

            // Validate based on field type
            switch (field.id) {
                case 'name':
                    isValid = value.length >= 2 && value.length <= 100;
                    break;
                case 'email':
                    isValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
                    break;
                case 'password':
                    isValid = value.length >= 8 && 
                             /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/.test(value);
                    break;
                case 'confirmPassword':
                    isValid = value === $('#password').val();
                    break;
                default:
                    isValid = value !== '';
            }

            // Apply validation class
            if (value !== '') {
                $field.addClass(isValid ? 'is-valid' : 'is-invalid');
            }

            return isValid;
        }

        function updatePasswordStrength(password) {
            const strengthBar = $('#passwordStrength');
            let strength = 0;
            let strengthClass = '';

            if (password.length >= 8) strength++;
            if (/[a-z]/.test(password)) strength++;
            if (/[A-Z]/.test(password)) strength++;
            if (/\d/.test(password)) strength++;
            if (/[@$!%*?&]/.test(password)) strength++;

            if (strength < 3) {
                strengthClass = 'strength-weak';
            } else if (strength < 5) {
                strengthClass = 'strength-medium';
            } else {
                strengthClass = 'strength-strong';
            }

            strengthBar.removeClass('strength-weak strength-medium strength-strong')
                      .addClass(strengthClass)
                      .css('width', (strength * 20) + '%');
        }

        function validatePasswordConfirmation() {
            const password = $('#password').val();
            const confirmPassword = $('#confirmPassword').val();
            const $confirmField = $('#confirmPassword');

            if (confirmPassword !== '') {
                if (password === confirmPassword) {
                    $confirmField.removeClass('is-invalid').addClass('is-valid');
                } else {
                    $confirmField.removeClass('is-valid').addClass('is-invalid');
                }
            }
        }

        function updateRoleInfo(role) {
            const roleInfo = $('#roleInfo');
            const roleDescription = $('#roleDescription');

            if (!role) {
                roleInfo.hide();
                return;
            }

            let description = '';
            switch (role) {
                case 'ADMIN':
                    description = `
                        <ul class="mb-0">
                            <li>Full system access and control</li>
                            <li>Manage all employees and departments</li>
                            <li>View and modify any task</li>
                            <li>Access all reports and analytics</li>
                            <li>System configuration and settings</li>
                        </ul>
                    `;
                    break;
                case 'MANAGER':
                    description = `
                        <ul class="mb-0">
                            <li>Create and assign tasks</li>
                            <li>Manage department employees</li>
                            <li>Approve/reject task submissions</li>
                            <li>View department reports</li>
                            <li>Override workflow restrictions</li>
                        </ul>
                    `;
                    break;
                case 'EMPLOYEE':
                    description = `
                        <ul class="mb-0">
                            <li>View and update assigned tasks</li>
                            <li>Log work sessions and time</li>
                            <li>Add comments and collaborate</li>
                            <li>Update task status (limited)</li>
                            <li>View personal productivity reports</li>
                        </ul>
                    `;
                    break;
            }

            roleDescription.html(description);
            roleInfo.show();
        }

        function filterManagers() {
            const selectedDept = $('#departmentId').val();
            const selectedRole = $('#role').val();
            const managerSelect = $('#managerId');

            // Reset manager options
            managerSelect.find('option:not(:first)').show();

            // Hide managers from different departments (if department is selected)
            if (selectedDept) {
                managerSelect.find('option:not(:first)').each(function() {
                    const optionText = $(this).text();
                    // This is a simplified filter - in real implementation, 
                    // you'd filter based on data attributes
                });
            }

            // If creating an admin, they typically don't have managers
            if (selectedRole === 'ADMIN') {
                managerSelect.val('');
                managerSelect.prop('disabled', true);
            } else {
                managerSelect.prop('disabled', false);
            }
        }

        function updateSummary() {
            $('#summaryName').text($('#name').val() || 'Not entered');
            $('#summaryEmail').text($('#email').val() || 'Not entered');
            
            const roleText = $('#role option:selected').text();
            $('#summaryRole').text(roleText || 'Not selected');
            
            const deptText = $('#departmentId option:selected').text();
            $('#summaryDepartment').text(deptText || 'Not selected');
            
            const managerText = $('#managerId option:selected').text();
            $('#summaryManager').text(managerText || 'None');
            
            const statusText = $('#isActive option:selected').text();
            $('#summaryStatus').text(statusText);
        }

        function generatePassword() {
            const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@$!%*?&';
            let password = '';
            
            // Ensure at least one character from each required category
            password += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[Math.floor(Math.random() * 26)];
            password += 'abcdefghijklmnopqrstuvwxyz'[Math.floor(Math.random() * 26)];
            password += '0123456789'[Math.floor(Math.random() * 10)];
            password += '@$!%*?&'[Math.floor(Math.random() * 7)];
            
            // Fill remaining characters
            for (let i = 4; i < 12; i++) {
                password += chars[Math.floor(Math.random() * chars.length)];
            }
            
            // Shuffle the password
            password = password.split('').sort(() => Math.random() - 0.5).join('');
            
            $('#password').val(password);
            $('#confirmPassword').val(password);
            
            updatePasswordStrength(password);
            validatePasswordConfirmation();
        }

        function validateForm() {
            let isValid = true;
            
            // Validate all required fields
            $('#employeeCreateForm [required]').each(function() {
                if (!validateField(this)) {
                    isValid = false;
                }
            });
            
            // Additional validations
            if ($('#password').val() !== $('#confirmPassword').val()) {
                isValid = false;
            }
            
            return isValid;
        }

        function showValidationErrors() {
            $('html, body').animate({
                scrollTop: $('.is-invalid').first().offset().top - 100
            }, 500);
        }
    </script>
</body>
</html>