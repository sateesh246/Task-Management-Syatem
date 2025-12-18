<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${employee.name} - Employee Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/dashboard.css" rel="stylesheet">
    <style>
        .employee-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            border-radius: 15px;
            margin-bottom: 2rem;
        }
        .employee-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: rgba(255,255,255,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 3rem;
            font-weight: bold;
            border: 4px solid rgba(255,255,255,0.3);
        }
        .status-indicator {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            display: inline-block;
        }
        .status-active { background-color: #28a745; }
        .status-inactive { background-color: #dc3545; }
        .info-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            margin-bottom: 2rem;
        }
        .info-header {
            background: #f8f9fa;
            padding: 1rem 1.5rem;
            border-radius: 15px 15px 0 0;
            border-bottom: 1px solid #dee2e6;
        }
        .task-item {
            border-left: 4px solid #dee2e6;
            padding-left: 1rem;
            margin-bottom: 1rem;
        }
        .task-pending { border-left-color: #6c757d; }
        .task-progress { border-left-color: #0d6efd; }
        .task-review { border-left-color: #17a2b8; }
        .task-completed { border-left-color: #28a745; }
        .task-overdue { border-left-color: #dc3545; }
        .metric-card {
            text-align: center;
            padding: 1.5rem;
            border-radius: 10px;
            background: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .metric-value {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }
        .chart-container {
            position: relative;
            height: 300px;
            margin: 1rem 0;
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
                <li class="breadcrumb-item active">${employee.name}</li>
            </ol>
        </nav>

        <!-- Success/Error Messages -->
        <c:if test="${not empty param.success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>
                <c:choose>
                    <c:when test="${param.success == 'password_reset'}">Password reset successfully!</c:when>
                    <c:when test="${param.success == 'status_updated'}">Employee status updated!</c:when>
                    <c:otherwise>Operation completed successfully!</c:otherwise>
                </c:choose>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Employee Header -->
        <div class="employee-header">
            <div class="row align-items-center">
                <div class="col-md-2">
                    <div class="employee-avatar">
                        ${employee.name.substring(0, 1).toUpperCase()}
                    </div>
                </div>
                <div class="col-md-7">
                    <h1 class="mb-2">
                        ${employee.name}
                        <span class="status-indicator ${employee.active ? 'status-active' : 'status-inactive'} ms-2"></span>
                    </h1>
                    <p class="mb-2 fs-5">${employee.email}</p>
                    <div class="d-flex flex-wrap gap-2">
                        <span class="badge bg-light text-dark fs-6">
                            <i class="fas fa-user-tag me-1"></i>${employee.role}
                        </span>
                        <span class="badge bg-light text-dark fs-6">
                            <i class="fas fa-building me-1"></i>${employee.departmentName}
                        </span>
                        <c:if test="${not empty employee.managerName}">
                            <span class="badge bg-light text-dark fs-6">
                                <i class="fas fa-user-tie me-1"></i>Reports to ${employee.managerName}
                            </span>
                        </c:if>
                    </div>
                </div>
                <div class="col-md-3 text-end">
                    <c:if test="${currentUser.role == 'ADMIN' or (currentUser.role == 'MANAGER' and currentUser.departmentId == employee.departmentId)}">
                        <div class="btn-group" role="group">
                            <a href="${pageContext.request.contextPath}/employees/edit/${employee.id}" 
                               class="btn btn-light">
                                <i class="fas fa-edit me-2"></i>Edit
                            </a>
                            <div class="btn-group" role="group">
                                <button class="btn btn-light dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                    <i class="fas fa-cog me-2"></i>Actions
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
                    </c:if>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Left Column -->
            <div class="col-lg-8">
                <!-- Performance Metrics -->
                <div class="info-card">
                    <div class="info-header">
                        <h5 class="mb-0"><i class="fas fa-chart-line me-2"></i>Performance Metrics</h5>
                    </div>
                    <div class="p-4">
                        <div class="row">
                            <div class="col-md-3">
                                <div class="metric-card">
                                    <div class="metric-value text-primary">${taskStats.totalTasks}</div>
                                    <div class="text-muted">Total Tasks</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="metric-card">
                                    <div class="metric-value text-success">${taskStats.completedTasks}</div>
                                    <div class="text-muted">Completed</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="metric-card">
                                    <div class="metric-value text-info">${taskStats.inProgressTasks}</div>
                                    <div class="text-muted">In Progress</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="metric-card">
                                    <div class="metric-value text-warning">${taskStats.overdueTasks}</div>
                                    <div class="text-muted">Overdue</div>
                                </div>
                            </div>
                        </div>

                        <!-- Performance Chart -->
                        <div class="chart-container">
                            <canvas id="performanceChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Current Tasks -->
                <div class="info-card">
                    <div class="info-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0"><i class="fas fa-tasks me-2"></i>Current Tasks</h5>
                        <span class="badge bg-primary">${currentTasks.size()}</span>
                    </div>
                    <div class="p-4">
                        <c:choose>
                            <c:when test="${not empty currentTasks}">
                                <c:forEach var="task" items="${currentTasks}">
                                    <div class="task-item task-${task.status.name().toLowerCase().replace('_', '')} ${task.overdue ? 'task-overdue' : ''}">
                                        <div class="d-flex justify-content-between align-items-start mb-2">
                                            <div>
                                                <h6 class="mb-1">
                                                    <a href="${pageContext.request.contextPath}/tasks/${task.id}" class="text-decoration-none">
                                                        #${task.id} - ${task.title}
                                                    </a>
                                                </h6>
                                                <p class="text-muted mb-1">${task.description.length() > 100 ? task.description.substring(0, 100) + '...' : task.description}</p>
                                                <div class="d-flex gap-2">
                                                    <span class="badge bg-${task.priority == 'HIGH' ? 'danger' : (task.priority == 'MEDIUM' ? 'warning' : 'secondary')}">
                                                        ${task.priority}
                                                    </span>
                                                    <span class="badge bg-${task.status == 'COMPLETED' ? 'success' : (task.status == 'IN_PROGRESS' ? 'primary' : 'secondary')}">
                                                        ${task.status.name().replace('_', ' ')}
                                                    </span>
                                                    <c:if test="${task.overdue}">
                                                        <span class="badge bg-danger">OVERDUE</span>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <div class="text-end">
                                                <small class="text-muted">
                                                    Due: <fmt:formatDate value="${task.dueDate}" pattern="MMM dd" />
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-4">
                                    <i class="fas fa-tasks fa-3x text-muted mb-3"></i>
                                    <h6 class="text-muted">No current tasks assigned</h6>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Work Sessions -->
                <div class="info-card">
                    <div class="info-header">
                        <h5 class="mb-0"><i class="fas fa-clock me-2"></i>Recent Work Sessions</h5>
                    </div>
                    <div class="p-4">
                        <c:choose>
                            <c:when test="${not empty recentSessions}">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Task</th>
                                                <th>Date</th>
                                                <th>Duration</th>
                                                <th>Notes</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="session" items="${recentSessions}">
                                                <tr>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/tasks/${session.taskId}" class="text-decoration-none">
                                                            #${session.taskId} - ${session.taskTitle}
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <fmt:formatDate value="${session.startTime}" pattern="MMM dd, yyyy" />
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${session.active}">
                                                                <span class="badge bg-success">Active</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${session.formattedDuration}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty session.notes}">
                                                                ${session.notes.length() > 50 ? session.notes.substring(0, 50) + '...' : session.notes}
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">No notes</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-4">
                                    <i class="fas fa-clock fa-3x text-muted mb-3"></i>
                                    <h6 class="text-muted">No work sessions recorded</h6>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Right Column -->
            <div class="col-lg-4">
                <!-- Employee Information -->
                <div class="info-card">
                    <div class="info-header">
                        <h5 class="mb-0"><i class="fas fa-info-circle me-2"></i>Employee Information</h5>
                    </div>
                    <div class="p-4">
                        <div class="mb-3">
                            <strong>Employee ID:</strong><br>
                            <span class="text-muted">#${employee.id}</span>
                        </div>
                        <div class="mb-3">
                            <strong>Full Name:</strong><br>
                            <span class="text-muted">${employee.name}</span>
                        </div>
                        <div class="mb-3">
                            <strong>Email:</strong><br>
                            <span class="text-muted">${employee.email}</span>
                        </div>
                        <div class="mb-3">
                            <strong>Role:</strong><br>
                            <span class="badge bg-${employee.role == 'ADMIN' ? 'danger' : (employee.role == 'MANAGER' ? 'warning' : 'info')}">
                                ${employee.role}
                            </span>
                        </div>
                        <div class="mb-3">
                            <strong>Department:</strong><br>
                            <span class="text-muted">${employee.departmentName}</span>
                        </div>
                        <c:if test="${not empty employee.managerName}">
                            <div class="mb-3">
                                <strong>Manager:</strong><br>
                                <span class="text-muted">${employee.managerName}</span>
                            </div>
                        </c:if>
                        <div class="mb-3">
                            <strong>Status:</strong><br>
                            <span class="badge bg-${employee.active ? 'success' : 'danger'}">
                                ${employee.active ? 'Active' : 'Inactive'}
                            </span>
                        </div>
                        <div class="mb-3">
                            <strong>Joined:</strong><br>
                            <span class="text-muted">
                                <fmt:formatDate value="${employee.createdAt}" pattern="MMMM dd, yyyy" />
                            </span>
                        </div>
                        <div class="mb-0">
                            <strong>Last Updated:</strong><br>
                            <span class="text-muted">
                                <fmt:formatDate value="${employee.updatedAt}" pattern="MMM dd, yyyy HH:mm" />
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Team Members (if manager) -->
                <c:if test="${employee.role == 'MANAGER' and not empty teamMembers}">
                    <div class="info-card">
                        <div class="info-header">
                            <h5 class="mb-0"><i class="fas fa-users me-2"></i>Team Members</h5>
                        </div>
                        <div class="p-4">
                            <c:forEach var="member" items="${teamMembers}">
                                <div class="d-flex align-items-center mb-3">
                                    <div class="employee-avatar me-3" style="width: 40px; height: 40px; font-size: 1rem;">
                                        ${member.name.substring(0, 1).toUpperCase()}
                                    </div>
                                    <div>
                                        <strong>${member.name}</strong><br>
                                        <small class="text-muted">${member.email}</small>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <!-- Quick Stats -->
                <div class="info-card">
                    <div class="info-header">
                        <h5 class="mb-0"><i class="fas fa-chart-bar me-2"></i>Quick Stats</h5>
                    </div>
                    <div class="p-4">
                        <div class="d-flex justify-content-between mb-2">
                            <span>Completion Rate:</span>
                            <strong>${taskStats.completionRate}%</strong>
                        </div>
                        <div class="progress mb-3">
                            <div class="progress-bar bg-success" style="width: ${taskStats.completionRate}%"></div>
                        </div>
                        
                        <div class="d-flex justify-content-between mb-2">
                            <span>Average Task Duration:</span>
                            <strong>${taskStats.avgDuration} days</strong>
                        </div>
                        
                        <div class="d-flex justify-content-between mb-2">
                            <span>Total Work Hours:</span>
                            <strong>${workStats.totalHours} hrs</strong>
                        </div>
                        
                        <div class="d-flex justify-content-between mb-0">
                            <span>This Month:</span>
                            <strong>${workStats.monthlyHours} hrs</strong>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    
    <script>
        // Performance Chart
        const ctx = document.getElementById('performanceChart').getContext('2d');
        const performanceChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [
                    <c:forEach var="data" items="${performanceData}" varStatus="status">
                        '${data.month}'${!status.last ? ',' : ''}
                    </c:forEach>
                ],
                datasets: [{
                    label: 'Tasks Completed',
                    data: [
                        <c:forEach var="data" items="${performanceData}" varStatus="status">
                            ${data.completed}${!status.last ? ',' : ''}
                        </c:forEach>
                    ],
                    borderColor: 'rgb(75, 192, 192)',
                    backgroundColor: 'rgba(75, 192, 192, 0.1)',
                    tension: 0.1
                }, {
                    label: 'Tasks Assigned',
                    data: [
                        <c:forEach var="data" items="${performanceData}" varStatus="status">
                            ${data.assigned}${!status.last ? ',' : ''}
                        </c:forEach>
                    ],
                    borderColor: 'rgb(54, 162, 235)',
                    backgroundColor: 'rgba(54, 162, 235, 0.1)',
                    tension: 0.1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                },
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    title: {
                        display: true,
                        text: 'Task Performance Over Time'
                    }
                }
            }
        });
    </script>
</body>
</html>