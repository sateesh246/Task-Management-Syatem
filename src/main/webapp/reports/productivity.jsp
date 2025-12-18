<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Productivity Analysis - Reports</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/dashboard.css" rel="stylesheet">
    <style>
        .productivity-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            padding: 2rem;
            margin-bottom: 2rem;
        }
        .employee-row {
            border-bottom: 1px solid #eee;
            padding: 1rem 0;
        }
        .employee-row:last-child {
            border-bottom: none;
        }
        .productivity-score {
            font-size: 1.5rem;
            font-weight: bold;
        }
        .score-excellent { color: #28a745; }
        .score-good { color: #17a2b8; }
        .score-average { color: #ffc107; }
        .score-poor { color: #dc3545; }
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
                <a class="nav-link active" href="${pageContext.request.contextPath}/reports">
                    <i class="fas fa-chart-bar me-1"></i>Reports
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
            <div class="col-md-8">
                <h2><i class="fas fa-chart-line me-2"></i>Productivity Analysis</h2>
                <p class="text-muted">Employee productivity metrics and performance trends</p>
            </div>
            <div class="col-md-4 text-end">
                <div class="btn-group" role="group">
                    <button class="btn btn-outline-primary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-filter me-2"></i>Filter Period
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="?period=week">This Week</a></li>
                        <li><a class="dropdown-item" href="?period=month">This Month</a></li>
                        <li><a class="dropdown-item" href="?period=quarter">This Quarter</a></li>
                        <li><a class="dropdown-item" href="?period=year">This Year</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- Summary Cards -->
        <div class="row mb-4">
            <div class="col-lg-3 col-md-6 mb-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-primary">${productivityStats.avgCompletionRate}%</h3>
                        <p class="text-muted">Average Completion Rate</p>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 mb-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-success">${productivityStats.totalHoursWorked}</h3>
                        <p class="text-muted">Total Hours Worked</p>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 mb-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-info">${productivityStats.avgTasksPerDay}</h3>
                        <p class="text-muted">Avg Tasks Per Day</p>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 mb-3">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-warning">${productivityStats.avgCompletionTime}</h3>
                        <p class="text-muted">Avg Completion Time (days)</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Productivity Trends Chart -->
        <div class="productivity-card">
            <h5 class="mb-3">Productivity Trends Over Time</h5>
            <canvas id="productivityTrendChart" height="300"></canvas>
        </div>

        <!-- Employee Productivity Rankings -->
        <div class="productivity-card">
            <h5 class="mb-3">Employee Productivity Rankings</h5>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>Rank</th>
                            <th>Employee</th>
                            <th>Department</th>
                            <th>Tasks Completed</th>
                            <th>Hours Worked</th>
                            <th>Completion Rate</th>
                            <th>Productivity Score</th>
                            <th>Trend</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="employee" items="${employeeProductivity}" varStatus="status">
                            <tr>
                                <td>
                                    <span class="badge bg-${status.index < 3 ? 'success' : (status.index < 10 ? 'primary' : 'secondary')}">
                                        #${status.index + 1}
                                    </span>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="avatar-sm bg-primary text-white rounded-circle me-2 d-flex align-items-center justify-content-center">
                                            ${employee.name.substring(0, 1).toUpperCase()}
                                        </div>
                                        <div>
                                            <div class="fw-bold">${employee.name}</div>
                                            <small class="text-muted">${employee.email}</small>
                                        </div>
                                    </div>
                                </td>
                                <td>${employee.departmentName}</td>
                                <td>
                                    <span class="badge bg-success">${employee.tasksCompleted}</span>
                                </td>
                                <td>${employee.hoursWorked}h</td>
                                <td>
                                    <div class="progress" style="height: 20px;">
                                        <div class="progress-bar bg-info" style="width: ${employee.completionRate}%">
                                            ${employee.completionRate}%
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="productivity-score score-${employee.productivityScore >= 90 ? 'excellent' : (employee.productivityScore >= 75 ? 'good' : (employee.productivityScore >= 60 ? 'average' : 'poor'))}">
                                        ${employee.productivityScore}
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${employee.trend > 0}">
                                            <i class="fas fa-arrow-up text-success"></i>
                                            <small class="text-success">+${employee.trend}%</small>
                                        </c:when>
                                        <c:when test="${employee.trend < 0}">
                                            <i class="fas fa-arrow-down text-danger"></i>
                                            <small class="text-danger">${employee.trend}%</small>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fas fa-minus text-muted"></i>
                                            <small class="text-muted">0%</small>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Department Comparison -->
        <div class="row">
            <div class="col-lg-6">
                <div class="productivity-card">
                    <h5 class="mb-3">Department Productivity Comparison</h5>
                    <canvas id="departmentComparisonChart" height="300"></canvas>
                </div>
            </div>
            <div class="col-lg-6">
                <div class="productivity-card">
                    <h5 class="mb-3">Work Hours Distribution</h5>
                    <canvas id="workHoursChart" height="300"></canvas>
                </div>
            </div>
        </div>

        <!-- Productivity Insights -->
        <div class="productivity-card">
            <h5 class="mb-3">Productivity Insights</h5>
            <div class="row">
                <div class="col-md-4">
                    <div class="alert alert-success">
                        <h6><i class="fas fa-trophy me-2"></i>Top Performer</h6>
                        <p class="mb-0">${insights.topPerformer.name} with ${insights.topPerformer.score} productivity score</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="alert alert-info">
                        <h6><i class="fas fa-chart-line me-2"></i>Most Improved</h6>
                        <p class="mb-0">${insights.mostImproved.name} improved by ${insights.mostImproved.improvement}%</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="alert alert-warning">
                        <h6><i class="fas fa-clock me-2"></i>Peak Hours</h6>
                        <p class="mb-0">Most productive time: ${insights.peakHours}</p>
                    </div>
                </div>
            </div>
            
            <div class="row mt-3">
                <div class="col-md-6">
                    <h6>Recommendations</h6>
                    <ul class="list-unstyled">
                        <c:forEach var="recommendation" items="${insights.recommendations}">
                            <li class="mb-2">
                                <i class="fas fa-lightbulb text-warning me-2"></i>
                                ${recommendation}
                            </li>
                        </c:forEach>
                    </ul>
                </div>
                <div class="col-md-6">
                    <h6>Key Metrics</h6>
                    <div class="row">
                        <div class="col-6">
                            <small class="text-muted">Average Efficiency</small>
                            <div class="h5">${insights.avgEfficiency}%</div>
                        </div>
                        <div class="col-6">
                            <small class="text-muted">Team Velocity</small>
                            <div class="h5">${insights.teamVelocity} tasks/week</div>
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
        // Productivity Trend Chart
        const productivityTrendCtx = document.getElementById('productivityTrendChart').getContext('2d');
        const productivityTrendChart = new Chart(productivityTrendCtx, {
            type: 'line',
            data: {
                labels: [
                    <c:forEach var="data" items="${productivityTrendData}" varStatus="status">
                        '${data.date}'${!status.last ? ',' : ''}
                    </c:forEach>
                ],
                datasets: [{
                    label: 'Productivity Score',
                    data: [
                        <c:forEach var="data" items="${productivityTrendData}" varStatus="status">
                            ${data.productivityScore}${!status.last ? ',' : ''}
                        </c:forEach>
                    ],
                    borderColor: 'rgb(75, 192, 192)',
                    backgroundColor: 'rgba(75, 192, 192, 0.1)',
                    tension: 0.1,
                    fill: true
                }, {
                    label: 'Completion Rate',
                    data: [
                        <c:forEach var="data" items="${productivityTrendData}" varStatus="status">
                            ${data.completionRate}${!status.last ? ',' : ''}
                        </c:forEach>
                    ],
                    borderColor: 'rgb(54, 162, 235)',
                    backgroundColor: 'rgba(54, 162, 235, 0.1)',
                    tension: 0.1,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100
                    }
                }
            }
        });

        // Department Comparison Chart
        const departmentComparisonCtx = document.getElementById('departmentComparisonChart').getContext('2d');
        const departmentComparisonChart = new Chart(departmentComparisonCtx, {
            type: 'radar',
            data: {
                labels: ['Completion Rate', 'Efficiency', 'Quality', 'Timeliness', 'Collaboration'],
                datasets: [
                    <c:forEach var="dept" items="${departmentComparison}" varStatus="status">
                    {
                        label: '${dept.name}',
                        data: [${dept.completionRate}, ${dept.efficiency}, ${dept.quality}, ${dept.timeliness}, ${dept.collaboration}],
                        borderColor: '${dept.color}',
                        backgroundColor: '${dept.color}33',
                        pointBackgroundColor: '${dept.color}',
                        pointBorderColor: '#fff',
                        pointHoverBackgroundColor: '#fff',
                        pointHoverBorderColor: '${dept.color}'
                    }${!status.last ? ',' : ''}
                    </c:forEach>
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    r: {
                        beginAtZero: true,
                        max: 100
                    }
                }
            }
        });

        // Work Hours Chart
        const workHoursCtx = document.getElementById('workHoursChart').getContext('2d');
        const workHoursChart = new Chart(workHoursCtx, {
            type: 'bar',
            data: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                datasets: [{
                    label: 'Hours Worked',
                    data: [
                        <c:forEach var="hours" items="${weeklyHours}" varStatus="status">
                            ${hours}${!status.last ? ',' : ''}
                        </c:forEach>
                    ],
                    backgroundColor: 'rgba(54, 162, 235, 0.8)',
                    borderColor: 'rgba(54, 162, 235, 1)',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    </script>
</body>
</html>