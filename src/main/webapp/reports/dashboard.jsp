<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Executive Dashboard - Reports</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/dashboard.css" rel="stylesheet">
    <style>
        .metric-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            padding: 2rem;
            text-align: center;
            height: 100%;
            transition: transform 0.3s ease;
        }
        .metric-card:hover {
            transform: translateY(-5px);
        }
        .metric-value {
            font-size: 3rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }
        .metric-label {
            color: #6c757d;
            font-size: 1.1rem;
        }
        .chart-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            padding: 2rem;
            margin-bottom: 2rem;
        }
        .trend-up { color: #28a745; }
        .trend-down { color: #dc3545; }
        .trend-neutral { color: #6c757d; }
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
                <h2><i class="fas fa-tachometer-alt me-2"></i>Executive Dashboard</h2>
                <p class="text-muted">High-level overview of system performance and key metrics</p>
            </div>
            <div class="col-md-4 text-end">
                <div class="btn-group" role="group">
                    <button class="btn btn-outline-primary" onclick="refreshData()">
                        <i class="fas fa-sync-alt me-2"></i>Refresh
                    </button>
                    <button class="btn btn-outline-success" onclick="exportReport()">
                        <i class="fas fa-download me-2"></i>Export
                    </button>
                </div>
            </div>
        </div>

        <!-- Key Metrics -->
        <div class="row mb-4">
            <div class="col-lg-3 col-md-6 mb-4">
                <div class="metric-card">
                    <div class="metric-value text-primary">${dashboardStats.totalTasks}</div>
                    <div class="metric-label">Total Tasks</div>
                    <div class="mt-2">
                        <small class="trend-up">
                            <i class="fas fa-arrow-up"></i> +${dashboardStats.tasksGrowth}% this month
                        </small>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 mb-4">
                <div class="metric-card">
                    <div class="metric-value text-success">${dashboardStats.completedTasks}</div>
                    <div class="metric-label">Completed Tasks</div>
                    <div class="mt-2">
                        <small class="trend-up">
                            <i class="fas fa-arrow-up"></i> +${dashboardStats.completionGrowth}% this month
                        </small>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 mb-4">
                <div class="metric-card">
                    <div class="metric-value text-warning">${dashboardStats.activeTasks}</div>
                    <div class="metric-label">Active Tasks</div>
                    <div class="mt-2">
                        <small class="trend-neutral">
                            <i class="fas fa-minus"></i> ${dashboardStats.activeChange}% from last week
                        </small>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 mb-4">
                <div class="metric-card">
                    <div class="metric-value text-danger">${dashboardStats.overdueTasks}</div>
                    <div class="metric-label">Overdue Tasks</div>
                    <div class="mt-2">
                        <small class="trend-down">
                            <i class="fas fa-arrow-down"></i> -${dashboardStats.overdueReduction}% this week
                        </small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts Row -->
        <div class="row">
            <!-- Task Completion Trend -->
            <div class="col-lg-8 mb-4">
                <div class="chart-container">
                    <h5 class="mb-3">Task Completion Trend</h5>
                    <canvas id="completionTrendChart" height="300"></canvas>
                </div>
            </div>
            
            <!-- Task Distribution -->
            <div class="col-lg-4 mb-4">
                <div class="chart-container">
                    <h5 class="mb-3">Task Distribution by Status</h5>
                    <canvas id="statusDistributionChart" height="300"></canvas>
                </div>
            </div>
        </div>

        <!-- Department Performance -->
        <div class="row">
            <div class="col-lg-6 mb-4">
                <div class="chart-container">
                    <h5 class="mb-3">Department Performance</h5>
                    <canvas id="departmentPerformanceChart" height="300"></canvas>
                </div>
            </div>
            
            <!-- Priority Distribution -->
            <div class="col-lg-6 mb-4">
                <div class="chart-container">
                    <h5 class="mb-3">Task Priority Distribution</h5>
                    <canvas id="priorityDistributionChart" height="300"></canvas>
                </div>
            </div>
        </div>

        <!-- Performance Metrics Table -->
        <div class="row">
            <div class="col-12">
                <div class="chart-container">
                    <h5 class="mb-3">Top Performers</h5>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>Employee</th>
                                    <th>Department</th>
                                    <th>Completed Tasks</th>
                                    <th>Completion Rate</th>
                                    <th>Avg. Completion Time</th>
                                    <th>Performance Score</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="performer" items="${topPerformers}">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="avatar-sm bg-primary text-white rounded-circle me-2 d-flex align-items-center justify-content-center">
                                                    ${performer.name.substring(0, 1).toUpperCase()}
                                                </div>
                                                ${performer.name}
                                            </div>
                                        </td>
                                        <td>${performer.departmentName}</td>
                                        <td>${performer.completedTasks}</td>
                                        <td>
                                            <div class="progress" style="height: 20px;">
                                                <div class="progress-bar bg-success" style="width: ${performer.completionRate != null ? performer.completionRate : 0}%">
                                                    ${performer.completionRate != null ? performer.completionRate : 0}%
                                                </div>
                                            </div>
                                        </td>
                                        <td>${performer.avgCompletionTime} days</td>
                                        <td>
                                            <span class="badge bg-${performer.performanceScore >= 90 ? 'success' : (performer.performanceScore >= 70 ? 'warning' : 'danger')}">
                                                ${performer.performanceScore}
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    
    <script>
        // Task Completion Trend Chart
        const completionTrendCtx = document.getElementById('completionTrendChart').getContext('2d');
        const completionTrendChart = new Chart(completionTrendCtx, {
            type: 'line',
            data: {
                labels: [
                    <c:choose>
                        <c:when test="${not empty completionTrendData}">
                            <c:forEach var="data" items="${completionTrendData}" varStatus="status">
                                '${data.date}'${!status.last ? ',' : ''}
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            'No Data'
                        </c:otherwise>
                    </c:choose>
                ],
                datasets: [{
                    label: 'Tasks Completed',
                    data: [
                        <c:choose>
                            <c:when test="${not empty completionTrendData}">
                                <c:forEach var="data" items="${completionTrendData}" varStatus="status">
                                    ${data.completed != null ? data.completed : 0}${!status.last ? ',' : ''}
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                0
                            </c:otherwise>
                        </c:choose>
                    ],
                    borderColor: 'rgb(75, 192, 192)',
                    backgroundColor: 'rgba(75, 192, 192, 0.1)',
                    tension: 0.1,
                    fill: true
                }, {
                    label: 'Tasks Created',
                    data: [
                        <c:choose>
                            <c:when test="${not empty completionTrendData}">
                                <c:forEach var="data" items="${completionTrendData}" varStatus="status">
                                    ${data.created != null ? data.created : 0}${!status.last ? ',' : ''}
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                0
                            </c:otherwise>
                        </c:choose>
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
                        beginAtZero: true
                    }
                }
            }
        });

        // Status Distribution Chart
        const statusDistributionCtx = document.getElementById('statusDistributionChart').getContext('2d');
        const statusDistributionChart = new Chart(statusDistributionCtx, {
            type: 'doughnut',
            data: {
                labels: ['Completed', 'In Progress', 'Pending', 'Under Review', 'Overdue'],
                datasets: [{
                    data: [
                        ${statusDistribution.completed != null ? statusDistribution.completed : 0},
                        ${statusDistribution.inProgress != null ? statusDistribution.inProgress : 0},
                        ${statusDistribution.pending != null ? statusDistribution.pending : 0},
                        ${statusDistribution.underReview != null ? statusDistribution.underReview : 0},
                        ${statusDistribution.overdue != null ? statusDistribution.overdue : 0}
                    ],
                    backgroundColor: [
                        '#28a745',
                        '#007bff',
                        '#6c757d',
                        '#17a2b8',
                        '#dc3545'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });

        // Department Performance Chart
        const departmentPerformanceCtx = document.getElementById('departmentPerformanceChart').getContext('2d');
        const departmentPerformanceChart = new Chart(departmentPerformanceCtx, {
            type: 'bar',
            data: {
                labels: [
                    <c:choose>
                        <c:when test="${not empty departmentPerformance}">
                            <c:forEach var="dept" items="${departmentPerformance}" varStatus="status">
                                '${dept.name}'${!status.last ? ',' : ''}
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            'No Data'
                        </c:otherwise>
                    </c:choose>
                ],
                datasets: [{
                    label: 'Completion Rate (%)',
                    data: [
                        <c:choose>
                            <c:when test="${not empty departmentPerformance}">
                                <c:forEach var="dept" items="${departmentPerformance}" varStatus="status">
                                    ${dept.completionRate != null ? dept.completionRate : 0}${!status.last ? ',' : ''}
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                0
                            </c:otherwise>
                        </c:choose>
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
                        beginAtZero: true,
                        max: 100
                    }
                }
            }
        });

        // Priority Distribution Chart
        const priorityDistributionCtx = document.getElementById('priorityDistributionChart').getContext('2d');
        const priorityDistributionChart = new Chart(priorityDistributionCtx, {
            type: 'pie',
            data: {
                labels: ['High Priority', 'Medium Priority', 'Low Priority'],
                datasets: [{
                    data: [
                        ${priorityDistribution.high != null ? priorityDistribution.high : 0},
                        ${priorityDistribution.medium != null ? priorityDistribution.medium : 0},
                        ${priorityDistribution.low != null ? priorityDistribution.low : 0}
                    ],
                    backgroundColor: [
                        '#dc3545',
                        '#ffc107',
                        '#28a745'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });

        function refreshData() {
            location.reload();
        }

        function exportReport() {
            window.open('${pageContext.request.contextPath}/reports/export?type=dashboard&format=pdf', '_blank');
        }

        // Auto-refresh every 5 minutes
        setInterval(refreshData, 300000);
    </script>
</body>
</html>