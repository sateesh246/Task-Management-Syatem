package com.taskmanagement.dao;

import com.taskmanagement.config.DatabaseConfig;
import com.taskmanagement.model.Notification;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Notification operations
 * Handles system notifications for user engagement
 */
public class NotificationDAO {
    
    /**
     * Create a new notification
     */
    public boolean createNotification(Notification notification) {
        String sql = """
            INSERT INTO notifications (recipient_id, task_id, notification_type, message)
            VALUES (?, ?, ?, ?)
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, notification.getRecipientId());
            
            if (notification.getTaskId() != null) {
                stmt.setInt(2, notification.getTaskId());
            } else {
                stmt.setNull(2, Types.INTEGER);
            }
            
            stmt.setString(3, notification.getNotificationType().name());
            stmt.setString(4, notification.getMessage());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    notification.setId(generatedKeys.getInt(1));
                }
                return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get unread notifications for a user
     */
    public List<Notification> getUnreadNotifications(int userId, int limit) {
        return getNotificationsForUser(userId, true, limit);
    }
    
    /**
     * Get notifications by recipient
     */
    public List<Notification> getNotificationsByRecipient(int userId, int limit) {
        return getNotificationsForUser(userId, false, limit);
    }
    
    /**
     * Get unread notifications with pagination
     */
    public List<Notification> getUnreadNotifications(int userId, int pageSize, int offset) {
        return getNotificationsForUserWithPagination(userId, true, pageSize, offset);
    }
    
    /**
     * Get notifications by recipient with pagination
     */
    public List<Notification> getNotificationsByRecipient(int userId, int pageSize, int offset) {
        return getNotificationsForUserWithPagination(userId, false, pageSize, offset);
    }
    
    /**
     * Get notifications for a user
     */
    public List<Notification> getNotificationsForUser(int userId, boolean unreadOnly, int limit) {
        StringBuilder sql = new StringBuilder("""
            SELECT n.id, n.recipient_id, n.task_id, n.notification_type, n.message, 
                   n.is_read, n.created_at, n.read_at,
                   e.name as recipient_name, t.title as task_title
            FROM notifications n
            JOIN employees e ON n.recipient_id = e.id
            LEFT JOIN tasks t ON n.task_id = t.id
            WHERE n.recipient_id = ?
        """);
        
        if (unreadOnly) {
            sql.append(" AND n.is_read = FALSE");
        }
        
        sql.append(" ORDER BY n.created_at DESC");
        
        if (limit > 0) {
            sql.append(" LIMIT ?");
        }
        
        List<Notification> notifications = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            stmt.setInt(1, userId);
            if (limit > 0) {
                stmt.setInt(2, limit);
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                notifications.add(mapResultSetToNotification(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return notifications;
    }
    
    /**
     * Get notifications for a user with pagination
     */
    public List<Notification> getNotificationsForUserWithPagination(int userId, boolean unreadOnly, int pageSize, int offset) {
        StringBuilder sql = new StringBuilder("""
            SELECT n.id, n.recipient_id, n.task_id, n.notification_type, n.message, 
                   n.is_read, n.created_at, n.read_at,
                   e.name as recipient_name, t.title as task_title
            FROM notifications n
            JOIN employees e ON n.recipient_id = e.id
            LEFT JOIN tasks t ON n.task_id = t.id
            WHERE n.recipient_id = ?
        """);
        
        if (unreadOnly) {
            sql.append(" AND n.is_read = FALSE");
        }
        
        sql.append(" ORDER BY n.created_at DESC LIMIT ? OFFSET ?");
        
        List<Notification> notifications = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, pageSize);
            stmt.setInt(3, offset);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                notifications.add(mapResultSetToNotification(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return notifications;
    }
    
    /**
     * Get unread notification count
     */
    public int getUnreadNotificationCount(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE recipient_id = ? AND is_read = FALSE";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Get total notification count
     */
    public int getTotalNotificationCount(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE recipient_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Get read notifications with pagination
     */
    public List<Notification> getReadNotifications(int userId, int pageSize, int offset) {
        String sql = """
            SELECT n.id, n.recipient_id, n.task_id, n.notification_type, n.message, 
                   n.is_read, n.created_at, n.read_at,
                   e.name as recipient_name, t.title as task_title
            FROM notifications n
            JOIN employees e ON n.recipient_id = e.id
            LEFT JOIN tasks t ON n.task_id = t.id
            WHERE n.recipient_id = ? AND n.is_read = TRUE
            ORDER BY n.created_at DESC LIMIT ? OFFSET ?
        """;
        
        List<Notification> notifications = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, pageSize);
            stmt.setInt(3, offset);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                notifications.add(mapResultSetToNotification(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return notifications;
    }
    
    /**
     * Get read notification count
     */
    public int getReadNotificationCount(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE recipient_id = ? AND is_read = TRUE";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Get notification by ID
     */
    public Notification getNotificationById(int notificationId) {
        String sql = """
            SELECT n.id, n.recipient_id, n.task_id, n.notification_type, n.message, 
                   n.is_read, n.created_at, n.read_at,
                   e.name as recipient_name, t.title as task_title
            FROM notifications n
            JOIN employees e ON n.recipient_id = e.id
            LEFT JOIN tasks t ON n.task_id = t.id
            WHERE n.id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, notificationId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToNotification(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Mark all notifications as read for a user
     */
    public boolean markAllAsRead(int userId) {
        String sql = """
            UPDATE notifications 
            SET is_read = TRUE, read_at = CURRENT_TIMESTAMP 
            WHERE recipient_id = ? AND is_read = FALSE
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            return stmt.executeUpdate() >= 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Delete a notification
     */
    public boolean deleteNotification(int notificationId) {
        String sql = "DELETE FROM notifications WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, notificationId);
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Delete read notifications for a user
     */
    public boolean deleteReadNotifications(int userId) {
        String sql = "DELETE FROM notifications WHERE recipient_id = ? AND is_read = TRUE";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            return stmt.executeUpdate() >= 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Delete all notifications for a user
     */
    public boolean deleteAllNotifications(int userId) {
        String sql = "DELETE FROM notifications WHERE recipient_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            return stmt.executeUpdate() >= 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Mark notification as read
     */
    public boolean markAsRead(int notificationId, int userId) {
        String sql = """
            UPDATE notifications 
            SET is_read = TRUE, read_at = CURRENT_TIMESTAMP 
            WHERE id = ? AND recipient_id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, notificationId);
            stmt.setInt(2, userId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Mark notification as read (overloaded for servlet compatibility)
     */
    public boolean markAsRead(int notificationId) {
        String sql = """
            UPDATE notifications 
            SET is_read = TRUE, read_at = CURRENT_TIMESTAMP 
            WHERE id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, notificationId);
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Mark all notifications as read for user
     */
    
    
    /**
     * Get unread notification count for user
     */
    public int getUnreadCount(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE recipient_id = ? AND is_read = FALSE";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Delete notification
     */
    public boolean deleteNotification(int notificationId, int userId) {
        String sql = "DELETE FROM notifications WHERE id = ? AND recipient_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, notificationId);
            stmt.setInt(2, userId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Delete old notifications (cleanup)
     */
    public int deleteOldNotifications(int daysOld) {
        String sql = """
            DELETE FROM notifications 
            WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, daysOld);
            return stmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Create task assignment notification
     */
    public boolean createTaskAssignmentNotification(int taskId, int assigneeId, int assignedBy) {
        String message = "You have been assigned to a new task";
        
        Notification notification = new Notification(
            assigneeId, 
            taskId, 
            Notification.NotificationType.TASK_ASSIGNED, 
            message
        );
        
        return createNotification(notification);
    }
    
    /**
     * Create status change notification
     */
    public boolean createStatusChangeNotification(int taskId, String oldStatus, String newStatus, 
                                                 List<Integer> recipientIds) {
        String message = String.format("Task status changed from %s to %s", 
                                     oldStatus.replace("_", " "), 
                                     newStatus.replace("_", " "));
        
        boolean allSuccess = true;
        
        for (int recipientId : recipientIds) {
            Notification notification = new Notification(
                recipientId, 
                taskId, 
                Notification.NotificationType.STATUS_CHANGED, 
                message
            );
            
            if (!createNotification(notification)) {
                allSuccess = false;
            }
        }
        
        return allSuccess;
    }
    
    /**
     * Create overdue task notification
     */
    public boolean createOverdueNotification(int taskId, List<Integer> recipientIds) {
        String message = "Task is overdue and requires attention";
        
        boolean allSuccess = true;
        
        for (int recipientId : recipientIds) {
            Notification notification = new Notification(
                recipientId, 
                taskId, 
                Notification.NotificationType.TASK_OVERDUE, 
                message
            );
            
            if (!createNotification(notification)) {
                allSuccess = false;
            }
        }
        
        return allSuccess;
    }
    
    /**
     * Create priority escalation notification
     */
    public boolean createPriorityEscalationNotification(int taskId, String newPriority, 
                                                       List<Integer> recipientIds) {
        String message = String.format("Task priority has been escalated to %s", newPriority);
        
        boolean allSuccess = true;
        
        for (int recipientId : recipientIds) {
            Notification notification = new Notification(
                recipientId, 
                taskId, 
                Notification.NotificationType.PRIORITY_ESCALATED, 
                message
            );
            
            if (!createNotification(notification)) {
                allSuccess = false;
            }
        }
        
        return allSuccess;
    }
    
    /**
     * Create approval needed notification
     */
    public boolean createApprovalNeededNotification(int taskId, int managerId) {
        String message = "Task requires your approval";
        
        Notification notification = new Notification(
            managerId, 
            taskId, 
            Notification.NotificationType.APPROVAL_NEEDED, 
            message
        );
        
        return createNotification(notification);
    }
    
    /**
     * Create dependency resolved notification
     */
    public boolean createDependencyResolvedNotification(int taskId, List<Integer> recipientIds) {
        String message = "Task dependencies have been resolved and task can now proceed";
        
        boolean allSuccess = true;
        
        for (int recipientId : recipientIds) {
            Notification notification = new Notification(
                recipientId, 
                taskId, 
                Notification.NotificationType.DEPENDENCY_RESOLVED, 
                message
            );
            
            if (!createNotification(notification)) {
                allSuccess = false;
            }
        }
        
        return allSuccess;
    }
    
    /**
     * Get notifications by type
     */
    public List<Notification> getNotificationsByType(int userId, Notification.NotificationType type, int limit) {
        String sql = """
            SELECT n.id, n.recipient_id, n.task_id, n.notification_type, n.message, 
                   n.is_read, n.created_at, n.read_at,
                   e.name as recipient_name, t.title as task_title
            FROM notifications n
            JOIN employees e ON n.recipient_id = e.id
            LEFT JOIN tasks t ON n.task_id = t.id
            WHERE n.recipient_id = ? AND n.notification_type = ?
            ORDER BY n.created_at DESC
            LIMIT ?
        """;
        
        List<Notification> notifications = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setString(2, type.name());
            stmt.setInt(3, limit);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                notifications.add(mapResultSetToNotification(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return notifications;
    }
    
    /**
     * Map ResultSet to Notification object
     */
    private Notification mapResultSetToNotification(ResultSet rs) throws SQLException {
        Notification notification = new Notification();
        notification.setId(rs.getInt("id"));
        notification.setRecipientId(rs.getInt("recipient_id"));
        notification.setRecipientName(rs.getString("recipient_name"));
        
        int taskId = rs.getInt("task_id");
        if (!rs.wasNull()) {
            notification.setTaskId(taskId);
            notification.setTaskTitle(rs.getString("task_title"));
        }
        
        notification.setNotificationType(
            Notification.NotificationType.valueOf(rs.getString("notification_type"))
        );
        notification.setMessage(rs.getString("message"));
        notification.setRead(rs.getBoolean("is_read"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            notification.setCreatedAt(createdAt);
        }
        
        Timestamp readAt = rs.getTimestamp("read_at");
        if (readAt != null) {
            notification.setReadAt(readAt);
        }
        
        return notification;
    }
}