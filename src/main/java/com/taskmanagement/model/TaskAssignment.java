package com.taskmanagement.model;

import java.sql.Timestamp;

/**
 * TaskAssignment entity representing task-employee assignments
 * Supports PRIMARY and SECONDARY assignment types
 */
public class TaskAssignment {
    
    public enum AssignmentType {
        PRIMARY, SECONDARY
    }
    
    private int id;
    private int taskId;
    private String taskTitle; // For display
    private String taskStatus; // For display
    private int employeeId;
    private String employeeName; // For display
    private String employeeEmail; // For display
    private AssignmentType assignmentType;
    private Timestamp assignedAt;
    private int assignedBy;
    private String assignedByName; // For display
    
    // Constructors
    public TaskAssignment() {}
    
    public TaskAssignment(int taskId, int employeeId, AssignmentType assignmentType, int assignedBy) {
        this.taskId = taskId;
        this.employeeId = employeeId;
        this.assignmentType = assignmentType;
        this.assignedBy = assignedBy;
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
    
    public String getEmployeeEmail() {
        return employeeEmail;
    }
    
    public void setEmployeeEmail(String employeeEmail) {
        this.employeeEmail = employeeEmail;
    }
    
    public AssignmentType getAssignmentType() {
        return assignmentType;
    }
    
    public void setAssignmentType(AssignmentType assignmentType) {
        this.assignmentType = assignmentType;
    }
    
    public Timestamp getAssignedAt() {
        return assignedAt;
    }
    
    public void setAssignedAt(Timestamp assignedAt) {
        this.assignedAt = assignedAt;
    }
    
    public int getAssignedBy() {
        return assignedBy;
    }
    
    public void setAssignedBy(int assignedBy) {
        this.assignedBy = assignedBy;
    }
    
    public String getAssignedByName() {
        return assignedByName;
    }
    
    public void setAssignedByName(String assignedByName) {
        this.assignedByName = assignedByName;
    }
    
    // Utility methods
    public boolean isPrimary() {
        return assignmentType == AssignmentType.PRIMARY;
    }
    
    public boolean isSecondary() {
        return assignmentType == AssignmentType.SECONDARY;
    }
    
    public String getAssignmentTypeClass() {
        return assignmentType == AssignmentType.PRIMARY ? "assignment-primary" : "assignment-secondary";
    }
    
    @Override
    public String toString() {
        return "TaskAssignment{" +
                "id=" + id +
                ", taskId=" + taskId +
                ", employeeId=" + employeeId +
                ", assignmentType=" + assignmentType +
                ", assignedAt=" + assignedAt +
                '}';
    }
}