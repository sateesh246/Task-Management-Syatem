package com.taskmanagement.model;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * Notification entity for user notifications
 * Handles system notifications for task updates, assignments, etc.
 */
public class Notification {
    
    public enum NotificationType {
        TASK_ASSIGNED("Task Assigned"),
        STATUS_CHANGED("Status Changed"),
        TASK_OVERDUE("Task Overdue"),
        PRIORITY_ESCALATED("Priority Escalated"),
        APPROVAL_NEEDED("Approval Needed"),
        DEPENDENCY_RESOLVED("Dependency Resolved"),
        COMMENT_ADDED("Comment Added"),
        WORK_SESSION_REMINDER("Work Session Reminder"),
        DEADLINE_APPROACHING("Deadline Approaching");
        
        private final String displayName;
        
        NotificationType(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
    
    private int id;
    private int recipientId;
    private String recipientName; // For display
    private Integer taskId; // Can be null for system notifications
    private String taskTitle; // For display
    private NotificationType notificationType;
    private String message;
    private boolean isRead;
    private Timestamp createdAt;
    private Timestamp readAt;
    
    // Constructors
    public Notification() {}
    
    public Notification(int recipientId, Integer taskId, NotificationType notificationType, String message) {
        this.recipientId = recipientId;
        this.taskId = taskId;
        this.notificationType = notificationType;
        this.message = message;
        this.isRead = false;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getRecipientId() {
        return recipientId;
    }
    
    public void setRecipientId(int recipientId) {
        this.recipientId = recipientId;
    }
    
    public String getRecipientName() {
        return recipientName;
    }
    
    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }
    
    public Integer getTaskId() {
        return taskId;
    }
    
    public void setTaskId(Integer taskId) {
        this.taskId = taskId;
    }
    
    public String getTaskTitle() {
        return taskTitle;
    }
    
    public void setTaskTitle(String taskTitle) {
        this.taskTitle = taskTitle;
    }
    
    public NotificationType getNotificationType() {
        return notificationType;
    }
    
    public void setNotificationType(NotificationType notificationType) {
        this.notificationType = notificationType;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public boolean isRead() {
        return isRead;
    }
    
    public void setRead(boolean read) {
        isRead = read;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getReadAt() {
        return readAt;
    }
    
    public void setReadAt(Timestamp readAt) {
        this.readAt = readAt;
    }
    
    // Business logic methods
    
    /**
     * Mark notification as read
     */
    public void markAsRead() {
        this.isRead = true;
        this.readAt = Timestamp.valueOf(LocalDateTime.now());
    }
    
    /**
     * Get time since notification was created
     */
    public String getTimeAgo() {
        if (createdAt == null) return "Unknown";
        
        LocalDateTime now = LocalDateTime.now();
        long minutes = java.time.Duration.between(createdAt.toLocalDateTime(), now).toMinutes();
        
        if (minutes < 1) {
            return "Just now";
        } else if (minutes < 60) {
            return minutes + "m ago";
        } else if (minutes < 1440) { // 24 hours
            long hours = minutes / 60;
            return hours + "h ago";
        } else {
            long days = minutes / 1440;
            return days + "d ago";
        }
    }
    
    /**
     * Get CSS class for notification type
     */
    public String getTypeClass() {
        switch (notificationType) {
            case TASK_ASSIGNED:
                return "notification-info";
            case STATUS_CHANGED:
                return "notification-primary";
            case TASK_OVERDUE:
            case DEADLINE_APPROACHING:
                return "notification-warning";
            case PRIORITY_ESCALATED:
                return "notification-danger";
            case APPROVAL_NEEDED:
                return "notification-warning";
            case DEPENDENCY_RESOLVED:
            case COMMENT_ADDED:
                return "notification-success";
            default:
                return "notification-secondary";
        }
    }
    
    /**
     * Get icon for notification type
     */
    public String getTypeIcon() {
        switch (notificationType) {
            case TASK_ASSIGNED:
                return "fas fa-user-plus";
            case STATUS_CHANGED:
                return "fas fa-exchange-alt";
            case TASK_OVERDUE:
                return "fas fa-exclamation-triangle";
            case PRIORITY_ESCALATED:
                return "fas fa-arrow-up";
            case APPROVAL_NEEDED:
                return "fas fa-check-circle";
            case DEPENDENCY_RESOLVED:
                return "fas fa-link";
            case COMMENT_ADDED:
                return "fas fa-comment";
            case WORK_SESSION_REMINDER:
                return "fas fa-clock";
            case DEADLINE_APPROACHING:
                return "fas fa-calendar-exclamation";
            default:
                return "fas fa-bell";
        }
    }
    
    @Override
    public String toString() {
        return "Notification{" +
                "id=" + id +
                ", recipientId=" + recipientId +
                ", taskId=" + taskId +
                ", notificationType=" + notificationType +
                ", message='" + message + '\'' +
                ", isRead=" + isRead +
                ", createdAt=" + createdAt +
                '}';
    }
}