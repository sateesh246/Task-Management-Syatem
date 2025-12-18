package com.taskmanagement.servlet;

import com.taskmanagement.dao.TaskAttachmentDAO;
import com.taskmanagement.dao.TaskDAO;
import com.taskmanagement.model.Employee;
import com.taskmanagement.model.Task;
import com.taskmanagement.model.TaskAttachment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet for handling file attachments
 * Supports file upload, download, and management
 */
@WebServlet(name = "AttachmentServlet", urlPatterns = {"/attachments", "/attachments/*"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class AttachmentServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(AttachmentServlet.class.getName());
    private static final String UPLOAD_DIR = "uploads";
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
    
    private TaskAttachmentDAO attachmentDAO;
    private TaskDAO taskDAO;
    
    @Override
    public void init() throws ServletException {
        try {
            attachmentDAO = new TaskAttachmentDAO();
            taskDAO = new TaskDAO();
        } catch (SQLException e) {
            throw new ServletException("Failed to initialize DAOs", e);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee currentUser = (Employee) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo != null && pathInfo.startsWith("/download/")) {
            try {
				handleDownload(request, response, currentUser);
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        } else {
            try {
				handleList(request, response, currentUser);
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (ServletException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Employee currentUser = (Employee) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            switch (action) {
                case "upload":
                    handleUpload(request, response, currentUser);
                    break;
                case "delete":
                    handleDelete(request, response, currentUser);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error in AttachmentServlet.doPost", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Database error occurred");
        }
    }
    
    private void handleUpload(HttpServletRequest request, HttpServletResponse response, 
                            Employee currentUser) throws SQLException, ServletException, IOException {
        
        int taskId = getIntParameter(request, "taskId", -1);
        if (taskId == -1) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Task ID is required");
            return;
        }
        
        // Verify task exists and user has access
        Task task = taskDAO.getTaskById(taskId);
        if (task == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
            return;
        }
        
        // Check permissions
        if (!canAccessTask(currentUser, task)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        // Create upload directory if it doesn't exist
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        try {
            Part filePart = request.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "No file uploaded");
                return;
            }
            
            // Validate file size
            if (filePart.getSize() > MAX_FILE_SIZE) {
                response.sendError(HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE, 
                    "File size exceeds maximum limit of 10MB");
                return;
            }
            
            // Get file info
            String originalFilename = getSubmittedFileName(filePart);
            String mimeType = filePart.getContentType();
            
            // Generate unique filename
            String fileExtension = getFileExtension(originalFilename);
            String uniqueFilename = UUID.randomUUID().toString() + fileExtension;
            String filePath = uploadPath + File.separator + uniqueFilename;
            
            // Save file
            filePart.write(filePath);
            
            // Create database record
            TaskAttachment attachment = new TaskAttachment();
            attachment.setTaskId(taskId);
            attachment.setFilename(originalFilename);
            attachment.setFilePath(UPLOAD_DIR + "/" + uniqueFilename);
            attachment.setFileSize(filePart.getSize());
            attachment.setMimeType(mimeType);
            attachment.setUploadedBy(currentUser.getId());
            
            boolean success = attachmentDAO.createTaskAttachment(attachment);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/tasks/" + taskId + 
                    "?success=file_uploaded");
            } else {
                // Delete the uploaded file if database insert failed
                new File(filePath).delete();
                response.sendRedirect(request.getContextPath() + "/tasks/" + taskId + 
                    "?error=upload_failed");
            }
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error uploading file", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "File upload failed");
        }
    }
    
    private void handleDownload(HttpServletRequest request, HttpServletResponse response, 
                              Employee currentUser) throws SQLException, IOException {
        
        String pathInfo = request.getPathInfo();
        String[] pathParts = pathInfo.split("/");
        
        if (pathParts.length < 3) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid download URL");
            return;
        }
        
        int attachmentId;
        try {
            attachmentId = Integer.parseInt(pathParts[2]);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid attachment ID");
            return;
        }
        
        // Get attachment info
        TaskAttachment attachment = attachmentDAO.getAttachmentById(attachmentId);
        if (attachment == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Attachment not found");
            return;
        }
        
        // Verify task access
        Task task = taskDAO.getTaskById(attachment.getTaskId());
        if (task == null || !canAccessTask(currentUser, task)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        // Get file path
        String filePath = getServletContext().getRealPath("") + File.separator + attachment.getFilePath();
        File file = new File(filePath);
        
        if (!file.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found on disk");
            return;
        }
        
        // Set response headers
        response.setContentType(attachment.getMimeType());
        response.setContentLengthLong(attachment.getFileSize());
        response.setHeader("Content-Disposition", 
            "attachment; filename=\"" + attachment.getFilename() + "\"");
        
        // Stream file to response
        try (FileInputStream fileIn = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = fileIn.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
            out.flush();
        }
    }
    
    private void handleDelete(HttpServletRequest request, HttpServletResponse response, 
                            Employee currentUser) throws SQLException, IOException {
        
        int attachmentId = getIntParameter(request, "attachmentId", -1);
        if (attachmentId == -1) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Attachment ID is required");
            return;
        }
        
        // Get attachment info
        TaskAttachment attachment = attachmentDAO.getAttachmentById(attachmentId);
        if (attachment == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Attachment not found");
            return;
        }
        
        // Verify permissions (only uploader, task creator, or admin can delete)
        Task task = taskDAO.getTaskById(attachment.getTaskId());
        if (task == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
            return;
        }
        
        if (attachment.getUploadedBy() != currentUser.getId() && 
            task.getCreatedBy() != currentUser.getId() &&
            currentUser.getRole() != Employee.Role.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        // Delete from database
        boolean success = attachmentDAO.deleteAttachment(attachmentId);
        
        if (success) {
            // Delete physical file
            String filePath = getServletContext().getRealPath("") + File.separator + attachment.getFilePath();
            File file = new File(filePath);
            if (file.exists()) {
                file.delete();
            }
            
            response.sendRedirect(request.getContextPath() + "/tasks/" + attachment.getTaskId() + 
                "?success=file_deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/tasks/" + attachment.getTaskId() + 
                "?error=delete_failed");
        }
    }
    
    private void handleList(HttpServletRequest request, HttpServletResponse response, 
                          Employee currentUser) throws SQLException, ServletException, IOException {
        
        int taskId = getIntParameter(request, "taskId", -1);
        if (taskId == -1) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Task ID is required");
            return;
        }
        
        // Verify task access
        Task task = taskDAO.getTaskById(taskId);
        if (task == null || !canAccessTask(currentUser, task)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        // Get attachments
        var attachments = attachmentDAO.getAttachmentsByTask(taskId);
        
        // Set attributes for JSP
        request.setAttribute("attachments", attachments);
        request.setAttribute("task", task);
        request.setAttribute("currentUser", currentUser);
        
        // Forward to JSP
        request.getRequestDispatcher("/attachments.jsp").forward(request, response);
    }
    
    private boolean canAccessTask(Employee user, Task task) throws SQLException {
        // Admins can access any task
        if (user.getRole() == Employee.Role.ADMIN) {
            return true;
        }
        
        // Managers can access tasks in their department
        if (user.getRole() == Employee.Role.MANAGER && 
            task.getDepartmentId() == user.getDepartmentId()) {
            return true;
        }
        
        // Task creator can access their tasks
        if (task.getCreatedBy() == user.getId()) {
            return true;
        }
        
        // Assigned employees can access their tasks
        return taskDAO.isEmployeeAssignedToTask(task.getId(), user.getId());
    }
    
    private String getSubmittedFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] tokens = contentDisposition.split(";");
        
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        
        return "unknown";
    }
    
    private String getFileExtension(String filename) {
        if (filename == null || filename.isEmpty()) {
            return "";
        }
        
        int lastDotIndex = filename.lastIndexOf('.');
        if (lastDotIndex == -1) {
            return "";
        }
        
        return filename.substring(lastDotIndex);
    }
    
    private int getIntParameter(HttpServletRequest request, String paramName, int defaultValue) {
        String paramValue = request.getParameter(paramName);
        if (paramValue == null || paramValue.trim().isEmpty()) {
            return defaultValue;
        }
        
        try {
            return Integer.parseInt(paramValue);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}