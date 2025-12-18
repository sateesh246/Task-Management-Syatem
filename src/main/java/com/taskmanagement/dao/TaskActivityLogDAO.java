package com.taskmanagement.dao;

import com.taskmanagement.config.DatabaseConfig;
import com.taskmanagement.model.TaskActivityLog;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for TaskActivityLog operations
 * Handles audit trail functionality for compliance and debugging
 */
public class TaskActivityLogDAO {
    
    /**
     * Log an activity
     */
    public boolean logActivity(TaskActivityLog activity) {
        String sql = """
            INSERT INTO task_activity_log (task_id, employee_id, action, field_name, old_value, new_value, description)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, activity.getTaskId());
            stmt.setInt(2, activity.getEmployeeId());
            stmt.setString(3, activity.getAction().name());
            stmt.setString(4, activity.getFieldName());
            stmt.setString(5, activity.getOldValue());
            stmt.setString(6, activity.getNewValue());
            stmt.setString(7, activity.getDescription());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    activity.setId(generatedKeys.getInt(1));
                }
                return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get activity log for a task
     */
    public List<TaskActivityLog> getActivityLogForTask(int taskId) {
        String sql = """
            SELECT tal.id, tal.task_id, tal.employee_id, tal.action, tal.field_name, 
                   tal.old_value, tal.new_value, tal.description, tal.created_at,
                   t.title as task_title, e.name as employee_name
            FROM task_activity_log tal
            JOIN tasks t ON tal.task_id = t.id
            JOIN employees e ON tal.employee_id = e.id
            WHERE tal.task_id = ?
            ORDER BY tal.created_at DESC
        """;
        
        List<TaskActivityLog> activities = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                activities.add(mapResultSetToActivityLog(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return activities;
    }
    
    /**
     * Get activity log for an employee
     */
    public List<TaskActivityLog> getActivityLogForEmployee(int employeeId, int limit) {
        String sql = """
            SELECT tal.id, tal.task_id, tal.employee_id, tal.action, tal.field_name, 
                   tal.old_value, tal.new_value, tal.description, tal.created_at,
                   t.title as task_title, e.name as employee_name
            FROM task_activity_log tal
            JOIN tasks t ON tal.task_id = t.id
            JOIN employees e ON tal.employee_id = e.id
            WHERE tal.employee_id = ?
            ORDER BY tal.created_at DESC
            LIMIT ?
        """;
        
        List<TaskActivityLog> activities = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            stmt.setInt(2, limit);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                activities.add(mapResultSetToActivityLog(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return activities;
    }
    
    /**
     * Get recent system-wide activity
     */
    public List<TaskActivityLog> getRecentSystemActivity(int limit) {
        String sql = """
            SELECT tal.id, tal.task_id, tal.employee_id, tal.action, tal.field_name, 
                   tal.old_value, tal.new_value, tal.description, tal.created_at,
                   t.title as task_title, e.name as employee_name
            FROM task_activity_log tal
            JOIN tasks t ON tal.task_id = t.id
            JOIN employees e ON tal.employee_id = e.id
            ORDER BY tal.created_at DESC
            LIMIT ?
        """;
        
        List<TaskActivityLog> activities = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                activities.add(mapResultSetToActivityLog(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return activities;
    }
    
    /**
     * Get activity log for department
     */
    public List<TaskActivityLog> getActivityLogForDepartment(int departmentId, int limit) {
        String sql = """
            SELECT tal.id, tal.task_id, tal.employee_id, tal.action, tal.field_name, 
                   tal.old_value, tal.new_value, tal.description, tal.created_at,
                   t.title as task_title, e.name as employee_name
            FROM task_activity_log tal
            JOIN tasks t ON tal.task_id = t.id
            JOIN employees e ON tal.employee_id = e.id
            WHERE t.department_id = ?
            ORDER BY tal.created_at DESC
            LIMIT ?
        """;
        
        List<TaskActivityLog> activities = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, departmentId);
            stmt.setInt(2, limit);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                activities.add(mapResultSetToActivityLog(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return activities;
    }
    
    /**
     * Get activity log by action type
     */
    public List<TaskActivityLog> getActivityLogByAction(TaskActivityLog.ActionType actionType, int limit) {
        String sql = """
            SELECT tal.id, tal.task_id, tal.employee_id, tal.action, tal.field_name, 
                   tal.old_value, tal.new_value, tal.description, tal.created_at,
                   t.title as task_title, e.name as employee_name
            FROM task_activity_log tal
            JOIN tasks t ON tal.task_id = t.id
            JOIN employees e ON tal.employee_id = e.id
            WHERE tal.action = ?
            ORDER BY tal.created_at DESC
            LIMIT ?
        """;
        
        List<TaskActivityLog> activities = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, actionType.name());
            stmt.setInt(2, limit);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                activities.add(mapResultSetToActivityLog(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return activities;
    }
    
    /**
     * Search activity log
     */
    public List<TaskActivityLog> searchActivityLog(String searchTerm, Integer departmentId, 
                                                  Integer employeeId, int limit) {
        StringBuilder sql = new StringBuilder("""
            SELECT tal.id, tal.task_id, tal.employee_id, tal.action, tal.field_name, 
                   tal.old_value, tal.new_value, tal.description, tal.created_at,
                   t.title as task_title, e.name as employee_name
            FROM task_activity_log tal
            JOIN tasks t ON tal.task_id = t.id
            JOIN employees e ON tal.employee_id = e.id
            WHERE (tal.description LIKE ? OR t.title LIKE ?)
        """);
        
        List<Object> params = new ArrayList<>();
        params.add("%" + searchTerm + "%");
        params.add("%" + searchTerm + "%");
        
        if (departmentId != null) {
            sql.append(" AND t.department_id = ?");
            params.add(departmentId);
        }
        
        if (employeeId != null) {
            sql.append(" AND tal.employee_id = ?");
            params.add(employeeId);
        }
        
        sql.append(" ORDER BY tal.created_at DESC LIMIT ?");
        params.add(limit);
        
        List<TaskActivityLog> activities = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                activities.add(mapResultSetToActivityLog(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return activities;
    }
    
    /**
     * Get activity count by action type (for analytics)
     */
    public List<Object[]> getActivityCountByAction(Integer departmentId) {
        StringBuilder sql = new StringBuilder("""
            SELECT tal.action, COUNT(*) as count
            FROM task_activity_log tal
        """);
        
        if (departmentId != null) {
            sql.append("""
                JOIN tasks t ON tal.task_id = t.id
                WHERE t.department_id = ?
            """);
        }
        
        sql.append(" GROUP BY tal.action ORDER BY count DESC");
        
        List<Object[]> results = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            if (departmentId != null) {
                stmt.setInt(1, departmentId);
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Object[] row = {
                    rs.getString("action"),
                    rs.getInt("count")
                };
                results.add(row);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return results;
    }
    
    /**
     * Delete old activity logs (cleanup)
     */
    public int deleteOldActivityLogs(int daysOld) {
        String sql = """
            DELETE FROM task_activity_log 
            WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, daysOld);
            return stmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    // Convenience methods for common logging scenarios
    
