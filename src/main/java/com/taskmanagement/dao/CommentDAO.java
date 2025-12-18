package com.taskmanagement.dao;

import com.taskmanagement.config.DatabaseConfig;
import com.taskmanagement.model.Comment;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Comment operations
 * Handles task comments for collaboration
 */
public class CommentDAO {
    
    /**
     * Add a comment to a task
     */
    public boolean addComment(Comment comment) {
        String sql = """
            INSERT INTO comments (task_id, employee_id, comment_text)
            VALUES (?, ?, ?)
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, comment.getTaskId());
            stmt.setInt(2, comment.getEmployeeId());
            stmt.setString(3, comment.getCommentText());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    comment.setId(generatedKeys.getInt(1));
                }
                return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get all comments for a task
     */
    public List<Comment> getCommentsForTask(int taskId) {
        String sql = """
            SELECT c.id, c.task_id, c.employee_id, c.comment_text, c.created_at, c.updated_at,
                   t.title as task_title, e.name as employee_name
            FROM comments c
            JOIN tasks t ON c.task_id = t.id
            JOIN employees e ON c.employee_id = e.id
            WHERE c.task_id = ?
            ORDER BY c.created_at ASC
        """;
        
        List<Comment> comments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                comments.add(mapResultSetToComment(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return comments;
    }
    
    /**
     * Get comment by ID
     */
    public Comment getCommentById(int commentId) {
        String sql = """
            SELECT c.id, c.task_id, c.employee_id, c.comment_text, c.created_at, c.updated_at,
                   t.title as task_title, e.name as employee_name
            FROM comments c
            JOIN tasks t ON c.task_id = t.id
            JOIN employees e ON c.employee_id = e.id
            WHERE c.id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, commentId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToComment(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Update comment text
     */
    public boolean updateComment(int commentId, String newText, int employeeId) {
        // First verify the comment belongs to the employee
        String checkSql = "SELECT employee_id FROM comments WHERE id = ?";
        String updateSql = "UPDATE comments SET comment_text = ? WHERE id = ? AND employee_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection()) {
            
            // Check ownership
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setInt(1, commentId);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next() && rs.getInt("employee_id") == employeeId) {
                // Update comment
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setString(1, newText);
                updateStmt.setInt(2, commentId);
                updateStmt.setInt(3, employeeId);
                
                return updateStmt.executeUpdate() > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Delete comment
     */
    public boolean deleteComment(int commentId, int employeeId) {
        String sql = "DELETE FROM comments WHERE id = ? AND employee_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, commentId);
            stmt.setInt(2, employeeId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get recent comments for employee (for dashboard)
     */
    public List<Comment> getRecentCommentsForEmployee(int employeeId, int limit) {
        String sql = """
            SELECT c.id, c.task_id, c.employee_id, c.comment_text, c.created_at, c.updated_at,
                   t.title as task_title, e.name as employee_name
            FROM comments c
            JOIN tasks t ON c.task_id = t.id
            JOIN employees e ON c.employee_id = e.id
            WHERE c.employee_id = ?
            ORDER BY c.created_at DESC
            LIMIT ?
        """;
        
        List<Comment> comments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            stmt.setInt(2, limit);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                comments.add(mapResultSetToComment(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return comments;
    }
    
    /**
     * Get comments for tasks in department
     */
    public List<Comment> getCommentsForDepartment(int departmentId, int limit) {
        String sql = """
            SELECT c.id, c.task_id, c.employee_id, c.comment_text, c.created_at, c.updated_at,
                   t.title as task_title, e.name as employee_name
            FROM comments c
            JOIN tasks t ON c.task_id = t.id
            JOIN employees e ON c.employee_id = e.id
            WHERE t.department_id = ?
            ORDER BY c.created_at DESC
            LIMIT ?
        """;
        
        List<Comment> comments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, departmentId);
            stmt.setInt(2, limit);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                comments.add(mapResultSetToComment(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return comments;
    }
    
    /**
     * Get comment count for task
     */
    public int getCommentCountForTask(int taskId) {
        String sql = "SELECT COUNT(*) FROM comments WHERE task_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Search comments by text
     */
    public List<Comment> searchComments(String searchText, Integer departmentId, int limit) {
        StringBuilder sql = new StringBuilder("""
            SELECT c.id, c.task_id, c.employee_id, c.comment_text, c.created_at, c.updated_at,
                   t.title as task_title, e.name as employee_name
            FROM comments c
            JOIN tasks t ON c.task_id = t.id
            JOIN employees e ON c.employee_id = e.id
            WHERE c.comment_text LIKE ?
        """);
        
        List<Object> params = new ArrayList<>();
        params.add("%" + searchText + "%");
        
        if (departmentId != null) {
            sql.append(" AND t.department_id = ?");
            params.add(departmentId);
        }
        
        sql.append(" ORDER BY c.created_at DESC LIMIT ?");
        params.add(limit);
        
        List<Comment> comments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                comments.add(mapResultSetToComment(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return comments;
    }
    
    /**
     * Get comments with pagination
     */
    public List<Comment> getCommentsForTaskPaginated(int taskId, int offset, int limit) {
        String sql = """
            SELECT c.id, c.task_id, c.employee_id, c.comment_text, c.created_at, c.updated_at,
                   t.title as task_title, e.name as employee_name
            FROM comments c
            JOIN tasks t ON c.task_id = t.id
            JOIN employees e ON c.employee_id = e.id
            WHERE c.task_id = ?
            ORDER BY c.created_at DESC
            LIMIT ? OFFSET ?
        """;
        
        List<Comment> comments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            stmt.setInt(2, limit);
            stmt.setInt(3, offset);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                comments.add(mapResultSetToComment(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return comments;
    }
    
    /**
     * Map ResultSet to Comment object
     */
    private Comment mapResultSetToComment(ResultSet rs) throws SQLException {
        Comment comment = new Comment();
        comment.setId(rs.getInt("id"));
        comment.setTaskId(rs.getInt("task_id"));
        comment.setTaskTitle(rs.getString("task_title"));
        comment.setEmployeeId(rs.getInt("employee_id"));
        comment.setEmployeeName(rs.getString("employee_name"));
        comment.setCommentText(rs.getString("comment_text"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            comment.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            comment.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return comment;
    }
}