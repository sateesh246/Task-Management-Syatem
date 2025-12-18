package com.taskmanagement.model;

import java.time.LocalDateTime;

/**
 * Department entity representing organizational departments
 */
public class Department {
    
    private int id;
    private String name;
    private String description;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Statistics fields for dashboard display
    private int employeeCount;
    private int activeTaskCount;
    private int completedTaskCount;
    
    // Constructors
    public Department() {}
    
    public Department(String name, String description) {
        this.name = name;
        this.description = description;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
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
    
    public int getEmployeeCount() {
        return employeeCount;
    }
    
    public void setEmployeeCount(int employeeCount) {
        this.employeeCount = employeeCount;
    }
    
    public int getActiveTaskCount() {
        return activeTaskCount;
    }
    
    public void setActiveTaskCount(int activeTaskCount) {
        this.activeTaskCount = activeTaskCount;
    }
    
    public int getCompletedTaskCount() {
        return completedTaskCount;
    }
    
    public void setCompletedTaskCount(int completedTaskCount) {
        this.completedTaskCount = completedTaskCount;
    }
    
    @Override
    public String toString() {
        return "Department{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", employeeCount=" + employeeCount +
                '}';
    }
}