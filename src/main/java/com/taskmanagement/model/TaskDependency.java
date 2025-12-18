package com.taskmanagement.model;

import java.sql.Timestamp;

/**
 * TaskDependency entity representing dependencies between tasks
 * Used for dependency chain management and circular dependency detection
 */
public class TaskDependency {
    
    private int id;
    private int taskId; // The task that depends on another
    private String taskTitle; // For display
    private String taskStatus; // For display
    private int dependsOnTaskId; // The task it depends on
    private String dependsOnTaskTitle; // For display
    private Task.Status dependsOnTaskStatus; // For checking if dependency is resolved
    private String dependsOnTaskPriority; // For display
    private Timestamp createdAt;
    private int createdBy;
    private String createdByName; // For display
    
    // Constructors
    public TaskDependency() {}
    
    public TaskDependency(int taskId, int dependsOnTaskId, int createdBy) {
        this.taskId = taskId;
        this.dependsOnTaskId = dependsOnTaskId;
        this.createdBy = createdBy;
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
    
    public String getTaskStatus() {
        return taskStatus;
    }
    
    public void setTaskStatus(String taskStatus) {
        this.taskStatus = taskStatus;
    }
    
    public int getDependsOnTaskId() {
        return dependsOnTaskId;
    }
    
    public void setDependsOnTaskId(int dependsOnTaskId) {
        this.dependsOnTaskId = dependsOnTaskId;
    }
    
    public String getDependsOnTaskTitle() {
        return dependsOnTaskTitle;
    }
    
    public void setDependsOnTaskTitle(String dependsOnTaskTitle) {
        this.dependsOnTaskTitle = dependsOnTaskTitle;
    }
    
    public Task.Status getDependsOnTaskStatus() {
        return dependsOnTaskStatus;
    }
    
    public void setDependsOnTaskStatus(Task.Status dependsOnTaskStatus) {
        this.dependsOnTaskStatus = dependsOnTaskStatus;
    }
    
    /**
     * Set depends on task status from string (for DAO compatibility)
     */
    public void setDependsOnTaskStatus(String status) {
        if (status != null) {
            this.dependsOnTaskStatus = Task.Status.valueOf(status);
        }
    }
    
    public String getDependsOnTaskPriority() {
        return dependsOnTaskPriority;
    }
    
    public void setDependsOnTaskPriority(String dependsOnTaskPriority) {
        this.dependsOnTaskPriority = dependsOnTaskPriority;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public int getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }
    
    public String getCreatedByName() {
        return createdByName;
    }
    
    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }
    
    // Business logic methods
    
    /**
     * Check if the dependency is resolved (blocking task is completed)
     */
    public boolean isResolved() {
        return dependsOnTaskStatus == Task.Status.COMPLETED;
    }
    
    /**
     * Check if the dependency is blocking (blocking task is not completed)
     */
    public boolean isBlocking() {
        return !isResolved();
    }
    
    /**
     * Get CSS class for dependency status display
     */
    public String getStatusClass() {
        return isResolved() ? "dependency-resolved" : "dependency-blocking";
    }
    
    /**
     * Get status text for display
     */
    public String getStatusText() {
        return isResolved() ? "Resolved" : "Blocking";
    }
    
    @Override
    public String toString() {
        return "TaskDependency{" +
                "id=" + id +
                ", taskId=" + taskId +
                ", dependsOnTaskId=" + dependsOnTaskId +
                ", dependsOnTaskStatus=" + dependsOnTaskStatus +
                ", createdAt=" + createdAt +
                '}';
    }
}