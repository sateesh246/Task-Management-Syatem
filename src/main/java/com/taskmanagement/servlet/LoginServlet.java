package com.taskmanagement.servlet;

import com.taskmanagement.dao.EmployeeDAO;
import com.taskmanagement.model.Employee;
import com.taskmanagement.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Handles user authentication and session management
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    
    private EmployeeDAO employeeDAO;
    
    @Override
    public void init() throws ServletException {
        employeeDAO = new EmployeeDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is already logged in
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        // Forward to login page
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        // Validate input
        if (!ValidationUtil.isValidEmail(email) || !ValidationUtil.isNotEmpty(password)) {
            request.setAttribute("errorMessage", "Please provide valid email and password.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        // Sanitize input
        email = ValidationUtil.sanitizeInput(email);
        
        try {
            // Authenticate user
            Employee employee = employeeDAO.authenticate(email, password);
            
            if (employee != null && employee.isActive()) {
                // Authentication successful
                HttpSession session = request.getSession(true);
                session.setAttribute("currentUser", employee);
                session.setMaxInactiveInterval(30 * 60); // 30 minutes
                
                // Redirect to appropriate dashboard based on role
                String redirectUrl = getDashboardUrl(employee.getRole());
                response.sendRedirect(request.getContextPath() + redirectUrl);
                
            } else {
                // Authentication failed
                request.setAttribute("errorMessage", "Invalid email or password, or account is deactivated.");
                request.setAttribute("email", email); // Preserve email for user convenience
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "An error occurred during login. Please try again.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
    
    /**
     * Get dashboard URL based on user role
     */
    private String getDashboardUrl(Employee.Role role) {
        switch (role) {
            case ADMIN:
                return "/dashboard?view=admin";
            case MANAGER:
                return "/dashboard?view=manager";
            case EMPLOYEE:
            default:
                return "/dashboard?view=employee";
        }
    }
}