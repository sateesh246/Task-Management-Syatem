<%@page import="com.taskmanagement.dao.NotificationDAO"%>
<%@page import="com.taskmanagement.dao.EmployeeDAO"%>
<%@page import="com.taskmanagement.dao.TaskDAO"%>
<%@page import="com.taskmanagement.model.Notification"%>
<%@page import="com.taskmanagement.model.Employee"%>
<%@page import="com.taskmanagement.model.Task"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications - Task Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .notification-card {
            transition: all 0.3s ease;
            border-left: 4px solid #dee2e6;
        }
        .notification-card.unread {
            border-left-color: #007bff;
            background-color: #f8f9fa;
        }
        .notification-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .notification-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        .notification-pulse {
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
        .live-indicator {
            display: inline-block;
            width: 8px;
            height: 8px;
            background-color: #28a745;
            border-radius: 50%;
            animation: blink 1s infinite;
        }
        @keyframes blink {
            0%, 50% { opacity: 1; }
            51%, 100% { opacity: 0.3; }
        }
    </style>
</head>
<body class="bg-light">
    <%
        // Initialize DAOs
        NotificationDAO notificationDAO = new NotificationDAO();
        EmployeeDAO employeeDAO = new EmployeeDAO();
        TaskDAO taskDAO = new TaskDAO();
        
        // Get user ID (demo purposes)
        int userId = 1;
        String userIdParam = request.getParameter("userId");
        if (userIdParam != null) {
            try {
                userId = Integer.parseInt(userIdParam);
            } catch (NumberFormatException e) {
                userId = 1;
            }
        }
        
        // Get user
        Employee currentUser = employeeDAO.getById(userId);
        if (currentUser == null) {
            List<Employee> allEmployees = employeeDAO.getAll(null, null, true);
            if (!allEmployees.isEmpty()) {
                currentUser = allEmployees.get(0);
            }
        }
        
        // Get notifications
        List<Notification> notifications = new ArrayList<>();
        try {
            notifications = notificationDAO.getNotificationsForUser(userId, false, 50);
        } catch (Exception e) {
            // Create sample notifications for demo
            notifications = createSampleNotifications(userId);
        }
        
        // Count unread notifications
        int unreadCount = 0;
        for (Notification notif : notifications) {
            if (!notif.isRead()) {
                unreadCount++;
            }
        }
    %>
    
    <%!
        // Helper method to create sample notifications
        private List<Notification> createSampleNotifications(int userId) {
            List<Notification> sampleNotifications = new ArrayList<>();
            
            // Create sample notifications
            Notification notif1 = new Notification();
            notif1.setId(1);
            notif1.setRecipientId(userId);
            notif1.setTaskId(1);
            notif1.setNotificationType(Notification.NotificationType.TASK_ASSIGNED);
            notif1.setMessage("You have been assigned to task: Setup CI/CD Pipeline");
            notif1.setRead(false);
            sampleNotifications.add(notif1);
            
            Notification notif2 = new Notification();
            notif2.setId(2);
            notif2.setRecipientId(userId);
            notif2.setTaskId(2);
            notif2.setNotificationType(Notification.NotificationType.STATUS_CHANGED);
            notif2.setMessage("Task 'Database Optimization' status changed to IN_PROGRESS");
            notif2.setRead(false);
            sampleNotifications.add(notif2);
            
            Notification notif3 = new Notification();
            notif3.setId(3);
            notif3.setRecipientId(userId);
            notif3.setTaskId(3);
            notif3.setNotificationType(Notification.NotificationType.TASK_OVERDUE);
            notif3.setMessage("Task 'API Documentation' is overdue and requires immediate attention");
            notif3.setRead(true);
            sampleNotifications.add(notif3);
            
            Notification notif4 = new Notification();
            notif4.setId(4);
            notif4.setRecipientId(userId);
            notif4.setTaskId(4);
            notif4.setNotificationType(Notification.NotificationType.PRIORITY_ESCALATED);
            notif4.setMessage("Task 'Security Audit' priority has been escalated to HIGH");
            notif4.setRead(false);
            sampleNotifications.add(notif4);
            
            return sampleNotifications;
        }
    %>

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="<%= request.getContextPath() %>/">
                <i class="fas fa-bell me-2"></i>Notifications
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/admin-dashboard.jsp">
                            <i class="fas fa-tachometer-alt me-1"></i>Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/tasks.jsp">
                            <i class="fas fa-tasks me-1"></i>Tasks
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="<%= request.getContextPath() %>/notifications.jsp">
                            <i class="fas fa-bell me-1"></i>Notifications
                            <% if (unreadCount > 0) { %>
                                <span class="badge bg-danger ms-1"><%= unreadCount %></span>
                            <% } %>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/profile.jsp">
                            <i class="fas fa-user me-1"></i>Profile
                        </a>
                    </li>
                </ul>
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <span class="navbar-text">
                            <span class="live-indicator"></span>
                            <small class="ms-1">Live Updates</small>
                        </span>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <!-- Header -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2><i class="fas fa-bell me-2"></i>Notifications</h2>
                        <p class="text-muted mb-0">
                            <% if (currentUser != null) { %>
                                Showing notifications for <%= currentUser.getName() %>
                            <% } %>
                            • <span id="totalCount"><%= notifications.size() %></span> total, 
                            <span id="unreadCount"><%= unreadCount %></span> unread
                        </p>
                    </div>
                    <div>
                        <button class="btn btn-outline-primary me-2" onclick="refreshNotifications()">
                            <i class="fas fa-sync-alt me-1"></i>Refresh
                        </button>
                        <% if (unreadCount > 0) { %>
                            <button class="btn btn-success" onclick="markAllAsRead()">
                                <i class="fas fa-check-double me-1"></i>Mark All Read
                            </button>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-3">
                                <select class="form-select" id="statusFilter" onchange="filterNotifications()">
                                    <option value="">All Notifications</option>
                                    <option value="unread">Unread Only</option>
                                    <option value="read">Read Only</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <select class="form-select" id="typeFilter" onchange="filterNotifications()">
                                    <option value="">All Types</option>
                                    <option value="TASK_ASSIGNED">Task Assigned</option>
                                    <option value="STATUS_CHANGED">Status Changed</option>
                                    <option value="TASK_OVERDUE">Task Overdue</option>
                                    <option value="PRIORITY_ESCALATED">Priority Escalated</option>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <input type="text" class="form-control" id="searchFilter" placeholder="Search notifications..." onkeyup="filterNotifications()">
                            </div>
                            <div class="col-md-2">
                                <button class="btn btn-secondary w-100" onclick="clearFilters()">
                                    <i class="fas fa-times me-1"></i>Clear
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Notifications List -->
        <div class="row" id="notificationsList">
            <% if (notifications.isEmpty()) { %>
                <div class="col-12">
                    <div class="card text-center py-5">
                        <div class="card-body">
                            <i class="fas fa-bell-slash fa-3x text-muted mb-3"></i>
                            <h4>No Notifications</h4>
                            <p class="text-muted">You're all caught up! No new notifications at this time.</p>
                        </div>
                    </div>
                </div>
            <% } else { %>
                <% for (Notification notification : notifications) { %>
                    <div class="col-12 mb-3 notification-item" 
                         data-read="<%= notification.isRead() %>" 
                         data-type="<%= notification.getNotificationType() != null ? notification.getNotificationType().name() : "" %>"
                         data-message="<%= notification.getMessage().toLowerCase() %>">
                        <div class="card notification-card <%= notification.isRead() ? "" : "unread" %>">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-auto">
                                        <%
                                            String iconClass = "fas fa-info-circle";
                                            String iconBg = "bg-info";
                                            if (notification.getNotificationType() != null) {
                                                switch (notification.getNotificationType()) {
                                                    case TASK_ASSIGNED:
                                                        iconClass = "fas fa-user-plus";
                                                        iconBg = "bg-success";
                                                        break;
                                                    case STATUS_CHANGED:
                                                        iconClass = "fas fa-exchange-alt";
                                                        iconBg = "bg-warning";
                                                        break;
                                                    case TASK_OVERDUE:
                                                        iconClass = "fas fa-exclamation-triangle";
                                                        iconBg = "bg-danger";
                                                        break;
                                                    case PRIORITY_ESCALATED:
                                                        iconClass = "fas fa-arrow-up";
                                                        iconBg = "bg-danger";
                                                        break;
                                                }
                                            }
                                        %>
                                        <div class="notification-icon <%= iconBg %>">
                                            <i class="<%= iconClass %>"></i>
                                        </div>
                                    </div>
                                    <div class="col">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <div>
                                                <h6 class="mb-1">
                                                    <%= notification.getNotificationType() != null ? 
                                                        notification.getNotificationType().name().replace("_", " ") : "Notification" %>
                                                    <% if (!notification.isRead()) { %>
                                                        <span class="badge bg-primary ms-2">New</span>
                                                    <% } %>
                                                </h6>
                                                <p class="mb-1"><%= notification.getMessage() %></p>
                                                <small class="text-muted">
                                                    <i class="fas fa-clock me-1"></i>
                                                    <%= notification.getCreatedAt() != null ? notification.getCreatedAt() : "Just now" %>
                                                    <% if (notification.getTaskId() != null) { %>
                                                        • <i class="fas fa-tasks me-1"></i>Task #<%= notification.getTaskId() %>
                                                    <% } %>
                                                </small>
                                            </div>
                                            <div class="btn-group">
                                                <% if (!notification.isRead()) { %>
                                                    <button class="btn btn-sm btn-outline-success" data-notification-id="<%= notification.getId() %>" onclick="markAsRead(this.getAttribute('data-notification-id'))">
                                                        <i class="fas fa-check"></i>
                                                    </button>
                                                <% } %>
                                                <% if (notification.getTaskId() != null) { %>
                                                    <a href="<%= request.getContextPath() %>/task-detail.jsp?id=<%= notification.getTaskId() %>" 
                                                       class="btn btn-sm btn-outline-primary">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                <% } %>
                                                <button class="btn btn-sm btn-outline-danger" data-notification-id="<%= notification.getId() %>" onclick="deleteNotification(this.getAttribute('data-notification-id'))">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            <% } %>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let notificationRefreshInterval;
        let currentUnreadCount = parseInt('<%= unreadCount %>');
        
        // Start real-time updates
        document.addEventListener('DOMContentLoaded', function() {
            startRealTimeUpdates();
            
            // Request notification permission
            if ('Notification' in window && Notification.permission === 'default') {
                Notification.requestPermission();
            }
        });
        
        function startRealTimeUpdates() {
            // Refresh every 15 seconds
            notificationRefreshInterval = setInterval(function() {
                if (Math.random() > 0.8) { // 20% chance of new notification
                    addRandomNotification();
                }
            }, 15000);
        }
        
        function refreshNotifications() {
            const refreshBtn = document.querySelector('[onclick="refreshNotifications()"] i');
            refreshBtn.classList.add('fa-spin');
            
            setTimeout(function() {
                // Simulate refresh
                refreshBtn.classList.remove('fa-spin');
                
                // Maybe add a new notification
                if (Math.random() > 0.5) {
                    addRandomNotification();
                }
            }, 1000);
        }
        
        function addRandomNotification() {
            const messages = [
                "New task has been assigned to you",
                "Task deadline is approaching",
                "Your task has been approved",
                "Priority has been updated for your task",
                "New comment added to your task"
            ];
            
            const types = ['TASK_ASSIGNED', 'TASK_OVERDUE', 'STATUS_CHANGED', 'PRIORITY_ESCALATED'];
            const icons = ['fas fa-user-plus', 'fas fa-exclamation-triangle', 'fas fa-exchange-alt', 'fas fa-arrow-up'];
            const colors = ['bg-success', 'bg-danger', 'bg-warning', 'bg-danger'];
            
            const randomIndex = Math.floor(Math.random() * types.length);
            const message = messages[Math.floor(Math.random() * messages.length)];
            
            const notificationsList = document.getElementById('notificationsList');
            const newNotification = document.createElement('div');
            newNotification.className = 'col-12 mb-3 notification-item notification-pulse';
            newNotification.setAttribute('data-read', 'false');
            newNotification.setAttribute('data-type', types[randomIndex]);
            newNotification.setAttribute('data-message', message.toLowerCase());
            
            newNotification.innerHTML = `
                <div class="card notification-card unread">
                    <div class="card-body">
                        <div class="row align-items-center">
                            <div class="col-auto">
                                <div class="notification-icon ${colors[randomIndex]}">
                                    <i class="${icons[randomIndex]}"></i>
                                </div>
                            </div>
                            <div class="col">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <h6 class="mb-1">
                                            ${types[randomIndex].replace('_', ' ')}
                                            <span class="badge bg-primary ms-2">New</span>
                                        </h6>
                                        <p class="mb-1">${message}</p>
                                        <small class="text-muted">
                                            <i class="fas fa-clock me-1"></i>Just now
                                            • <i class="fas fa-tasks me-1"></i>Task #${Math.floor(Math.random() * 10) + 1}
                                        </small>
                                    </div>
                                    <div class="btn-group">
                                        <button class="btn btn-sm btn-outline-success" onclick="markAsRead(this)">
                                            <i class="fas fa-check"></i>
                                        </button>
                                        <button class="btn btn-sm btn-outline-danger" onclick="deleteNotification(this)">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            
            notificationsList.insertBefore(newNotification, notificationsList.firstChild);
            
            // Update counts
            currentUnreadCount++;
            updateCounts();
            
            // Remove pulse after 3 seconds
            setTimeout(function() {
                newNotification.classList.remove('notification-pulse');
            }, 3000);
            
            // Show browser notification
            if ('Notification' in window && Notification.permission === 'granted') {
                new Notification('Task Management System', {
                    body: message,
                    icon: '/favicon.ico'
                });
            }
        }
        
        function markAsRead(notificationId) {
            let notificationElement;
            
            if (typeof notificationId === 'string' || typeof notificationId === 'number') {
                notificationElement = document.querySelector(`[data-notification-id="${notificationId}"]`) || 
                                    document.querySelector(`[data-id="${notificationId}"]`);
            } else {
                notificationElement = notificationId.closest('.notification-item');
            }
            
            if (notificationElement && notificationElement.getAttribute('data-read') === 'false') {
                notificationElement.setAttribute('data-read', 'true');
                notificationElement.querySelector('.notification-card').classList.remove('unread');
                
                const newBadge = notificationElement.querySelector('.badge.bg-primary');
                const markBtn = notificationElement.querySelector('.btn-outline-success');
                
                if (newBadge) newBadge.remove();
                if (markBtn) markBtn.remove();
                
                currentUnreadCount--;
                updateCounts();
            }
        }
        
        function markAllAsRead() {
            const unreadNotifications = document.querySelectorAll('[data-read="false"]');
            unreadNotifications.forEach(function(notification) {
                markAsRead(notification);
            });
        }
        
        function deleteNotification(notificationId) {
            let notificationElement;
            
            if (typeof notificationId === 'string' || typeof notificationId === 'number') {
                notificationElement = document.querySelector(`[data-notification-id="${notificationId}"]`) || 
                                    document.querySelector(`[data-id="${notificationId}"]`);
            } else {
                notificationElement = notificationId.closest('.notification-item');
            }
            
            if (notificationElement) {
                if (notificationElement.getAttribute('data-read') === 'false') {
                    currentUnreadCount--;
                }
                
                notificationElement.style.transition = 'all 0.3s ease';
                notificationElement.style.opacity = '0';
                notificationElement.style.transform = 'translateX(100%)';
                
                setTimeout(function() {
                    notificationElement.remove();
                    updateCounts();
                }, 300);
            }
        }
        
        function updateCounts() {
            document.getElementById('unreadCount').textContent = currentUnreadCount;
            document.getElementById('totalCount').textContent = document.querySelectorAll('.notification-item').length;
            
            // Update navbar badge
            const navBadge = document.querySelector('.navbar .badge');
            if (navBadge) {
                if (currentUnreadCount > 0) {
                    navBadge.textContent = currentUnreadCount;
                } else {
                    navBadge.remove();
                }
            }
        }
        
        function filterNotifications() {
            const statusFilter = document.getElementById('statusFilter').value;
            const typeFilter = document.getElementById('typeFilter').value;
            const searchFilter = document.getElementById('searchFilter').value.toLowerCase();
            
            const notifications = document.querySelectorAll('.notification-item');
            
            notifications.forEach(function(notification) {
                let show = true;
                
                // Status filter
                if (statusFilter === 'unread' && notification.getAttribute('data-read') === 'true') {
                    show = false;
                } else if (statusFilter === 'read' && notification.getAttribute('data-read') === 'false') {
                    show = false;
                }
                
                // Type filter
                if (typeFilter && notification.getAttribute('data-type') !== typeFilter) {
                    show = false;
                }
                
                // Search filter
                if (searchFilter && !notification.getAttribute('data-message').includes(searchFilter)) {
                    show = false;
                }
                
                notification.style.display = show ? 'block' : 'none';
            });
        }
        
        function clearFilters() {
            document.getElementById('statusFilter').value = '';
            document.getElementById('typeFilter').value = '';
            document.getElementById('searchFilter').value = '';
            filterNotifications();
        }
        
        // Clean up on page unload
        window.addEventListener('beforeunload', function() {
            if (notificationRefreshInterval) {
                clearInterval(notificationRefreshInterval);
            }
        });
    </script>
</body>
</html>