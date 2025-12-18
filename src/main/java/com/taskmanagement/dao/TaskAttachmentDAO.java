package com.taskmanagement.dao;

import com.taskmanagement.config.DatabaseConfig;
import com.taskmanagement.model.TaskAttachment;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for TaskAttachment operations
 * Handles file attachment metadata for tasks
 */
public class TaskAttachmentDAO {
    private static final Logger logger = Logger.getLogger(TaskAttachmentDAO.class.getName());
    
    public TaskAttachmentDAO() throws SQLException {
        // Constructor can be used for initialization if needed
    }
    
    /**
     * Create a new task attachment record
     */
    public boolean createTaskAttachment(TaskAttachment attachment) throws SQLException {
        String sql = "INSERT INTO task_attachments (task_id, filename, file_path, file_size, mime_type, uploaded_by) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, attachment.getTaskId());
            stmt.setString(2, attachment.getFilename());
            stmt.setString(3, attachment.getFilePath());
            stmt.setLong(4, attachment.getFileSize());
            stmt.setString(5, attachment.getMimeType());
            stmt.setInt(6, attachment.getUploadedBy());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        attachment.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
            
            return false;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error creating task attachment", e);
            throw e;
        }
    }
    
    /**
     * Get all attachments for a specific task
     */
    public List<TaskAttachment> getAttachmentsByTask(int taskId) throws SQLException {
        String sql = """
            SELECT ta.*, e.name as uploaded_by_name
            FROM task_attachments ta
            JOIN employees e ON ta.uploaded_by = e.id
            WHERE ta.task_id = ?
            ORDER BY ta.uploaded_at DESC
        """;
        
        List<TaskAttachment> attachments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskAttachment attachment = mapResultSetToTaskAttachment(rs);
                    attachments.add(attachment);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting attachments for task: " + taskId, e);
            throw e;
        }
        
        return attachments;
    }
    
    /**
     * Get attachment by ID
     */
    public TaskAttachment getAttachmentById(int attachmentId) throws SQLException {
        String sql = """
            SELECT ta.*, e.name as uploaded_by_name
            FROM task_attachments ta
            JOIN employees e ON ta.uploaded_by = e.id
            WHERE ta.id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, attachmentId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTaskAttachment(rs);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting attachment by ID: " + attachmentId, e);
            throw e;
        }
        
        return null;
    }
    
    /**
     * Delete an attachment record
     */
    public boolean deleteAttachment(int attachmentId) throws SQLException {
        String sql = "DELETE FROM task_attachments WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, attachmentId);
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting attachment: " + attachmentId, e);
            throw e;
        }
    }
    
    /**
     * Delete all attachments for a task
     */
    public boolean deleteAllAttachmentsForTask(int taskId) throws SQLException {
        String sql = "DELETE FROM task_attachments WHERE task_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            return stmt.executeUpdate() >= 0; // Returns true even if 0 rows deleted
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting all attachments for task: " + taskId, e);
            throw e;
        }
    }
    
    /**
     * Get attachments uploaded by a specific user
     */
    public List<TaskAttachment> getAttachmentsByUploader(int uploaderId) throws SQLException {
        String sql = """
            SELECT ta.*, t.title as task_title
            FROM task_attachments ta
            JOIN tasks t ON ta.task_id = t.id
            WHERE ta.uploaded_by = ?
            ORDER BY ta.uploaded_at DESC
        """;
        
        List<TaskAttachment> attachments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, uploaderId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskAttachment attachment = mapResultSetToTaskAttachment(rs);
                    attachment.setTaskTitle(rs.getString("task_title"));
                    attachments.add(attachment);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting attachments by uploader: " + uploaderId, e);
            throw e;
        }
        
        return attachments;
    }
    
    /**
     * Get total file size for a task
     */
    public long getTotalFileSizeForTask(int taskId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(file_size), 0) FROM task_attachments WHERE task_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting total file size for task: " + taskId, e);
            throw e;
        }
        
        return 0L;
    }
    
    /**
     * Get attachment count for a task
     */
    public int getAttachmentCountForTask(int taskId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM task_attachments WHERE task_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting attachment count for task: " + taskId, e);
            throw e;
        }
        
        return 0;
    }
    
    /**
     * Search attachments by filename
     */
    public List<TaskAttachment> searchAttachmentsByFilename(String filename, int limit) throws SQLException {
        String sql = """
            SELECT ta.*, e.name as uploaded_by_name, t.title as task_title
            FROM task_attachments ta
            JOIN employees e ON ta.uploaded_by = e.id
            JOIN tasks t ON ta.task_id = t.id
            WHERE ta.filename LIKE ?
            ORDER BY ta.uploaded_at DESC
            LIMIT ?
        """;
        
        List<TaskAttachment> attachments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, "%" + filename + "%");
            stmt.setInt(2, limit);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskAttachment attachment = mapResultSetToTaskAttachment(rs);
                    attachment.setTaskTitle(rs.getString("task_title"));
                    attachments.add(attachment);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error searching attachments by filename: " + filename, e);
            throw e;
        }
        
        return attachments;
    }
    
    /**
     * Get attachments by file type (mime type)
     */
    public List<TaskAttachment> getAttachmentsByMimeType(String mimeType) throws SQLException {
        String sql = """
            SELECT ta.*, e.name as uploaded_by_name, t.title as task_title
            FROM task_attachments ta
            JOIN employees e ON ta.uploaded_by = e.id
            JOIN tasks t ON ta.task_id = t.id
            WHERE ta.mime_type = ?
            ORDER BY ta.uploaded_at DESC
        """;
        
        List<TaskAttachment> attachments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, mimeType);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskAttachment attachment = mapResultSetToTaskAttachment(rs);
                    attachment.setTaskTitle(rs.getString("task_title"));
                    attachments.add(attachment);
                }
            }
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting attachments by mime type: " + mimeType, e);
            throw e;
        }
        
        return attachments;
    }
    
    /**
     * Update attachment metadata
     */
    public boolean updateAttachment(TaskAttachment attachment) throws SQLException {
        String sql = "UPDATE task_attachments SET filename = ?, mime_type = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, attachment.getFilename());
            stmt.setString(2, attachment.getMimeType());
            stmt.setInt(3, attachment.getId());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating attachment", e);
            throw e;
        }
    }
    
    private TaskAttachment mapResultSetToTaskAttachment(ResultSet rs) throws SQLException {
        TaskAttachment attachment = new TaskAttachment();
        attachment.setId(rs.getInt("id"));
        attachment.setTaskId(rs.getInt("task_id"));
        attachment.setFilename(rs.getString("filename"));
        attachment.setFilePath(rs.getString("file_path"));
        attachment.setFileSize(rs.getLong("file_size"));
        attachment.setMimeType(rs.getString("mime_type"));
        attachment.setUploadedBy(rs.getInt("uploaded_by"));
        attachment.setUploadedAt(rs.getTimestamp("uploaded_at"));
        
        // Additional fields if available
        if (hasColumn(rs, "uploaded_by_name")) {
            attachment.setUploadedByName(rs.getString("uploaded_by_name"));
        }
        if (hasColumn(rs, "task_title")) {
            attachment.setTaskTitle(rs.getString("task_title"));
        }
        
        return attachment;
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