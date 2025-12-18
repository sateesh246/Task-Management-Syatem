package com.taskmanagement.servlet;

import com.taskmanagement.dao.EmployeeDAO;
import com.taskmanagement.dao.TaskDAO;
import com.taskmanagement.dao.WorkSessionDAO;
import com.taskmanagement.model.Employee;
import com.taskmanagement.util.PasswordUtil;
import com.taskmanagement.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet for handling user profile operations
 * Supports profile viewing, editing, and password changes
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile", "/profile/*"})
public class ProfileServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(ProfileServlet.class.getName());
    
    private EmployeeDAO employeeDAO;
    private TaskDAO taskDAO;
    private WorkSessionDAO workSessionDAO;
    
    @Override
    public void init() throws ServletException {
        employeeDAO = new EmployeeDAO();
		taskDAO = new TaskDAO();
		workSessionDAO = new WorkSessionDAO();
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
        
        try {
            // Load fresh user data
            Employee user = employeeDAO.getEmployeeById(currentUser.getId());
            if (user == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
                return;
            }
            
            // Load profile statistics
            loadProfileStatistics(request, user);
            
            // Set attributes for JSP
            request.setAttribute("user", user);
            request.setAttribute("currentUser", currentUser);
            
            // Forward to JSP
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error in ProfileServlet.doGet", e);
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
                case "updateProfile":
                    handleUpdateProfile(request, response, currentUser);
                    break;
                case "changePassword":
                    handleChangePassword(request, response, currentUser);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error in ProfileServlet.doPost", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Database error occurred");
        }
    }
    
    private void loadProfileStatistics(HttpServletRequest request, Employee user) 
            throws SQLException {
        
        // Task statistics
        Map<String, Object> taskStats = new HashMap<>();
        taskStats.put("totalTasks", taskDAO.getTotalTasksForEmployee(user.getId()));
        taskStats.put("completedTasks", taskDAO.getCompletedTasksForEmployee(user.getId()));
        taskStats.put("inProgressTasks", taskDAO.getInProgressTasksForEmployee(user.getId()));
        taskStats.put("overdueTasks", taskDAO.getOverdueTasksForEmployee(user.getId()));
        
        // Calculate completion rate
        int total = (Integer) taskStats.get("totalTasks");
        int completed = (Integer) taskStats.get("completedTasks");
        int completionRate = total > 0 ? (completed * 100) / total : 0;
        taskStats.put("completionRate", completionRate);
        
        request.setAttribute("taskStats", taskStats);
        
        // Work session statistics
        Map<String, Object> workStats = new HashMap<>();
        workStats.put("totalHours", workSessionDAO.getTotalHoursForEmployee(user.getId()));
        workStats.put("monthlyHours", workSessionDAO.getMonthlyHoursForEmployee(user.getId()));
        workStats.put("averageSessionDuration", workSessionDAO.getAverageSessionDuration(user.getId()));
        
        request.setAttribute("workStats", workStats);
    }
    
    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response, 
                                   Employee currentUser) throws SQLException, ServletException, IOException {
        
        // Validate input
        Map<String, String> errors = validateProfileInput(request);
        if (!errors.isEmpty()) {
            // Reload page with errors
            loadProfileData(request, currentUser);
            setValidationErrors(request, errors);
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }
        
        // Update user profile
        Employee updatedUser = buildUpdatedProfile(request, currentUser);
        boolean success = employeeDAO.updateEmployee(updatedUser);
        
        if (success) {
            // Update session with new user data
            Employee freshUser = employeeDAO.getEmployeeById(currentUser.getId());
            request.getSession().setAttribute("currentUser", freshUser);
            
            response.sendRedirect(request.getContextPath() + "/profile?success=profile_updated");
        } else {
            loadProfileData(request, currentUser);
            request.setAttribute("errorMessage", "Failed to update profile. Please try again.");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
        }
    }
    
    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response, 
                                    Employee currentUser) throws SQLException, ServletException, IOException {
        
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validate password change
        Map<String, String> errors = validatePasswordChange(currentPassword, newPassword, 
                                                           confirmPassword, currentUser);
        if (!errors.isEmpty()) {
            loadProfileData(request, currentUser);
            setValidationErrors(request, errors);
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }
        
        // Update password
        String hashedPassword = PasswordUtil.hashPassword(newPassword);
        boolean success = employeeDAO.updatePassword(currentUser.getId(), hashedPassword);
        
        if (success) {
            response.sendRedirect(request.getContextPath() + "/profile?success=password_changed");
        } else {
            loadProfileData(request, currentUser);
            request.setAttribute("errorMessage", "Failed to change password. Please try again.");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
        }
    }
    
    private Map<String, String> validateProfileInput(HttpServletRequest request) {
        Map<String, String> errors = new HashMap<>();
        
        // Validate name
        String name = request.getParameter("name");
        if (!ValidationUtil.isValidName(name)) {
            errors.put("nameError", "Name must be between 2 and 100 characters");
        }
        
        // Validate email
        String email = request.getParameter("email");
        if (!ValidationUtil.isValidEmail(email)) {
            errors.put("emailError", "Please enter a valid email address");
        }
        
        return errors;
    }
    
    private Map<String, String> validatePasswordChange(String currentPassword, String newPassword, 
                                                     String confirmPassword, Employee currentUser) 
            throws SQLException {
        Map<String, String> errors = new HashMap<>();
        
        // Validate current password
        if (currentPassword == null || currentPassword.trim().isEmpty()) {
            errors.put("currentPasswordError", "Current password is required");
        } else {
            // Verify current password
            Employee user = employeeDAO.getEmployeeById(currentUser.getId());
            if (!PasswordUtil.verifyPassword(currentPassword, user.getPassword())) {
                errors.put("currentPasswordError", "Current password is incorrect");
            }
        }
        
        // Validate new password
        if (!ValidationUtil.isValidPassword(newPassword)) {
            errors.put("newPasswordError", 
                "Password must be at least 8 characters with uppercase, lowercase, number, and special character");
        }
        
        // Validate password confirmation
        if (!newPassword.equals(confirmPassword)) {
            errors.put("confirmPasswordError", "Password confirmation does not match");
        }
        
        return errors;
    }
    
    private Employee buildUpdatedProfile(HttpServletRequest request, Employee currentUser) {
        Employee updatedUser = new Employee();
        updatedUser.setId(currentUser.getId());
        updatedUser.setName(request.getParameter("name").trim());
        updatedUser.setEmail(request.getParameter("email").trim());
        
        // Keep other fields unchanged
        updatedUser.setRole(currentUser.getRole());
        updatedUser.setDepartmentId(currentUser.getDepartmentId());
        updatedUser.setManagerId(currentUser.getManagerId());
        updatedUser.setActive(currentUser.isActive());
        updatedUser.setPassword(currentUser.getPassword());
        updatedUser.setCreatedAt(currentUser.getCreatedAt());
        
        return updatedUser;
    }
    
    private void loadProfileData(HttpServletRequest request, Employee currentUser) 
            throws SQLException {
        
        Employee user = employeeDAO.getEmployeeById(currentUser.getId());
        loadProfileStatistics(request, user);
        request.setAttribute("user", user);
        request.setAttribute("currentUser", currentUser);
    }
    
    private void setValidationErrors(HttpServletRequest request, Map<String, String> errors) {
        for (Map.Entry<String, String> error : errors.entrySet()) {
            request.setAttribute(error.getKey(), error.getValue());
        }
    }
}