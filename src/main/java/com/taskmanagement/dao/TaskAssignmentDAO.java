package com.taskmanagement.dao;

import com.taskmanagement.config.DatabaseConfig;
import com.taskmanagement.model.TaskAssignment;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for TaskAssignment operations
 * Handles task-employee assignment relationships
 */
public class TaskAssignmentDAO {
    private static final Logger logger = Logger.getLogger(TaskAssignmentDAO.class.getName());
    
    public TaskAssignmentDAO() throws SQLException {
        // Constructor can be used for initialization if needed
    }
    
    /**
     * Create a new task assignment
     */
    public boolean createTaskAssignment(TaskAssignment assignment) throws SQLException {
        String sql = "INSERT INTO task_assignments (task_id, employee_id, assignment_type, assigned_by) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, assignment.getTaskId());
            stmt.setInt(2, assignment.getEmployeeId());
            stmt.setString(3, assignment.getAssignmentType().name());
            stmt.setInt(4, assignment.getAssignedBy());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        assignment.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
            
            return false;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error creating task assignment", e);
            throw e;
        }
    }
    
    /**
     * Get all assignments for a specific task
     */
    public List<TaskAssignment> getAssignmentsByTask(int taskId) throws SQLException {
        String sql = """
            SELECT ta.*, e.name as employee_name, e.email as employee_email,
                   assigner.name as assigned_by_name
            FROM task_assignments ta
            JOIN employees e ON ta.employee_id = e.id
            JOIN employees assigner ON ta.assigned_by = assigner.id
            WHERE ta.task_id = ?
            ORDER BY ta.assignment_type, ta.assigned_at
        """;
        
        List<TaskAssignment> assignments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskAssignment assignment = mapResultSetToTaskAssignment(rs);
                    assignments.add(assignment);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting assignments for task: " + taskId, e);
            throw e;
        }
        
        return assignments;
    }
    
    /**
     * Get all assignments for a specific employee
     */
    public List<TaskAssignment> getAssignmentsByEmployee(int employeeId) throws SQLException {
        String sql = """
            SELECT ta.*, t.title as task_title, t.status as task_status,
                   assigner.name as assigned_by_name
            FROM task_assignments ta
            JOIN tasks t ON ta.task_id = t.id
            JOIN employees assigner ON ta.assigned_by = assigner.id
            WHERE ta.employee_id = ?
            ORDER BY ta.assigned_at DESC
        """;
        
        List<TaskAssignment> assignments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskAssignment assignment = mapResultSetToTaskAssignment(rs);
                    assignment.setTaskTitle(rs.getString("task_title"));
                    assignment.setTaskStatus(rs.getString("task_status"));
                    assignments.add(assignment);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting assignments for employee: " + employeeId, e);
            throw e;
        }
        
        return assignments;
    }
    
    /**
     * Check if an employee is assigned to a task
     */
    public boolean isEmployeeAssignedToTask(int taskId, int employeeId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM task_assignments WHERE task_id = ? AND employee_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            stmt.setInt(2, employeeId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking task assignment", e);
            throw e;
        }
        
        return false;
    }
    
    /**
     * Remove a task assignment
     */
    public boolean removeTaskAssignment(int taskId, int employeeId) throws SQLException {
        String sql = "DELETE FROM task_assignments WHERE task_id = ? AND employee_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            stmt.setInt(2, employeeId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error removing task assignment", e);
            throw e;
        }
    }
    
    /**
     * Remove all assignments for a task
     */
    public boolean removeAllTaskAssignments(int taskId) throws SQLException {
        String sql = "DELETE FROM task_assignments WHERE task_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            return stmt.executeUpdate() >= 0; // Returns true even if 0 rows deleted
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error removing all task assignments for task: " + taskId, e);
            throw e;
        }
    }
    
    /**
     * Get assignment by ID
     */
    public TaskAssignment getAssignmentById(int assignmentId) throws SQLException {
        String sql = """
            SELECT ta.*, e.name as employee_name, e.email as employee_email,
                   assigner.name as assigned_by_name
            FROM task_assignments ta
            JOIN employees e ON ta.employee_id = e.id
            JOIN employees assigner ON ta.assigned_by = assigner.id
            WHERE ta.id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, assignmentId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTaskAssignment(rs);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting assignment by ID: " + assignmentId, e);
            throw e;
        }
        
        return null;
    }
    
    /**
     * Update assignment type
     */
    public boolean updateAssignmentType(int assignmentId, TaskAssignment.AssignmentType newType) throws SQLException {
        String sql = "UPDATE task_assignments SET assignment_type = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, newType.name());
            stmt.setInt(2, assignmentId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating assignment type", e);
            throw e;
        }
    }
    
    /**
     * Get workload for employee (count of active assignments)
     */
    public int getEmployeeWorkload(int employeeId) throws SQLException {
        String sql = """
            SELECT COUNT(*) FROM task_assignments ta
            JOIN tasks t ON ta.task_id = t.id
            WHERE ta.employee_id = ? AND t.status IN ('PENDING', 'IN_PROGRESS', 'UNDER_REVIEW')
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting employee workload", e);
            throw e;
        }
        
        return 0;
    }
    
    private TaskAssignment mapResultSetToTaskAssignment(ResultSet rs) throws SQLException {
        TaskAssignment assignment = new TaskAssignment();
        assignment.setId(rs.getInt("id"));
        assignment.setTaskId(rs.getInt("task_id"));
        assignment.setEmployeeId(rs.getInt("employee_id"));
        assignment.setAssignmentType(TaskAssignment.AssignmentType.valueOf(rs.getString("assignment_type")));
        assignment.setAssignedAt(rs.getTimestamp("assigned_at"));
        assignment.setAssignedBy(rs.getInt("assigned_by"));
        
        // Additional fields if available
        if (hasColumn(rs, "employee_name")) {
            assignment.setEmployeeName(rs.getString("employee_name"));
        }
        if (hasColumn(rs, "employee_email")) {
            assignment.setEmployeeEmail(rs.getString("employee_email"));
        }
        if (hasColumn(rs, "assigned_by_name")) {
            assignment.setAssignedByName(rs.getString("assigned_by_name"));
        }
        
        return assignment;
    }
    
    private boolean hasColumn(ResultSet rs, String columnName) {
        try {
            rs.findColumn(columnName);
            return true;
        } catch (SQLException e) {
            return false;
        }
    }
}