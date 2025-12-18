package com.taskmanagement.model;

import java.time.LocalDateTime;

/**
 * Comment entity for task collaboration
 * Allows employees to add comments to tasks for communication
 */
public class Comment {
    
    private int id;
    private int taskId;
    private String taskTitle; // For display
    private int employeeId;
    private String employeeName; // For display
    private String commentText;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public Comment() {}
    
    public Comment(int taskId, int employeeId, String commentText) {
        this.taskId = taskId;
        this.employeeId = employeeId;
        this.commentText = commentText;
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
    
    public String getCommentText() {
        return commentText;
    }
    
    public void setCommentText(String commentText) {
        this.commentText = commentText;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    // Business logic methods
    
    /**
     * Check if comment was edited
     */
    public boolean isEdited() {
        return updatedAt != null && !updatedAt.equals(createdAt);
    }
    
    /**
     * Get time since comment was created
     */
    public String getTimeAgo() {
        if (createdAt == null) return "Unknown";
        
        LocalDateTime now = LocalDateTime.now();
        long minutes = java.time.Duration.between(createdAt, now).toMinutes();
        
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
     * Get truncated comment text for preview
     */
    public String getPreviewText(int maxLength) {
        if (commentText == null) return "";
        
        if (commentText.length() <= maxLength) {
            return commentText;
        }
        
        return commentText.substring(0, maxLength) + "...";
    }
    
    @Override
    public String toString() {
        return "Comment{" +
                "id=" + id +
                ", taskId=" + taskId +
                ", employeeId=" + employeeId +
                ", commentText='" + commentText + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}