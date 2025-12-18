package com.taskmanagement.model;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.Duration;

/**
 * WorkSession entity for time tracking functionality
 * Tracks employee work sessions on tasks for productivity analysis
 */
public class WorkSession {
    
    private int id;
    private int taskId;
    private String taskTitle; // For display
    private int employeeId;
    private String employeeName; // For display
    private Timestamp startTime;
    private Timestamp endTime;
    private Integer durationMinutes; // Calculated field
    private String notes;
    private Timestamp createdAt;
    
    // Constructors
    public WorkSession() {}
    
    public WorkSession(int taskId, int employeeId, Timestamp startTime, String notes) {
        this.taskId = taskId;
        this.employeeId = employeeId;
        this.startTime = startTime;
        this.notes = notes;
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
    
    public Timestamp getStartTime() {
        return startTime;
    }
    
    public void setStartTime(Timestamp startTime) {
        this.startTime = startTime;
    }
    
    public Timestamp getEndTime() {
        return endTime;
    }
    
    public void setEndTime(Timestamp endTime) {
        this.endTime = endTime;
    }
    
    public Integer getDurationMinutes() {
        return durationMinutes;
    }
    
    public void setDurationMinutes(Integer durationMinutes) {
        this.durationMinutes = durationMinutes;
    }
    
    public String getNotes() {
        return notes;
    }
    
    public void setNotes(String notes) {
        this.notes = notes;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    // Business logic methods
    
    /**
     * Check if session is currently active (no end time)
     */
    public boolean isActive() {
        return endTime == null;
    }
    
    /**
     * Calculate duration in minutes
     */
    public long calculateDurationMinutes() {
        if (startTime == null) return 0;
        
        LocalDateTime start = startTime.toLocalDateTime();
        LocalDateTime end = endTime != null ? endTime.toLocalDateTime() : LocalDateTime.now();
        return Duration.between(start, end).toMinutes();
    }
    
    /**
     * Get formatted duration string
     */
    public String getFormattedDuration() {
        long minutes = calculateDurationMinutes();
        long hours = minutes / 60;
        long remainingMinutes = minutes % 60;
        
        if (hours > 0) {
            return String.format("%d hours %d minutes", hours, remainingMinutes);
        } else {
            return String.format("%d minutes", remainingMinutes);
        }
    }
    
    /**
     * End the work session
     */
    public void endSession() {
        this.endTime = Timestamp.valueOf(LocalDateTime.now());
        this.durationMinutes = (int) calculateDurationMinutes();
    }
    
    @Override
    public String toString() {
        return "WorkSession{" +
                "id=" + id +
                ", taskId=" + taskId +
                ", employeeId=" + employeeId +
                ", startTime=" + startTime +
                ", endTime=" + endTime +
                ", durationMinutes=" + durationMinutes +
                '}';
    }
}