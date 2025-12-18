package com.taskmanagement.servlet;

import com.taskmanagement.dao.WorkSessionDAO;
import com.taskmanagement.dao.TaskDAO;
import com.taskmanagement.model.Employee;
import com.taskmanagement.model.WorkSession;
import com.taskmanagement.model.Task;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet for handling work session operations
 * Supports time tracking, session management, and productivity analytics
 */
@WebServlet(name = "WorkSessionServlet", urlPatterns = {"/work-sessions", "/work-sessions/*"})
public class WorkSessionServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(WorkSessionServlet.class.getName());
    
    private WorkSessionDAO workSessionDAO;
    private TaskDAO taskDAO;
    
    @Override
    public void init() throws ServletException {
        workSessionDAO = new WorkSessionDAO();
		taskDAO = new TaskDAO();
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
        String action = request.getParameter("action");
        
        try {
            if ("api".equals(action)) {
                handleApiRequest(request, response, currentUser);
            } else if (pathInfo != null && pathInfo.startsWith("/active")) {
                handleActiveSessionRequest(request, response, currentUser);
            } else {
                handlePageRequest(request, response, currentUser);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error in WorkSessionServlet.doGet", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Database error occurred");
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
                case "start":
                    handleStartSession(request, response, currentUser);
                    break;
                case "end":
                    handleEndSession(request, response, currentUser);
                    break;
                case "update":
                    handleUpdateSession(request, response, currentUser);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error in WorkSessionServlet.doPost", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Database error occurred");
        }
    }
    
    private void handleApiRequest(HttpServletRequest request, HttpServletResponse response, 
                                Employee currentUser) throws SQLException, IOException {
        
        String type = request.getParameter("type");
        
        if ("active".equals(type)) {
            // Get active sessions for current user
            List<WorkSession> activeSessions = workSessionDAO.getActiveSessionsByEmployee(currentUser.getId());
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            PrintWriter out = response.getWriter();
            out.print(buildSessionsJson(activeSessions));
            out.flush();
            
        } else if ("recent".equals(type)) {
            // Get recent sessions
            int limit = getIntParameter(request, "limit", 10);
            List<WorkSession> recentSessions = workSessionDAO.getRecentSessionsByEmployee(currentUser.getId(), limit);
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            PrintWriter out = response.getWriter();
            out.print(buildSessionsJson(recentSessions));
            out.flush();
        }
    }
    
    private void handleActiveSessionRequest(HttpServletRequest request, HttpServletResponse response, 
                                          Employee currentUser) throws SQLException, IOException {
        
        List<WorkSession> activeSessions = workSessionDAO.getActiveSessionsByEmployee(currentUser.getId());
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        out.print(buildSessionsJson(activeSessions));
        out.flush();
    }
    
    private void handlePageRequest(HttpServletRequest request, HttpServletResponse response, 
                                 Employee currentUser) throws SQLException, ServletException, IOException {
        
        // Get filter parameters
        int page = getIntParameter(request, "page", 1);
        int pageSize = getIntParameter(request, "pageSize", 20);
        int offset = (page - 1) * pageSize;
        
        // Get work sessions for current user
        List<WorkSession> sessions = workSessionDAO.getSessionsByEmployee(currentUser.getId(), pageSize, offset);
        int totalCount = workSessionDAO.getTotalSessionCount(currentUser.getId());
        
        // Get active sessions
        List<WorkSession> activeSessions = workSessionDAO.getActiveSessionsByEmployee(currentUser.getId());
        
        // Calculate pagination
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        
        // Set attributes for JSP
        request.setAttribute("sessions", sessions);
        request.setAttribute("activeSessions", activeSessions);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("currentUser", currentUser);
        
        // Forward to JSP
        request.getRequestDispatcher("/work-sessions.jsp").forward(request, response);
    }
    
    private void handleStartSession(HttpServletRequest request, HttpServletResponse response, 
                                  Employee currentUser) throws SQLException, IOException {
        
        int taskId = getIntParameter(request, "taskId", -1);
        String notes = request.getParameter("notes");
        
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
        
        // Check if user is assigned to this task
        if (!taskDAO.isEmployeeAssignedToTask(taskId, currentUser.getId()) && 
            currentUser.getRole() != Employee.Role.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, 
                "You are not assigned to this task");
            return;
        }
        
        // Check if user already has an active session for this task
        WorkSession existingSession = workSessionDAO.getActiveSessionByTaskAndEmployee(taskId, currentUser.getId());
        if (existingSession != null) {
            response.sendError(HttpServletResponse.SC_CONFLICT, 
                "You already have an active session for this task");
            return;
        }
        
        // Create new work session
        WorkSession session = new WorkSession();
        session.setTaskId(taskId);
        session.setEmployeeId(currentUser.getId());
        session.setStartTime(new Timestamp(System.currentTimeMillis()));
        session.setNotes(notes);
        
        boolean success = workSessionDAO.createWorkSession(session);
        
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            // AJAX request
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": " + success + "}");
            out.flush();
        } else {
            // Regular request
            String redirectUrl = request.getContextPath() + "/tasks/" + taskId;
            if (success) {
                redirectUrl += "?success=session_started";
            } else {
                redirectUrl += "?error=session_start_failed";
            }
            response.sendRedirect(redirectUrl);
        }
    }
    
    private void handleEndSession(HttpServletRequest request, HttpServletResponse response, 
                                Employee currentUser) throws SQLException, IOException {
        
        int sessionId = getIntParameter(request, "sessionId", -1);
        String notes = request.getParameter("notes");
        
        if (sessionId == -1) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Session ID is required");
            return;
        }
        
        // Verify session exists and belongs to current user
        WorkSession session = workSessionDAO.getWorkSessionById(sessionId);
        if (session == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Work session not found");
            return;
        }
        
        if (session.getEmployeeId() != currentUser.getId() && 
            currentUser.getRole() != Employee.Role.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        // End the session
        session.setEndTime(new Timestamp(System.currentTimeMillis()));
        if (notes != null && !notes.trim().isEmpty()) {
            session.setNotes(notes.trim());
        }
        
        boolean success = workSessionDAO.updateWorkSession(session);
        
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            // AJAX request
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": " + success + "}");
            out.flush();
        } else {
            // Regular request
            String redirectUrl = request.getContextPath() + "/tasks/" + session.getTaskId();
            if (success) {
                redirectUrl += "?success=session_ended";
            } else {
                redirectUrl += "?error=session_end_failed";
            }
            response.sendRedirect(redirectUrl);
        }
    }
    
    private void handleUpdateSession(HttpServletRequest request, HttpServletResponse response, 
                                   Employee currentUser) throws SQLException, IOException {
        
        int sessionId = getIntParameter(request, "sessionId", -1);
        String notes = request.getParameter("notes");
        
        if (sessionId == -1) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Session ID is required");
            return;
        }
        
        // Verify session exists and belongs to current user
        WorkSession session = workSessionDAO.getWorkSessionById(sessionId);
        if (session == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Work session not found");
            return;
        }
        
        if (session.getEmployeeId() != currentUser.getId() && 
            currentUser.getRole() != Employee.Role.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        // Update notes
        if (notes != null) {
            session.setNotes(notes.trim());
        }
        
        boolean success = workSessionDAO.updateWorkSession(session);
        
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            // AJAX request
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": " + success + "}");
            out.flush();
        } else {
            // Regular request
            String redirectUrl = request.getContextPath() + "/work-sessions";
            if (success) {
                redirectUrl += "?success=session_updated";
            } else {
                redirectUrl += "?error=session_update_failed";
            }
            response.sendRedirect(redirectUrl);
        }
    }
    
    private String buildSessionsJson(List<WorkSession> sessions) {
        StringBuilder json = new StringBuilder();
        json.append("{\"sessions\": [");
        
        for (int i = 0; i < sessions.size(); i++) {
            if (i > 0) json.append(",");
            
            WorkSession session = sessions.get(i);
            json.append("{")
                .append("\"id\": ").append(session.getId()).append(",")
                .append("\"taskId\": ").append(session.getTaskId()).append(",")
                .append("\"employeeId\": ").append(session.getEmployeeId()).append(",")
                .append("\"startTime\": \"").append(session.getStartTime()).append("\",")
                .append("\"endTime\": ").append(session.getEndTime() != null ? "\"" + session.getEndTime() + "\"" : "null").append(",")
                .append("\"duration\": ").append(session.getDurationMinutes() != null ? session.getDurationMinutes() : "null").append(",")
                .append("\"notes\": \"").append(escapeJson(session.getNotes())).append("\",")
                .append("\"active\": ").append(session.getEndTime() == null)
                .append("}");
        }
        
        json.append("]}");
        return json.toString();
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\"", "\\\"")
                 .replace("\n", "\\n")
                 .replace("\r", "\\r")
                 .replace("\t", "\\t");
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