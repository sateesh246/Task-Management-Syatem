package com.taskmanagement.model;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * TaskActivityLog entity for audit trail
 * Tracks all changes made to tasks for compliance and debugging
 */
public class TaskActivityLog {
    
    public enum ActionType {
        CREATED("Task Created"),
        STATUS_CHANGED("Status Changed"),
        ASSIGNED("Employee Assigned"),
        UNASSIGNED("Employee Unassigned"),
        UPDATED("Task Updated"),
        PRIORITY_CHANGED("Priority Changed"),
        DUE_DATE_CHANGED("Due Date Changed"),
        DEPENDENCY_ADDED("Dependency Added"),
        DEPENDENCY_REMOVED("Dependency Removed"),
        COMMENT_ADDED("Comment Added"),
        WORK_SESSION_STARTED("Work Session Started"),
        WORK_SESSION_ENDED("Work Session Ended"),
        ATTACHMENT_ADDED("Attachment Added"),
        ATTACHMENT_REMOVED("Attachment Removed"),
        DELETED("Task Deleted");
        
        private final String displayName;
        
        ActionType(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
    
    private int id;
    private int taskId;
    private String taskTitle; // For display
    private int employeeId;
    private String employeeName; // For display
    private ActionType action;
    private String fieldName; // Which field was changed
    private String oldValue; // Previous value
    private String newValue; // New value
    private String description; // Human readable description
    private Timestamp createdAt;
    
    // Constructors
    public TaskActivityLog() {}
    
    public TaskActivityLog(int taskId, int employeeId, ActionType action, String description) {
        this.taskId = taskId;
        this.employeeId = employeeId;
        this.action = action;
        this.description = description;
    }
    
    public TaskActivityLog(int taskId, int employeeId, ActionType action, String fieldName, 
                          String oldValue, String newValue, String description) {
        this.taskId = taskId;
        this.employeeId = employeeId;
        this.action = action;
        this.fieldName = fieldName;
        this.oldValue = oldValue;
        this.newValue = newValue;
        this.description = description;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getTaskId() {
        return taskId;
    }
    
    public void setTaskId(int taskId) {
        this.taskId = taskId;
    }
    
    public String getTaskTitle() {
        return taskTitle;
    }
    
    public void setTaskTitle(String taskTitle) {
        this.taskTitle = taskTitle;
    }
    
    public int getEmployeeId() {
        return employeeId;
    }
    
    public void setEmployeeId(int employeeId) {
        this.employeeId = employeeId;
    }
    
    public String getEmployeeName() {
        return employeeName;
    }
    
    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }
    
    public ActionType getAction() {
        return action;
    }
    
    public void setAction(ActionType action) {
        this.action = action;
    }
    
    public String getFieldName() {
        return fieldName;
    }
    
    public void setFieldName(String fieldName) {
        this.fieldName = fieldName;
    }
    
    public String getOldValue() {
        return oldValue;
    }
    
    public void setOldValue(String oldValue) {
        this.oldValue = oldValue;
    }
    
    public String getNewValue() {
        return newValue;
    }
    
    public void setNewValue(String newValue) {
        this.newValue = newValue;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    // Business logic methods
    
    /**
     * Get time since activity occurred
     */
    public String getTimeAgo() {
        if (createdAt == null) return "Unknown";
        
        LocalDateTime now = LocalDateTime.now();
        long minutes = java.time.Duration.between(createdAt.toLocalDateTime(), now).toMinutes();
        
        if (minutes < 1) {
            return "Just now";
        } else if (minutes < 60) {
            return minutes + " minutes ago";
        } else if (minutes < 1440) { // 24 hours
            long hours = minutes / 60;
            return hours + " hours ago";
        } else {
            long days = minutes / 1440;
            return days + " days ago";
        }
    }
    
    /**
     * Get CSS class for action type
     */
    public String getActionClass() {
        switch (action) {
            case CREATED:
                return "activity-created";
            case STATUS_CHANGED:
                return "activity-status";
            case ASSIGNED:
            case UNASSIGNED:
                return "activity-assignment";
            case UPDATED:
            case PRIORITY_CHANGED:
            case DUE_DATE_CHANGED:
                return "activity-updated";
            case DEPENDENCY_ADDED:
            case DEPENDENCY_REMOVED:
                return "activity-dependency";
            case COMMENT_ADDED:
                return "activity-comment";
            case WORK_SESSION_STARTED:
            case WORK_SESSION_ENDED:
                return "activity-work";
            case ATTACHMENT_ADDED:
            case ATTACHMENT_REMOVED:
                return "activity-attachment";
            case DELETED:
                return "activity-deleted";
            default:
                return "activity-default";
        }
    }
    
    /**
     * Get icon for action type
     */
    public String getActionIcon() {
        switch (action) {
            case CREATED:
                return "fas fa-plus-circle";
            case STATUS_CHANGED:
                return "fas fa-exchange-alt";
            case ASSIGNED:
                return "fas fa-user-plus";
            case UNASSIGNED:
                return "fas fa-user-minus";
            case UPDATED:
                return "fas fa-edit";
            case PRIORITY_CHANGED:
                return "fas fa-exclamation";
            case DUE_DATE_CHANGED:
                return "fas fa-calendar";
            case DEPENDENCY_ADDED:
                return "fas fa-link";
            case DEPENDENCY_REMOVED:
                return "fas fa-unlink";
            case COMMENT_ADDED:
                return "fas fa-comment";
            case WORK_SESSION_STARTED:
                return "fas fa-play";
            case WORK_SESSION_ENDED:
                return "fas fa-stop";
            case ATTACHMENT_ADDED:
                return "fas fa-paperclip";
            case ATTACHMENT_REMOVED:
                return "fas fa-trash";
            case DELETED:
                return "fas fa-trash-alt";
            default:
                return "fas fa-info-circle";
        }
    }
    
    /**
     * Get formatted change description
     */
    public String getFormattedChange() {
        if (fieldName != null && oldValue != null && newValue != null) {
            return String.format("Changed %s from '%s' to '%s'", fieldName, oldValue, newValue);
        } else if (description != null) {
            return description;
        } else {
            return action.getDisplayName();
        }
    }
    
    @Override
    public String toString() {
        return "TaskActivityLog{" +
                "id=" + id +
                ", taskId=" + taskId +
                ", employeeId=" + employeeId +
                ", action=" + action +
                ", fieldName='" + fieldName + '\'' +
                ", oldValue='" + oldValue + '\'' +
                ", newValue='" + newValue + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}