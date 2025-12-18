package com.taskmanagement.model;

import java.time.LocalDateTime;

/**
 * Employee entity representing users in the system
 * Supports role-based access control with EMPLOYEE, MANAGER, ADMIN roles
 */
public class Employee {
    
    public enum Role {
        EMPLOYEE, MANAGER, ADMIN
    }
    
    private int id;
    private String name;
    private String email;
    private String password; // Will store hashed password
    private Role role;
    private int departmentId;
    private String departmentName; // For display purposes
    private Integer managerId;
    private String managerName; // For display purposes
    private boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public Employee() {}
    
    public Employee(String name, String email, String password, Role role, int departmentId) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.departmentId = departmentId;
        this.isActive = true;
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
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public Role getRole() {
        return role;
    }
    
    public void setRole(Role role) {
        this.role = role;
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
    
    public Integer getManagerId() {
        return managerId;
    }
    
    public void setManagerId(Integer managerId) {
        this.managerId = managerId;
    }
    
    public String getManagerName() {
        return managerName;
    }
    
    public void setManagerName(String managerName) {
        this.managerName = managerName;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
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
    
    // Utility methods for role checking
    public boolean isAdmin() {
        return role == Role.ADMIN;
    }
    
    public boolean isManager() {
        return role == Role.MANAGER;
    }
    
    public boolean isEmployee() {
        return role == Role.EMPLOYEE;
    }
    
    public boolean hasManagerPrivileges() {
        return role == Role.MANAGER || role == Role.ADMIN;
    }
    
    public boolean hasAdminPrivileges() {
        return role == Role.ADMIN;
    }
    
    @Override
    public String toString() {
        return "Employee{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", role=" + role +
                ", departmentId=" + departmentId +
                ", isActive=" + isActive +
                '}';
    }
}