package com.taskmanagement.servlet;

import com.taskmanagement.dao.NotificationDAO;
import com.taskmanagement.model.Employee;
import com.taskmanagement.model.Notification;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet for handling notification operations
 * Supports AJAX requests for real-time notification updates
 */
@WebServlet(name = "NotificationServlet", urlPatterns = {"/notifications", "/notifications/*"})
public class NotificationServlet extends HttpServlet {
    
    private static final Logger logger = Logger.getLogger(NotificationServlet.class.getName());
    private NotificationDAO notificationDAO;
    
    @Override
    public void init() throws ServletException {
        notificationDAO = new NotificationDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee currentUser = (Employee) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String pathInfo = request.getPathInfo();
        String action = request.getParameter("action");
        
        try {
            if ("api".equals(action)) {
                // AJAX request for notification data
                handleApiRequest(request, response, currentUser);
            } else if (pathInfo != null && pathInfo.startsWith("/count")) {
                // Get unread notification count
                handleCountRequest(request, response, currentUser);
            } else {
                // Regular page request
                handlePageRequest(request, response, currentUser);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error in NotificationServlet.doGet", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Database error occurred");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee currentUser = (Employee) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "markRead":
                    handleMarkRead(request, response, currentUser);
                    break;
                case "markAllRead":
                    handleMarkAllRead(request, response, currentUser);
                    break;
                case "delete":
                    handleDelete(request, response, currentUser);
                    break;
                case "deleteAll":
                    handleDeleteAll(request, response, currentUser);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error in NotificationServlet.doPost", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Database error occurred");
        }
    }
    
    private void handleApiRequest(HttpServletRequest request, HttpServletResponse response, 
                                Employee currentUser) throws SQLException, IOException {
        
        String type = request.getParameter("type");
        int limit = getIntParameter(request, "limit", 10);
        boolean unreadOnly = "true".equals(request.getParameter("unreadOnly"));
        
        List<Notification> notifications;
        
        if (unreadOnly) {
            notifications = notificationDAO.getUnreadNotifications(currentUser.getId(), limit);
        } else {
            notifications = notificationDAO.getNotificationsByRecipient(currentUser.getId(), limit);
        }
        
        // Return JSON response
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        out.print(buildNotificationJson(notifications));
        out.flush();
    }
    
    private void handleCountRequest(HttpServletRequest request, HttpServletResponse response, 
                                  Employee currentUser) throws SQLException, IOException {
        
        int unreadCount = notificationDAO.getUnreadNotificationCount(currentUser.getId());
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        out.print("{\"count\": " + unreadCount + "}");
        out.flush();
    }
    
    private void handlePageRequest(HttpServletRequest request, HttpServletResponse response, 
                                 Employee currentUser) throws SQLException, ServletException, IOException {
        
        // Get filter parameters
        String filter = request.getParameter("filter");
        if (filter == null) filter = "all";
        
        int page = getIntParameter(request, "page", 1);
        int pageSize = getIntParameter(request, "pageSize", 20);
        int offset = (page - 1) * pageSize;
        
        // Get notifications based on filter
        List<Notification> notifications;
        int totalCount;
        
        switch (filter) {
            case "unread":
                notifications = notificationDAO.getUnreadNotifications(currentUser.getId(), pageSize, offset);
                totalCount = notificationDAO.getUnreadNotificationCount(currentUser.getId());
                break;
            case "read":
                notifications = notificationDAO.getReadNotifications(currentUser.getId(), pageSize, offset);
                totalCount = notificationDAO.getReadNotificationCount(currentUser.getId());
                break;
            default:
                notifications = notificationDAO.getNotificationsByRecipient(currentUser.getId(), pageSize, offset);
                totalCount = notificationDAO.getTotalNotificationCount(currentUser.getId());
        }
        
        // Calculate pagination
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        
        // Set attributes for JSP
        request.setAttribute("notifications", notifications);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("filter", filter);
        request.setAttribute("currentUser", currentUser);
        
        // Get notification counts for filter tabs
        request.setAttribute("unreadCount", notificationDAO.getUnreadNotificationCount(currentUser.getId()));
        request.setAttribute("readCount", notificationDAO.getReadNotificationCount(currentUser.getId()));
        request.setAttribute("totalNotificationCount", notificationDAO.getTotalNotificationCount(currentUser.getId()));
        
        // Forward to JSP
        request.getRequestDispatcher("/notifications.jsp").forward(request, response);
    }
    
    private void handleMarkRead(HttpServletRequest request, HttpServletResponse response, 
                              Employee currentUser) throws SQLException, IOException {
        
        int notificationId = getIntParameter(request, "notificationId", -1);
        if (notificationId == -1) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Notification ID is required");
            return;
        }
        
        // Verify notification belongs to current user
        Notification notification = notificationDAO.getNotificationById(notificationId);
        if (notification == null || notification.getRecipientId() != currentUser.getId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        boolean success = notificationDAO.markAsRead(notificationId);
        
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            // AJAX request
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": " + success + "}");
            out.flush();
        } else {
            // Regular request
            String redirectUrl = request.getContextPath() + "/notifications";
            if (success) {
                redirectUrl += "?success=notification_marked_read";
            } else {
                redirectUrl += "?error=mark_read_failed";
            }
            response.sendRedirect(redirectUrl);
        }
    }
    
    private void handleMarkAllRead(HttpServletRequest request, HttpServletResponse response, 
                                 Employee currentUser) throws SQLException, IOException {
        
        boolean success = notificationDAO.markAllAsRead(currentUser.getId());
        
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            // AJAX request
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": " + success + "}");
            out.flush();
        } else {
            // Regular request
            String redirectUrl = request.getContextPath() + "/notifications";
            if (success) {
                redirectUrl += "?success=all_notifications_marked_read";
            } else {
                redirectUrl += "?error=mark_all_read_failed";
            }
            response.sendRedirect(redirectUrl);
        }
    }
    
    private void handleDelete(HttpServletRequest request, HttpServletResponse response, 
                             Employee currentUser) throws SQLException, IOException {
        
        int notificationId = getIntParameter(request, "notificationId", -1);
        if (notificationId == -1) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Notification ID is required");
            return;
        }
        
        // Verify notification belongs to current user
        Notification notification = notificationDAO.getNotificationById(notificationId);
        if (notification == null || notification.getRecipientId() != currentUser.getId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        boolean success = notificationDAO.deleteNotification(notificationId);
        
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            // AJAX request
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": " + success + "}");
            out.flush();
        } else {
            // Regular request
            String redirectUrl = request.getContextPath() + "/notifications";
            if (success) {
                redirectUrl += "?success=notification_deleted";
            } else {
                redirectUrl += "?error=delete_failed";
            }
            response.sendRedirect(redirectUrl);
        }
    }
    
    private void handleDeleteAll(HttpServletRequest request, HttpServletResponse response, 
                               Employee currentUser) throws SQLException, IOException {
        
        String type = request.getParameter("type");
        boolean success;
        
        if ("read".equals(type)) {
            success = notificationDAO.deleteReadNotifications(currentUser.getId());
        } else {
            success = notificationDAO.deleteAllNotifications(currentUser.getId());
        }
        
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            // AJAX request
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": " + success + "}");
            out.flush();
        } else {
            // Regular request
            String redirectUrl = request.getContextPath() + "/notifications";
            if (success) {
                redirectUrl += "?success=notifications_deleted";
            } else {
                redirectUrl += "?error=delete_all_failed";
            }
            response.sendRedirect(redirectUrl);
        }
    }
    
    private String buildNotificationJson(List<Notification> notifications) {
        StringBuilder json = new StringBuilder();
        json.append("{\"notifications\": [");
        
        for (int i = 0; i < notifications.size(); i++) {
            if (i > 0) json.append(",");
            
            Notification notification = notifications.get(i);
            json.append("{")
                .append("\"id\": ").append(notification.getId()).append(",")
                .append("\"type\": \"").append(escapeJson(notification.getNotificationType().name())).append("\",")
                .append("\"message\": \"").append(escapeJson(notification.getMessage())).append("\",")
                .append("\"isRead\": ").append(notification.isRead()).append(",")
                .append("\"taskId\": ").append(notification.getTaskId() != null ? notification.getTaskId() : "null").append(",")
                .append("\"createdAt\": \"").append(notification.getCreatedAt()).append("\",")
                .append("\"timeAgo\": \"").append(escapeJson(notification.getTimeAgo())).append("\"")
                .append("}");
        }
        
        json.append("]}");
        return json.toString();
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
    
    private int getIntParameter(HttpServletRequest request, String paramName, int defaultValue) {
        String paramValue = request.getParameter(paramName);
        if (paramValue == null || paramValue.trim().isEmpty()) {
            return defaultValue;
        }
        
        try {
            return Integer.parseInt(paramValue);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}