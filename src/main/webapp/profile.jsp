<%@page import="com.taskmanagement.dao.TaskDAO"%>
<%@page import="com.taskmanagement.dao.EmployeeDAO"%>
<%@page import="com.taskmanagement.dao.DepartmentDAO"%>
<%@page import="com.taskmanagement.dao.WorkSessionDAO"%>
<%@page import="com.taskmanagement.dao.NotificationDAO"%>
<%@page import="com.taskmanagement.model.Employee"%>
<%@page import="com.taskmanagement.model.Task"%>
<%@page import="com.taskmanagement.model.Department"%>
<%@page import="com.taskmanagement.model.WorkSession"%>
<%@page import="com.taskmanagement.model.Notification"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Initialize DAOs early
    EmployeeDAO employeeDAO = new EmployeeDAO();
    Employee loggedInUser = null;
    
    // First, try to get user from session (for authenticated dashboards)
    Employee sessionUser = (Employee) session.getAttribute("loggedInUser");
    if (sessionUser != null) {
        loggedInUser = sessionUser;
    } else {
        // Fallback: use userId parameter or default
        int userId = 1; // Default to first employee
        String userIdParam = request.getParameter("userId");
        if (userIdParam != null) {
            try {
                 userId = Integer.parseInt(userIdParam);
            } catch (NumberFormatException e) {
                userId = 1;
            }
        }
        loggedInUser = employeeDAO.getById(userId);
    }
    if (loggedInUser == null) {
        // If user not found, get first available user
        List<Employee> allEmployees = employeeDAO.getAll(null, null, true);
        if (!allEmployees.isEmpty()) {
            loggedInUser = allEmployees.get(0);
        } else {
            // Create a default user if none exist
            loggedInUser = new Employee();
            loggedInUser.setId(1);
            loggedInUser.setName("Demo User");
            loggedInUser.setEmail("demo@company.com");
            loggedInUser.setRole(Employee.Role.EMPLOYEE);
            loggedInUser.setDepartmentId(1);
            loggedInUser.setActive(true);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - <%= loggedInUser.getName() %> - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .profile-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            border-radius: 15px;
            margin-bottom: 2rem;
        }
        .profile-avatar {
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
        .metric-card {
            text-align: center;
            padding: 1.5rem;
            border-radius: 10px;
            background: #f8f9fa;
            margin-bottom: 1rem;
        }
        .metric-number {
            font-size: 2rem;
            font-weight: bold;
            color: #667eea;
        }
        .metric-label {
            color: #6c757d;
            font-size: 0.9rem;
        }
        .role-badge {
            font-size: 1rem;
            padding: 0.5rem 1rem;
        }
        .activity-item {
            border-left: 3px solid #667eea;
            padding-left: 1rem;
            margin-bottom: 1rem;
        }
        .notification-item {
            padding: 0.75rem;
            border-radius: 8px;
            margin-bottom: 0.5rem;
            transition: all 0.3s ease;
        }
        .notification-item.unread {
            background-color: #f8f9fa;
            border-left: 4px solid #007bff;
        }
        .notification-item:hover {
            background-color: #e9ecef;
        }
        .notification-pulse {
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
    </style>
</head>
<body class="bg-light">
    <%
        // Initialize remaining DAOs
        TaskDAO taskDAO = new TaskDAO();
        DepartmentDAO departmentDAO = new DepartmentDAO();
        WorkSessionDAO workSessionDAO = new WorkSessionDAO();
        NotificationDAO notificationDAO = new NotificationDAO();
        
        // Get user's department
        Department userDept = null;
        try {
            userDept = departmentDAO.getById(loggedInUser.getDepartmentId());
        } catch (Exception e) {
            // Handle error
        }
        
        // Get user's manager
        Employee manager = null;
        if (loggedInUser.getManagerId() != null) {
            try {
                manager = employeeDAO.getById(loggedInUser.getManagerId());
            } catch (Exception e) {
                // Handle error
            }
        }
        
        // Get user's tasks and statistics
        List<Task> userTasks = taskDAO.getTasksAssignedToEmployee(loggedInUser.getId(), 0, 100);
        List<WorkSession> userSessions = workSessionDAO.getSessionsForEmployee(loggedInUser.getId(), 10);
        
        // Get user's notifications
        List<Notification> userNotifications = new ArrayList<>();
        try {
            userNotifications = notificationDAO.getNotificationsForUser(loggedInUser.getId(), false, 10);
        } catch (Exception e) {
            // Handle error - create some sample notifications for demo
            userNotifications = new ArrayList<>();
        }
        
        // Calculate statistics
        int totalTasks = userTasks.size();
        int completedTasks = 0;
        int inProgressTasks = 0;
        int pendingTasks = 0;
        
        for (Task task : userTasks) {
            switch (task.getStatus()) {
                case COMPLETED:
                    completedTasks++;
                    break;
                case IN_PROGRESS:
                    inProgressTasks++;
                    break;
                case PENDING:
                    pendingTasks++;
                    break;
            }
        }
        
        // Calculate total work time
        int totalWorkMinutes = 0;
        try {
            // Calculate manually from work sessions
            for (WorkSession workSession : userSessions) {
                if (workSession.getDurationMinutes() != null) {
                    totalWorkMinutes += workSession.getDurationMinutes();
                }
            }
        } catch (Exception e) {
            totalWorkMinutes = 0;
        }
        
        double totalWorkHours = totalWorkMinutes / 60.0;
        double completionRate = totalTasks > 0 ? (double) completedTasks / totalTasks * 100 : 0;
        
        // Get user's initials for avatar
        String initials = "";
        String[] nameParts = loggedInUser.getName().split(" ");
        for (String part : nameParts) {
            if (!part.isEmpty()) {
                initials += part.charAt(0);
            }
        }
        initials = initials.toUpperCase();
    %>

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-info">
        <div class="container-fluid">
            <a class="navbar-brand" href="<%= request.getContextPath() %>/">
                <i class="fas fa-user me-2"></i>My Profile
            </a>
            <div class="navbar-nav me-auto">
                <a class="nav-link" href="<%= request.getContextPath() %>/admin-dashboard.jsp">
                    <i class="fas fa-tachometer-alt me-1"></i>Dashboard
                </a>
                <a class="nav-link active" href="<%= request.getContextPath() %>/profile.jsp">
                    <i class="fas fa-user me-1"></i>Profile
                </a>
                <a class="nav-link" href="<%= request.getContextPath() %>/tasks.jsp">
                    <i class="fas fa-tasks me-1"></i>Tasks
                </a>
                <a class="nav-link" href="<%= request.getContextPath() %>/notifications.jsp">
                    <i class="fas fa-bell me-1"></i>Notifications
                </a>
            </div>
            <div class="navbar-nav">
                <a class="btn btn-outline-light" href="<%= request.getContextPath() %>/index.html">
                    <i class="fas fa-home me-1"></i>Home
                </a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <!-- Profile Header -->
        <div class="profile-header">
            <div class="row align-items-center">
                <div class="col-md-2 text-center">
                    <div class="profile-avatar mx-auto">
                        <%= initials %>
                    </div>
                </div>
                <div class="col-md-6">
                    <h1 class="mb-2"><%= loggedInUser.getName() %></h1>
                    <p class="mb-2">
                        <span class="badge role-badge bg-<%= loggedInUser.getRole() == Employee.Role.ADMIN ? "danger" : 
                                                              loggedInUser.getRole() == Employee.Role.MANAGER ? "warning" : "success" %>">
                            <%= loggedInUser.getRole() %>
                        </span>
                    </p>
                    <p class="mb-0">
                        <i class="fas fa-envelope me-2"></i><%= loggedInUser.getEmail() %>
                    </p>
                    <p class="mb-0">
                        <i class="fas fa-building me-2"></i><%= userDept != null ? userDept.getName() : "No Department" %>
                    </p>
                    <% if (manager != null) { %>
                        <p class="mb-0">
                            <i class="fas fa-user-tie me-2"></i>Reports to: <%= manager.getName() %>
                        </p>
                    <% } %>
                </div>
                <div class="col-md-4">
                    <div class="row">
                        <div class="col-6">
                            <div class="metric-card">
                                <div class="metric-number"><%= totalTasks %></div>
                                <div class="metric-label">Total Tasks</div>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="metric-card">
                                <div class="metric-number"><%= Math.round(completionRate) %>%</div>
                                <div class="metric-label">Completion Rate</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Personal Information -->
            <div class="col-lg-4 mb-4">
                <div class="info-card">
                    <div class="info-header">
                        <h5 class="mb-0">
                            <i class="fas fa-info-circle me-2"></i>Personal Information
                        </h5>
                    </div>
                    <div class="p-3">
                        <div class="row mb-3">
                            <div class="col-sm-4"><strong>Employee ID:</strong></div>
                            <div class="col-sm-8"><%= loggedInUser.getId() %></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-sm-4"><strong>Name:</strong></div>
                            <div class="col-sm-8"><%= loggedInUser.getName() %></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-sm-4"><strong>Email:</strong></div>
                            <div class="col-sm-8"><%= loggedInUser.getEmail() %></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-sm-4"><strong>Role:</strong></div>
                            <div class="col-sm-8">
                                <span class="badge bg-<%= loggedInUser.getRole() == Employee.Role.ADMIN ? "danger" : 
                                                          loggedInUser.getRole() == Employee.Role.MANAGER ? "warning" : "success" %>">
                                    <%= loggedInUser.getRole() %>
                                </span>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-sm-4"><strong>Department:</strong></div>
                            <div class="col-sm-8"><%= userDept != null ? userDept.getName() : "No Department" %></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-sm-4"><strong>Status:</strong></div>
                            <div class="col-sm-8">
                                <span class="badge bg-<%= loggedInUser.isActive() ? "success" : "danger" %>">
                                    <%= loggedInUser.isActive() ? "Active" : "Inactive" %>
                                </span>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-sm-4"><strong>Joined:</strong></div>
                            <div class="col-sm-8"><%= loggedInUser.getCreatedAt() != null ? loggedInUser.getCreatedAt() : "N/A" %></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Performance Metrics -->
            <div class="col-lg-4 mb-4">
                <div class="info-card">
                    <div class="info-header">
                        <h5 class="mb-0">
                            <i class="fas fa-chart-bar me-2"></i>Performance Metrics
                        </h5>
                    </div>
                    <div class="p-3">
                        <div class="metric-card">
                            <div class="metric-number text-primary"><%= totalTasks %></div>
                            <div class="metric-label">Total Tasks Assigned</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-number text-success"><%= completedTasks %></div>
                            <div class="metric-label">Tasks Completed</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-number text-warning"><%= inProgressTasks %></div>
                            <div class="metric-label">Tasks In Progress</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-number text-info"><%= pendingTasks %></div>
                            <div class="metric-label">Tasks Pending</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-number text-secondary"><%= String.format("%.1f", totalWorkHours) %>h</div>
                            <div class="metric-label">Total Work Hours</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Real-time Notifications -->
            <div class="col-lg-4 mb-4">
                <div class="info-card">
                    <div class="info-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">
                            <i class="fas fa-bell me-2"></i>Notifications
                            <span class="badge bg-danger ms-2" id="notificationCount"><%= userNotifications.size() %></span>
                        </h5>
                        <button class="btn btn-sm btn-outline-primary" onclick="refreshNotifications()">
                            <i class="fas fa-sync-alt"></i>
                        </button>
                    </div>
                    <div class="p-3" style="max-height: 400px; overflow-y: auto;" id="notificationsList">
                        <% if (userNotifications.isEmpty()) { %>
                            <div class="text-center text-muted py-4">
                                <i class="fas fa-bell-slash fa-2x mb-2"></i>
                                <p>No new notifications</p>
                            </div>
                        <% } else { %>
                            <% for (Notification notification : userNotifications) { %>
                                <div class="notification-item <%= notification.isRead() ? "" : "unread" %>" data-id="<%= notification.getId() %>">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div class="flex-grow-1">
                                            <div class="d-flex align-items-center mb-1">
                                                <%
                                                    String notifIcon = "fas fa-info-circle text-info";
                                                    String notifClass = "info";
                                                    if (notification.getNotificationType() != null) {
                                                        switch (notification.getNotificationType()) {
                                                            case TASK_ASSIGNED:
                                                                notifIcon = "fas fa-user-plus text-success";
                                                                notifClass = "success";
                                                                break;
                                                            case STATUS_CHANGED:
                                                                notifIcon = "fas fa-exchange-alt text-warning";
                                                                notifClass = "warning";
                                                                break;
                                                            case TASK_OVERDUE:
                                                                notifIcon = "fas fa-exclamation-triangle text-danger";
                                                                notifClass = "danger";
                                                                break;
                                                            case PRIORITY_ESCALATED:
                                                                notifIcon = "fas fa-arrow-up text-danger";
                                                                notifClass = "danger";
                                                                break;
                                                        }
                                                    }
                                                %>
                                                <i class="<%= notifIcon %> me-2"></i>
                                                <small class="text-muted"><%= notification.getCreatedAt() %></small>
                                                <% if (!notification.isRead()) { %>
                                                    <span class="badge bg-primary ms-2">New</span>
                                                <% } %>
                                            </div>
                                            <p class="mb-0 small"><%= notification.getMessage() %></p>
                                        </div>
                                        <% if (!notification.isRead()) { %>
                                            <button class="btn btn-sm btn-outline-secondary ms-2" data-notification-id="<%= notification.getId() %>" onclick="markAsRead(this.getAttribute('data-notification-id'))">
                                                <i class="fas fa-check"></i>
                                            </button>
                                        <% } %>
                                    </div>
                                </div>
                                <hr class="my-2">
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Work Sessions -->
        <div class="row">
            <div class="col-12">
                <div class="info-card">
                    <div class="info-header">
                        <h5 class="mb-0">
                            <i class="fas fa-clock me-2"></i>Recent Work Sessions
                        </h5>
                    </div>
                    <div class="p-3">
                        <% if (userSessions.isEmpty()) { %>
                            <p class="text-muted">No work sessions recorded yet.</p>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Task ID</th>
                                            <th>Start Time</th>
                                            <th>End Time</th>
                                            <th>Duration</th>
                                            <th>Notes</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (WorkSession workSession : userSessions) { %>
                                            <tr>
                                                <td><%= workSession.getTaskId() %></td>
                                                <td><%= workSession.getStartTime() %></td>
                                                <td>
                                                    <%= workSession.getEndTime() != null ? workSession.getEndTime() : 
                                                        "<span class='badge bg-warning'>Active</span>" %>
                                                </td>
                                                <td>
                                                    <%= workSession.getDurationMinutes() != null ? 
                                                        workSession.getDurationMinutes() + " min" : "N/A" %>
                                                </td>
                                                <td>
                                                    <%= workSession.getNotes() != null && !workSession.getNotes().isEmpty() ? 
                                                        workSession.getNotes() : "-" %>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="info-card">
                    <div class="info-header">
                        <h5 class="mb-0">
                            <i class="fas fa-tools me-2"></i>Profile Actions
                        </h5>
                    </div>
                    <div class="p-3">
                        <div class="row">
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/admin-dashboard.jsp" class="btn btn-primary">
                                        <i class="fas fa-tachometer-alt me-2"></i>Back to Dashboard
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/tasks.jsp" class="btn btn-success">
                                        <i class="fas fa-tasks me-2"></i>My Tasks
                                    </a>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <button class="btn btn-info" onclick="window.print()">
                                        <i class="fas fa-print me-2"></i>Print Profile
                                    </button>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <div class="d-grid">
                                    <a href="<%= request.getContextPath() %>/index.html" class="btn btn-outline-secondary">
                                        <i class="fas fa-sign-out-alt me-2"></i>Logout
                                    </a>
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
        // Real-time notifications functionality
        let notificationRefreshInterval;
        let lastNotificationCount = parseInt('<%= userNotifications.size() %>');
        
        // Start real-time notification checking
        document.addEventListener('DOMContentLoaded', function() {
            startNotificationPolling();
        });
        
        function startNotificationPolling() {
            // Check for new notifications every 30 seconds
            notificationRefreshInterval = setInterval(function() {
                refreshNotifications();
            }, 30000);
        }
        
        function refreshNotifications() {
            const refreshBtn = document.querySelector('[onclick="refreshNotifications()"] i');
            refreshBtn.classList.add('fa-spin');
            
            // Simulate fetching new notifications (in real app, this would be an AJAX call)
            setTimeout(function() {
                // For demo purposes, randomly add a new notification
                if (Math.random() > 0.7) {
                    addNewNotification();
                }
                refreshBtn.classList.remove('fa-spin');
            }, 1000);
        }
        
        function addNewNotification() {
            const notificationsList = document.getElementById('notificationsList');
            const notificationCount = document.getElementById('notificationCount');
            
            // Sample new notification
            const newNotification = document.createElement('div');
            newNotification.className = 'notification-item unread notification-pulse';
            newNotification.innerHTML = `
                <div class="d-flex justify-content-between align-items-start">
                    <div class="flex-grow-1">
                        <div class="d-flex align-items-center mb-1">
                            <i class="fas fa-info-circle text-info me-2"></i>
                            <small class="text-muted">Just now</small>
                            <span class="badge bg-primary ms-2">New</span>
                        </div>
                        <p class="mb-0 small">New system notification: Profile page refreshed successfully!</p>
                    </div>
                    <button class="btn btn-sm btn-outline-secondary ms-2" onclick="markAsRead(this)">
                        <i class="fas fa-check"></i>
                    </button>
                </div>
                <hr class="my-2">
            `;
            
            // Add to top of notifications list
            if (notificationsList.querySelector('.text-center')) {
                // Replace "no notifications" message
                notificationsList.innerHTML = '';
            }
            notificationsList.insertBefore(newNotification, notificationsList.firstChild);
            
            // Update count
            lastNotificationCount++;
            notificationCount.textContent = lastNotificationCount;
            notificationCount.classList.add('notification-pulse');assList.add('notification-pulse');
            
            // Remove pulse animation after 3 seconds
            setTimeout(function() {
                newNotification.classList.remove('notification-pulse');
                notificationCount.classList.remove('notification-pulse');
            }, 3000);
            
            // Show browser notification if supported
            if ('Notification' in window && Notification.permission === 'granted') {
                new Notification('Task Management System', {
                    body: 'You have a new notification!',
                    icon: '/favicon.ico'
                });
            }
        }
        
        function markAsRead(notificationId) {
            let notificationElement;
            
            if (typeof notificationId === 'string' || typeof notificationId === 'number') {
                // Find by data-notification-id or data-id
                notificationElement = document.querySelector(`[data-notification-id="${notificationId}"]`) || 
                                    document.querySelector(`[data-id="${notificationId}"]`);
            } else {
                // Button element passed directly
                notificationElement = notificationId.closest('.notification-item');
            }
            
            if (notificationElement) {
                notificationElement.classList.remove('unread', 'notification-pulse');
                const newBadge = notificationElement.querySelector('.badge.bg-primary');
                const markBtn = notificationElement.querySelector('button');
                
                if (newBadge) newBadge.remove();
                if (markBtn) markBtn.remove();
                
                // Update count
                const notificationCount = document.getElementById('notificationCount');
                if (lastNotificationCount > 0) {
                    lastNotificationCount--;
                    notificationCount.textContent = lastNotificationCount;
                }
                
                // In a real app, this would send an AJAX request to mark as read
                console.log('Marked notification as read:', notificationId);
            }
        }
        
        // Request notification permission on page load
        if ('Notification' in window && Notification.permission === 'default') {
            Notification.requestPermission();
        }
        
        // Clean up interval when page is unloaded
        window.addEventListener('beforeunload', function() {
            if (notificationRefreshInterval) {
                clearInterval(notificationRefreshInterval);
            }
        });
        
        // Add some interactive features
        function showUserSelector() {
            const users = [
                {id: 1, name: 'John Admin', role: 'ADMIN'},
                {id: 2, name: 'Alice Manager', role: 'MANAGER'},
                {id: 3, name: 'Tom Employee', role: 'EMPLOYEE'},
                {id: 4, name: 'Lisa Employee', role: 'EMPLOYEE'},
                {id: 5, name: 'Mark Employee', role: 'EMPLOYEE'}
            ];
            
            let currentUserId = parseInt('<%= loggedInUser.getId() %>');
            let options = users.map(user => 
                `<option value="${user.id}" ${user.id == currentUserId ? 'selected' : ''}>
                    ${user.name} (${user.role})
                </option>`
            ).join('');
            
            const select = `
                <select class="form-select" onchange="switchUser(this.value)">
                    <option value="">Select a user to view their profile...</option>
                    ${options}
                </select>
            `;
            
            document.querySelector('.profile-header .col-md-6').innerHTML += 
                `<div class="mt-3"><label class="form-label text-white">Switch User (Demo):</label>${select}</div>`;
        }
        
        function switchUser(userId) {
            if (userId) {
                window.location.href = 'profile.jsp?userId=' + userId;
            }
        }
        
        // Add user selector for demo purposes
        setTimeout(showUserSelector, 1000);
    </script>
</body>
</html>