package com.taskmanagement.dao;

import com.taskmanagement.config.DatabaseConfig;
import com.taskmanagement.model.TaskDependency;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for TaskDependency operations
 * Handles task dependency relationships and circular dependency prevention
 */
public class TaskDependencyDAO {
    private static final Logger logger = Logger.getLogger(TaskDependencyDAO.class.getName());
    
    public TaskDependencyDAO() throws SQLException {
        // Constructor can be used for initialization if needed
    }
    
    /**
     * Create a new task dependency
     */
    public boolean createTaskDependency(TaskDependency dependency) throws SQLException {
        // First check for circular dependencies
        if (wouldCreateCircularDependency(dependency.getTaskId(), dependency.getDependsOnTaskId())) {
            throw new SQLException("Creating this dependency would result in a circular dependency");
        }
        
        String sql = "INSERT INTO task_dependencies (task_id, depends_on_task_id, created_by) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, dependency.getTaskId());
            stmt.setInt(2, dependency.getDependsOnTaskId());
            stmt.setInt(3, dependency.getCreatedBy());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        dependency.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
            
            return false;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error creating task dependency", e);
            throw e;
        }
    }
    
    /**
     * Get all dependencies for a specific task
     */
    public List<TaskDependency> getDependenciesForTask(int taskId) throws SQLException {
        String sql = """
            SELECT td.*, 
                   t.title as depends_on_task_title, 
                   t.status as depends_on_task_status,
                   t.priority as depends_on_task_priority,
                   creator.name as created_by_name
            FROM task_dependencies td
            JOIN tasks t ON td.depends_on_task_id = t.id
            JOIN employees creator ON td.created_by = creator.id
            WHERE td.task_id = ?
            ORDER BY td.created_at
        """;
        
        List<TaskDependency> dependencies = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskDependency dependency = mapResultSetToTaskDependency(rs);
                    dependencies.add(dependency);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting dependencies for task: " + taskId, e);
            throw e;
        }
        
        return dependencies;
    }
    
    /**
     * Get all tasks that depend on a specific task
     */
    public List<TaskDependency> getTasksDependingOn(int taskId) throws SQLException {
        String sql = """
            SELECT td.*, 
                   t.title as task_title, 
                   t.status as task_status,
                   creator.name as created_by_name
            FROM task_dependencies td
            JOIN tasks t ON td.task_id = t.id
            JOIN employees creator ON td.created_by = creator.id
            WHERE td.depends_on_task_id = ?
            ORDER BY td.created_at
        """;
        
        List<TaskDependency> dependencies = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskDependency dependency = mapResultSetToTaskDependency(rs);
                    dependency.setTaskTitle(rs.getString("task_title"));
                    dependency.setTaskStatus(rs.getString("task_status"));
                    dependencies.add(dependency);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting tasks depending on: " + taskId, e);
            throw e;
        }
        
        return dependencies;
    }
    
    /**
     * Remove a task dependency
     */
    public boolean removeTaskDependency(int taskId, int dependsOnTaskId) throws SQLException {
        String sql = "DELETE FROM task_dependencies WHERE task_id = ? AND depends_on_task_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            stmt.setInt(2, dependsOnTaskId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error removing task dependency", e);
            throw e;
        }
    }
    
    /**
     * Remove all dependencies for a task
     */
    public boolean removeAllDependenciesForTask(int taskId) throws SQLException {
        String sql = "DELETE FROM task_dependencies WHERE task_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            return stmt.executeUpdate() >= 0; // Returns true even if 0 rows deleted
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error removing all dependencies for task: " + taskId, e);
            throw e;
        }
    }
    
    /**
     * Check if a task is blocked by unresolved dependencies
     */
    public boolean isTaskBlocked(int taskId) throws SQLException {
        String sql = """
            SELECT COUNT(*) FROM task_dependencies td
            JOIN tasks t ON td.depends_on_task_id = t.id
            WHERE td.task_id = ? AND t.status NOT IN ('COMPLETED', 'CANCELLED')
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking if task is blocked", e);
            throw e;
        }
        
        return false;
    }
    
    /**
     * Check for circular dependencies using DFS algorithm
     */
    public boolean wouldCreateCircularDependency(int taskId, int dependsOnTaskId) throws SQLException {
        return hasPath(dependsOnTaskId, taskId, new ArrayList<>());
    }
    
    /**
     * DFS helper method to detect circular dependencies
     */
    private boolean hasPath(int fromTaskId, int toTaskId, List<Integer> visited) throws SQLException {
        if (fromTaskId == toTaskId) {
            return true;
        }
        
        if (visited.contains(fromTaskId)) {
            return false; // Already visited this node
        }
        
        visited.add(fromTaskId);
        
        String sql = "SELECT depends_on_task_id FROM task_dependencies WHERE task_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, fromTaskId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int nextTaskId = rs.getInt("depends_on_task_id");
                    if (hasPath(nextTaskId, toTaskId, new ArrayList<>(visited))) {
                        return true;
                    }
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking for circular dependency path", e);
            throw e;
        }
        
        return false;
    }
    
    /**
     * Get dependency by ID
     */
    public TaskDependency getDependencyById(int dependencyId) throws SQLException {
        String sql = """
            SELECT td.*, 
                   t.title as depends_on_task_title, 
                   t.status as depends_on_task_status,
                   creator.name as created_by_name
            FROM task_dependencies td
            JOIN tasks t ON td.depends_on_task_id = t.id
            JOIN employees creator ON td.created_by = creator.id
            WHERE td.id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, dependencyId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTaskDependency(rs);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting dependency by ID: " + dependencyId, e);
            throw e;
        }
        
        return null;
    }
    
    /**
     * Get all unresolved dependencies (blocking dependencies)
     */
    public List<TaskDependency> getUnresolvedDependencies() throws SQLException {
        String sql = """
            SELECT td.*, 
                   t1.title as task_title,
                   t1.status as task_status,
                   t2.title as depends_on_task_title, 
                   t2.status as depends_on_task_status,
                   creator.name as created_by_name
            FROM task_dependencies td
            JOIN tasks t1 ON td.task_id = t1.id
            JOIN tasks t2 ON td.depends_on_task_id = t2.id
            JOIN employees creator ON td.created_by = creator.id
            WHERE t2.status NOT IN ('COMPLETED', 'CANCELLED')
            AND t1.status NOT IN ('COMPLETED', 'CANCELLED')
            ORDER BY td.created_at
        """;
        
        List<TaskDependency> dependencies = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskDependency dependency = mapResultSetToTaskDependency(rs);
                    dependency.setTaskTitle(rs.getString("task_title"));
                    dependency.setTaskStatus(rs.getString("task_status"));
                    dependencies.add(dependency);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting unresolved dependencies", e);
            throw e;
        }
        
        return dependencies;
    }
    
    /**
     * Get dependency chain for a task (all tasks it depends on, recursively)
     */
    public List<Integer> getDependencyChain(int taskId) throws SQLException {
        List<Integer> chain = new ArrayList<>();
        getDependencyChainRecursive(taskId, chain, new ArrayList<>());
        return chain;
    }
    
    private void getDependencyChainRecursive(int taskId, List<Integer> chain, List<Integer> visited) throws SQLException {
        if (visited.contains(taskId)) {
            return; // Avoid infinite loops
        }
        
        visited.add(taskId);
        
        String sql = "SELECT depends_on_task_id FROM task_dependencies WHERE task_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int dependsOnTaskId = rs.getInt("depends_on_task_id");
                    if (!chain.contains(dependsOnTaskId)) {
                        chain.add(dependsOnTaskId);
                        getDependencyChainRecursive(dependsOnTaskId, chain, new ArrayList<>(visited));
                    }
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting dependency chain", e);
            throw e;
        }
    }
    
    private TaskDependency mapResultSetToTaskDependency(ResultSet rs) throws SQLException {
        TaskDependency dependency = new TaskDependency();
        dependency.setId(rs.getInt("id"));
        dependency.setTaskId(rs.getInt("task_id"));
        dependency.setDependsOnTaskId(rs.getInt("depends_on_task_id"));
        dependency.setCreatedAt(rs.getTimestamp("created_at"));
        dependency.setCreatedBy(rs.getInt("created_by"));
        
        // Additional fields if available
        if (hasColumn(rs, "depends_on_task_title")) {
            dependency.setDependsOnTaskTitle(rs.getString("depends_on_task_title"));
        }
        if (hasColumn(rs, "depends_on_task_status")) {
            dependency.setDependsOnTaskStatus(rs.getString("depends_on_task_status"));
        }
        if (hasColumn(rs, "depends_on_task_priority")) {
            dependency.setDependsOnTaskPriority(rs.getString("depends_on_task_priority"));
        }
        if (hasColumn(rs, "created_by_name")) {
            dependency.setCreatedByName(rs.getString("created_by_name"));
        }
        
        return dependency;
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