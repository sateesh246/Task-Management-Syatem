package com.taskmanagement.model;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * TaskAttachment entity for file attachments (bonus feature)
 * Stores metadata for files attached to tasks
 */
public class TaskAttachment {
    
    private int id;
    private int taskId;
    private String taskTitle; // For display
    private String filename;
    private String filePath;
    private long fileSize;
    private String mimeType;
    private int uploadedBy;
    private String uploadedByName; // For display
    private Timestamp uploadedAt;
    
    // Constructors
    public TaskAttachment() {}
    
    public TaskAttachment(int taskId, String filename, String filePath, long fileSize, 
                         String mimeType, int uploadedBy) {
        this.taskId = taskId;
        this.filename = filename;
        this.filePath = filePath;
        this.fileSize = fileSize;
        this.mimeType = mimeType;
        this.uploadedBy = uploadedBy;
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
    
    public String getFilename() {
        return filename;
    }
    
    public void setFilename(String filename) {
        this.filename = filename;
    }
    
    public String getFilePath() {
        return filePath;
    }
    
    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }
    
    public long getFileSize() {
        return fileSize;
    }
    
    public void setFileSize(long fileSize) {
        this.fileSize = fileSize;
    }
    
    public String getMimeType() {
        return mimeType;
    }
    
    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }
    
    public int getUploadedBy() {
        return uploadedBy;
    }
    
    public void setUploadedBy(int uploadedBy) {
        this.uploadedBy = uploadedBy;
    }
    
    public String getUploadedByName() {
        return uploadedByName;
    }
    
    public void setUploadedByName(String uploadedByName) {
        this.uploadedByName = uploadedByName;
    }
    
    public Timestamp getUploadedAt() {
        return uploadedAt;
    }
    
    public void setUploadedAt(Timestamp uploadedAt) {
        this.uploadedAt = uploadedAt;
    }
    
    // Business logic methods
    
    /**
     * Get human-readable file size
     */
    public String getFormattedFileSize() {
        if (fileSize < 1024) {
            return fileSize + " B";
        } else if (fileSize < 1024 * 1024) {
            return String.format("%.1f KB", fileSize / 1024.0);
        } else if (fileSize < 1024 * 1024 * 1024) {
            return String.format("%.1f MB", fileSize / (1024.0 * 1024.0));
        } else {
            return String.format("%.1f GB", fileSize / (1024.0 * 1024.0 * 1024.0));
        }
    }
    
    /**
     * Get file extension
     */
    public String getFileExtension() {
        if (filename == null || !filename.contains(".")) {
            return "";
        }
        return filename.substring(filename.lastIndexOf(".") + 1).toLowerCase();
    }
    
    /**
     * Check if file is an image
     */
    public boolean isImage() {
        String ext = getFileExtension();
        return ext.equals("jpg") || ext.equals("jpeg") || ext.equals("png") || 
               ext.equals("gif") || ext.equals("bmp") || ext.equals("webp");
    }
    
    /**
     * Check if file is a document
     */
    public boolean isDocument() {
        String ext = getFileExtension();
        return ext.equals("pdf") || ext.equals("doc") || ext.equals("docx") || 
               ext.equals("xls") || ext.equals("xlsx") || ext.equals("ppt") || 
               ext.equals("pptx") || ext.equals("txt");
    }
    
    /**
     * Get CSS class for file type icon
     */
    public String getFileTypeIcon() {
        String ext = getFileExtension();
        
        switch (ext) {
            case "pdf":
                return "fas fa-file-pdf text-danger";
            case "doc":
            case "docx":
                return "fas fa-file-word text-primary";
            case "xls":
            case "xlsx":
                return "fas fa-file-excel text-success";
            case "ppt":
            case "pptx":
                return "fas fa-file-powerpoint text-warning";
            case "jpg":
            case "jpeg":
            case "png":
            case "gif":
            case "bmp":
            case "webp":
                return "fas fa-file-image text-info";
            case "zip":
            case "rar":
            case "7z":
                return "fas fa-file-archive text-secondary";
            case "txt":
                return "fas fa-file-alt text-muted";
            default:
                return "fas fa-file text-muted";
        }
    }
    
    /**
     * Get time since upload
     */
    public String getTimeAgo() {
        if (uploadedAt == null) return "Unknown";
        
        LocalDateTime now = LocalDateTime.now();
        long minutes = java.time.Duration.between(uploadedAt.toLocalDateTime(), now).toMinutes();
        
        if (minutes < 1) {
            return "Just now";
        } else if (minutes < 60) {
            return minutes + " minutes ago";
        } else if (minutes < 1440) { // 24 hours
            long hours = minutes / 60;
            return hours + " hours ago";
        } else {
            long days = minutes / 1440;
            return days + " days ago";
        }
    }
    
    /**
     * Check if file can be previewed in browser
     */
    public boolean canPreview() {
        return isImage() || getFileExtension().equals("pdf") || getFileExtension().equals("txt");
    }
    
    @Override
    public String toString() {
        return "TaskAttachment{" +
                "id=" + id +
                ", taskId=" + taskId +
                ", filename='" + filename + '\'' +
                ", fileSize=" + fileSize +
                ", mimeType='" + mimeType + '\'' +
                ", uploadedBy=" + uploadedBy +
                ", uploadedAt=" + uploadedAt +
                '}';
    }
}