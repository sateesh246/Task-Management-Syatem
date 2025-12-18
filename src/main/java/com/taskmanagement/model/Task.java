package com.taskmanagement.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Task entity representing tasks in the system
 * Implements status workflow and supports optimistic locking for concurrent updates
 */
public class Task {
    
    public enum Priority {
        LOW, MEDIUM, HIGH
    }
    
    public enum Status {
        PENDING, IN_PROGRESS, UNDER_REVIEW, COMPLETED, CANCELLED, REJECTED
    }
    
    private int id;
    private String title;
    private String description;
    private Priority priority;
    private Status status;
    private LocalDate dueDate;
    private int departmentId;
    private String departmentName; // For display
    private int createdBy;
    private String createdByName; // For display
    private int version; // For optimistic locking
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Additional fields for display and business logic
    private List<TaskAssignment> assignments;
    private List<TaskDependency> dependencies;
    private List<TaskDependency> dependents; // Tasks that depend on this task
    private boolean isBlocked; // True if has incomplete dependencies
    private int workloadScore; // Calculated based on priority
    
    // Constructors
    public Task() {
        this.version = 1;
    }
    
    public Task(String title, String description, Priority priority, LocalDate dueDate, 
                int departmentId, int createdBy) {
        this.title = title;
        this.description = description;
        this.priority = priority;
        this.status = Status.PENDING;
        this.dueDate = dueDate;
        this.departmentId = departmentId;
        this.createdBy = createdBy;
        this.version = 1;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public Priority getPriority() {
        return priority;
    }
    
    public void setPriority(Priority priority) {
        this.priority = priority;
    }
    
    public Status getStatus() {
        return status;
    }
    
    public void setStatus(Status status) {
        this.status = status;
    }
    
    public LocalDate getDueDate() {
        return dueDate;
    }
    
    public void setDueDate(LocalDate dueDate) {
        this.dueDate = dueDate;
    }
    
    public int getDepartmentId() {
        return departmentId;
    }
    
    public void setDepartmentId(int departmentId) {
        this.departmentId = departmentId;
    }
    
    public String getDepartmentName() {
        return departmentName;
    }
    
    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
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
    
    public int getVersion() {
        return version;
    }
    
    public void setVersion(int version) {
        this.version = version;
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
    
    public List<TaskAssignment> getAssignments() {
        return assignments;
    }
    
    public void setAssignments(List<TaskAssignment> assignments) {
        this.assignments = assignments;
    }
    
    public List<TaskDependency> getDependencies() {
        return dependencies;
    }
    
    public void setDependencies(List<TaskDependency> dependencies) {
        this.dependencies = dependencies;
    }
    
    public List<TaskDependency> getDependents() {
        return dependents;
    }
    
    public void setDependents(List<TaskDependency> dependents) {
        this.dependents = dependents;
    }
    
    public boolean isBlocked() {
        return isBlocked;
    }
    
    public void setBlocked(boolean blocked) {
        isBlocked = blocked;
    }
    
    public int getWorkloadScore() {
        return workloadScore;
    }
    
    public void setWorkloadScore(int workloadScore) {
        this.workloadScore = workloadScore;
    }
    
    // Business logic methods
    
    /**
     * Check if status transition is valid based on workflow rules
     */
    public boolean canTransitionTo(Status newStatus, Employee.Role userRole) {
        if (status == newStatus) return false;
        
        switch (status) {
            case PENDING:
                return newStatus == Status.IN_PROGRESS || newStatus == Status.CANCELLED ||
                       (userRole == Employee.Role.ADMIN && (newStatus == Status.UNDER_REVIEW || newStatus == Status.COMPLETED));
                       
            case IN_PROGRESS:
                return newStatus == Status.UNDER_REVIEW || newStatus == Status.CANCELLED ||
                       (userRole == Employee.Role.ADMIN);
                       
            case UNDER_REVIEW:
                return (newStatus == Status.COMPLETED || newStatus == Status.REJECTED) && 
                       (userRole == Employee.Role.MANAGER || userRole == Employee.Role.ADMIN);
                       
            case REJECTED:
                return newStatus == Status.IN_PROGRESS || 
                       (userRole == Employee.Role.ADMIN);
                       
            case COMPLETED:
            case CANCELLED:
                return userRole == Employee.Role.ADMIN; // Only admin can reopen completed/cancelled tasks
                
            default:
                return false;
        }
    }
    
    /**
     * Get workload score based on priority
     */
    public int calculateWorkloadScore() {
        switch (priority) {
            case HIGH: return 3;
            case MEDIUM: return 2;
            case LOW: return 1;
            default: return 1;
        }
    }
    
    /**
     * Check if task is overdue
     */
    public boolean isOverdue() {
        return dueDate.isBefore(LocalDate.now()) && 
               (status != Status.COMPLETED && status != Status.CANCELLED);
    }
    
    /**
     * Get CSS class for priority display
     */
    public String getPriorityClass() {
        switch (priority) {
            case HIGH: return "priority-high";
            case MEDIUM: return "priority-medium";
            case LOW: return "priority-low";
            default: return "priority-low";
        }
    }
    
    /**
     * Get CSS class for status display
     */
    public String getStatusClass() {
        switch (status) {
            case PENDING: return "status-pending";
            case IN_PROGRESS: return "status-in-progress";
            case UNDER_REVIEW: return "status-under-review";
            case COMPLETED: return "status-completed";
            case CANCELLED: return "status-cancelled";
            case REJECTED: return "status-rejected";
            default: return "status-pending";
        }
    }
    
    @Override
    public String toString() {
        return "Task{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", priority=" + priority +
                ", status=" + status +
                ", dueDate=" + dueDate +
                ", version=" + version +
                '}';
    }
}