    /**
     * Log task creation
     */
    public boolean logTaskCreation(int taskId, int employeeId, String taskTitle) {
        TaskActivityLog activity = new TaskActivityLog(
            taskId, 
            employeeId, 
            TaskActivityLog.ActionType.CREATED, 
            "Task created: " + taskTitle
        );
        return logActivity(activity);
    }
    
    /**
     * Log status change
     */
    public boolean logStatusChange(int taskId, int employeeId, String oldStatus, String newStatus) {
        TaskActivityLog activity = new TaskActivityLog(
            taskId, 
            employeeId, 
            TaskActivityLog.ActionType.STATUS_CHANGED, 
            "status",
            oldStatus,
            newStatus,
            String.format("Status changed from %s to %s", oldStatus, newStatus)
        );
        return logActivity(activity);
    }
    
    /**
     * Log assignment
     */
    public boolean logAssignment(int taskId, int assignedBy, int assigneeId, String assigneeName) {
        TaskActivityLog activity = new TaskActivityLog(
            taskId, 
            assignedBy, 
            TaskActivityLog.ActionType.ASSIGNED, 
            "Assigned to " + assigneeName
        );
        return logActivity(activity);
    }
    
    /**
     * Log priority change
     */
    public boolean logPriorityChange(int taskId, int employeeId, String oldPriority, String newPriority) {
        TaskActivityLog activity = new TaskActivityLog(
            taskId, 
            employeeId, 
            TaskActivityLog.ActionType.PRIORITY_CHANGED, 
            "priority",
            oldPriority,
            newPriority,
            String.format("Priority changed from %s to %s", oldPriority, newPriority)
        );
        return logActivity(activity);
    }
    
    /**
     * Get task activity with limit (alias for getActivityLogForTask)
     */
    public List<TaskActivityLog> getTaskActivity(int taskId, int limit) {
        String sql = """
            SELECT tal.id, tal.task_id, tal.employee_id, tal.action, tal.field_name, 
                   tal.old_value, tal.new_value, tal.description, tal.created_at,
                   t.title as task_title, e.name as employee_name
            FROM task_activity_log tal
            JOIN tasks t ON tal.task_id = t.id
            JOIN employees e ON tal.employee_id = e.id
            WHERE tal.task_id = ?
            ORDER BY tal.created_at DESC
            LIMIT ?
        """;
        
        List<TaskActivityLog> activities = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            stmt.setInt(2, limit);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                activities.add(mapResultSetToActivityLog(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return activities;
    }
    
    /**
     * Map ResultSet to TaskActivityLog object
     */
    private TaskActivityLog mapResultSetToActivityLog(ResultSet rs) throws SQLException {
        TaskActivityLog activity = new TaskActivityLog();
        activity.setId(rs.getInt("id"));
        activity.setTaskId(rs.getInt("task_id"));
        activity.setTaskTitle(rs.getString("task_title"));
        activity.setEmployeeId(rs.getInt("employee_id"));
        activity.setEmployeeName(rs.getString("employee_name"));
        activity.setAction(TaskActivityLog.ActionType.valueOf(rs.getString("action")));
        activity.setFieldName(rs.getString("field_name"));
        activity.setOldValue(rs.getString("old_value"));
        activity.setNewValue(rs.getString("new_value"));
        activity.setDescription(rs.getString("description"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            activity.setCreatedAt(createdAt);
        }
        
        return activity;
    }
}