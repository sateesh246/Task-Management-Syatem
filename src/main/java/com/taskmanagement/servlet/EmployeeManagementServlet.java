package com.taskmanagement.servlet;

import com.taskmanagement.dao.*;
import com.taskmanagement.model.*;
import com.taskmanagement.util.ValidationUtil;
import com.taskmanagement.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for employee management (ADMIN only)
 * Handles CRUD operations for employees
 */
@WebServlet("/employees/*")
public class EmployeeManagementServlet extends HttpServlet {
    
    private EmployeeDAO employeeDAO;
    private DepartmentDAO departmentDAO;
    private TaskDAO taskDAO;
    private TaskActivityLogDAO activityLogDAO;
    private NotificationDAO notificationDAO;
    
    @Override
    public void init() throws ServletException {
        employeeDAO = new EmployeeDAO();
        departmentDAO = new DepartmentDAO();
        taskDAO = new TaskDAO();
        activityLogDAO = new TaskActivityLogDAO();
        notificationDAO = new NotificationDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Employee currentUser = (Employee) request.getAttribute("currentUser");
        String pathInfo = request.getPathInfo();
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Check permissions - only admins can manage employees
        if (!currentUser.hasAdminPrivileges()) {
            request.setAttribute("errorMessage", "Access denied. Only administrators can manage employees.");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                // Show employee list
                handleEmployeeList(request, response);
            } else if (pathInfo.equals("/create")) {
                // Show create employee form
                handleCreateEmployeeForm(request, response);
            } else if (pathInfo.startsWith("/edit/")) {
                // Show edit employee form
                String employeeIdStr = pathInfo.substring(6);
                handleEditEmployeeForm(request, response, employeeIdStr);
            } else if (pathInfo.startsWith("/view/")) {
                // Show employee details
                String employeeIdStr = pathInfo.substring(6);
                handleEmployeeDetails(request, response, employeeIdStr);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error processing request: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Employee currentUser = (Employee) request.getAttribute("currentUser");
        String action = request.getParameter("action");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Check permissions
        if (!currentUser.hasAdminPrivileges()) {
            request.setAttribute("errorMessage", "Access denied. Only administrators can manage employees.");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }
        
        try {
            switch (action) {
                case "create":
                    handleCreateEmployee(request, response);
                    break;
                case "update":
                    handleUpdateEmployee(request, response);
                    break;
                case "deactivate":
                    handleDeactivateEmployee(request, response);
                    break;
                case "activate":
                    handleActivateEmployee(request, response);
                    break;
                case "resetPassword":
                    handleResetPassword(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error processing request: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle employee list display
     */
    private void handleEmployeeList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Parse filters
        String roleFilter = request.getParameter("role");
        String departmentFilter = request.getParameter("department");
        String statusFilter = request.getParameter("status");
        String searchQuery = request.getParameter("search");
        
        Employee.Role role = null;
        if (ValidationUtil.isNotEmpty(roleFilter) && !roleFilter.equals("ALL")) {
            try {
                role = Employee.Role.valueOf(roleFilter);
            } catch (IllegalArgumentException e) {
                // Invalid role, ignore
            }
        }
        
        Integer departmentId = null;
        if (ValidationUtil.isNotEmpty(departmentFilter) && !departmentFilter.equals("ALL")) {
            try {
                departmentId = Integer.parseInt(departmentFilter);
            } catch (NumberFormatException e) {
                // Invalid department ID, ignore
            }
        }
        
        boolean activeOnly = !"inactive".equals(statusFilter);
        
        // Get employees with filters
        List<Employee> employees = employeeDAO.getAll(role, departmentId, activeOnly);
        
        // Apply search filter if provided
        if (ValidationUtil.isNotEmpty(searchQuery)) {
            String searchTerm = ValidationUtil.sanitizeInput(searchQuery).toLowerCase();
            employees.removeIf(emp -> 
                !emp.getName().toLowerCase().contains(searchTerm) &&
                !emp.getEmail().toLowerCase().contains(searchTerm)
            );
        }
        
        // Load departments for filter dropdown
        List<Department> departments = departmentDAO.getAll();
        
        // Set attributes
        request.setAttribute("employees", employees);
        request.setAttribute("departments", departments);
        request.setAttribute("roleFilter", roleFilter);
        request.setAttribute("departmentFilter", departmentFilter);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("searchQuery", searchQuery);
        
        request.getRequestDispatcher("/employees/list.jsp").forward(request, response);
    }
    
    /**
     * Handle create employee form display
     */
    private void handleCreateEmployeeForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Load reference data
        List<Department> departments = departmentDAO.getAll();
        List<Employee> managers = employeeDAO.getAll(Employee.Role.MANAGER, null, true);
        managers.addAll(employeeDAO.getAll(Employee.Role.ADMIN, null, true));
        
        request.setAttribute("departments", departments);
        request.setAttribute("managers", managers);
        request.setAttribute("roles", Employee.Role.values());
        
        request.getRequestDispatcher("/employees/create.jsp").forward(request, response);
    }
    
    /**
     * Handle edit employee form display
     */
    private void handleEditEmployeeForm(HttpServletRequest request, HttpServletResponse response, String employeeIdStr)
            throws ServletException, IOException {
        
        try {
            int employeeId = Integer.parseInt(employeeIdStr);
            Employee employee = employeeDAO.getById(employeeId);
            
            if (employee == null) {
                request.setAttribute("errorMessage", "Employee not found");
                request.getRequestDispatcher("/error.jsp").forward(request, response);
                return;
            }
            
            // Load reference data
            List<Department> departments = departmentDAO.getAll();
            List<Employee> managers = employeeDAO.getAll(Employee.Role.MANAGER, null, true);
            managers.addAll(employeeDAO.getAll(Employee.Role.ADMIN, null, true));
            
            request.setAttribute("employee", employee);
            request.setAttribute("departments", departments);
            request.setAttribute("managers", managers);
            request.setAttribute("roles", Employee.Role.values());
            
            request.getRequestDispatcher("/employees/edit.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid employee ID");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle employee details display
     */
    private void handleEmployeeDetails(HttpServletRequest request, HttpServletResponse response, String employeeIdStr)
            throws ServletException, IOException {
        
        try {
            int employeeId = Integer.parseInt(employeeIdStr);
            Employee employee = employeeDAO.getById(employeeId);
            
            if (employee == null) {
                request.setAttribute("errorMessage", "Employee not found");
                request.getRequestDispatcher("/error.jsp").forward(request, response);
                return;
            }
            
            // Get employee's task statistics
            java.util.Map<String, Integer> taskCounts = taskDAO.getTaskCountByStatus(null, employeeId);
            
            // Get employee's subordinates if they're a manager
            List<Employee> subordinates = employeeDAO.getSubordinates(employeeId);
            
            // Get recent activity
            List<TaskActivityLog> recentActivity = activityLogDAO.getActivityLogForEmployee(employeeId, 20);
            
            request.setAttribute("employee", employee);
            request.setAttribute("taskCounts", taskCounts);
            request.setAttribute("subordinates", subordinates);
            request.setAttribute("recentActivity", recentActivity);
            
            request.getRequestDispatcher("/employees/details.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid employee ID");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle create employee
     */
    private void handleCreateEmployee(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Employee employee = parseEmployeeFromRequest(request, true);
        
        if (employee == null) {
            // Validation errors - reload form
            handleCreateEmployeeForm(request, response);
            return;
        }
        
        // Check if email already exists
        if (employeeDAO.emailExists(employee.getEmail(), null)) {
            request.setAttribute("emailError", "Email address already exists");
            handleCreateEmployeeForm(request, response);
            return;
        }
        
        if (employeeDAO.create(employee)) {
            response.sendRedirect(request.getContextPath() + "/employees?success=employee_created");
        } else {
            request.setAttribute("errorMessage", "Failed to create employee");
            handleCreateEmployeeForm(request, response);
        }
    }
    
    /**
     * Handle update employee
     */
    private void handleUpdateEmployee(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String employeeIdStr = request.getParameter("employeeId");
        
        try {
            int employeeId = Integer.parseInt(employeeIdStr);
            Employee employee = parseEmployeeFromRequest(request, false);
            
            if (employee == null) {
                // Validation errors - reload form
                handleEditEmployeeForm(request, response, employeeIdStr);
                return;
            }
            
            employee.setId(employeeId);
            
            // Check if email already exists (excluding current employee)
            if (employeeDAO.emailExists(employee.getEmail(), employeeId)) {
                request.setAttribute("emailError", "Email address already exists");
                handleEditEmployeeForm(request, response, employeeIdStr);
                return;
            }
            
            if (employeeDAO.update(employee)) {
                response.sendRedirect(request.getContextPath() + "/employees?success=employee_updated");
            } else {
                request.setAttribute("errorMessage", "Failed to update employee");
                handleEditEmployeeForm(request, response, employeeIdStr);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid employee ID");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle deactivate employee
     */
    private void handleDeactivateEmployee(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String employeeIdStr = request.getParameter("employeeId");
        
        try {
            int employeeId = Integer.parseInt(employeeIdStr);
            
            // TODO: Implement cascading operations as per requirements:
            // - Reassign all IN_PROGRESS tasks to their manager
            // - Keep completed task history intact
            // - Update all activity logs
            
            if (employeeDAO.deactivate(employeeId)) {
                response.sendRedirect(request.getContextPath() + "/employees?success=employee_deactivated");
            } else {
                response.sendRedirect(request.getContextPath() + "/employees?error=deactivation_failed");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid employee ID");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle activate employee
     */
    private void handleActivateEmployee(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String employeeIdStr = request.getParameter("employeeId");
        
        try {
            int employeeId = Integer.parseInt(employeeIdStr);
            Employee employee = employeeDAO.getById(employeeId);
            
            if (employee != null) {
                employee.setActive(true);
                if (employeeDAO.update(employee)) {
                    response.sendRedirect(request.getContextPath() + "/employees?success=employee_activated");
                } else {
                    response.sendRedirect(request.getContextPath() + "/employees?error=activation_failed");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/employees?error=employee_not_found");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid employee ID");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle reset password
     */
    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String employeeIdStr = request.getParameter("employeeId");
        
        try {
            int employeeId = Integer.parseInt(employeeIdStr);
            
            // Generate new random password
            String newPassword = PasswordUtil.generateRandomPassword(12);
            
            if (employeeDAO.updatePassword(employeeId, newPassword)) {
                // In a real system, you would send this password via email
                request.setAttribute("successMessage", "Password reset successfully. New password: " + newPassword);
                request.setAttribute("newPassword", newPassword);
                handleEmployeeDetails(request, response, employeeIdStr);
            } else {
                response.sendRedirect(request.getContextPath() + "/employees?error=password_reset_failed");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid employee ID");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Parse employee from request parameters with validation
     */
    private Employee parseEmployeeFromRequest(HttpServletRequest request, boolean isCreate) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String roleStr = request.getParameter("role");
        String departmentIdStr = request.getParameter("departmentId");
        String managerIdStr = request.getParameter("managerId");
        
        boolean hasErrors = false;
        
        // Validate name
        if (!ValidationUtil.isValidName(name)) {
            request.setAttribute("nameError", "Name is required and must be 2-50 characters, letters and spaces only");
            hasErrors = true;
        }
        
        // Validate email
        if (!ValidationUtil.isValidEmail(email)) {
            request.setAttribute("emailError", "Valid email address is required");
            hasErrors = true;
        }
        
        // Validate password (only for create)
        if (isCreate && !PasswordUtil.isValidPassword(password)) {
            request.setAttribute("passwordError", "Password must be at least 8 characters with uppercase, lowercase, digit, and special character");
            hasErrors = true;
        }
        
        // Validate role
        Employee.Role role;
        try {
            role = Employee.Role.valueOf(roleStr);
        } catch (IllegalArgumentException e) {
            request.setAttribute("roleError", "Invalid role selected");
            hasErrors = true;
            role = Employee.Role.EMPLOYEE; // Default
        }
        
        // Validate department
        int departmentId;
        try {
            departmentId = Integer.parseInt(departmentIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("departmentError", "Invalid department selected");
            hasErrors = true;
            departmentId = 1; // Default
        }
        
        // Validate manager (optional)
        Integer managerId = null;
        if (ValidationUtil.isNotEmpty(managerIdStr) && !managerIdStr.equals("0")) {
            try {
                managerId = Integer.parseInt(managerIdStr);
            } catch (NumberFormatException e) {
                request.setAttribute("managerError", "Invalid manager selected");
                hasErrors = true;
            }
        }
        
        if (hasErrors) {
            // Preserve form data for redisplay
            request.setAttribute("formName", name);
            request.setAttribute("formEmail", email);
            request.setAttribute("formRole", roleStr);
            request.setAttribute("formDepartmentId", departmentIdStr);
            request.setAttribute("formManagerId", managerIdStr);
            return null;
        }
        
        // Sanitize inputs
        name = ValidationUtil.sanitizeInput(name);
        email = ValidationUtil.sanitizeInput(email);
        
        // Create employee object
        Employee employee = new Employee(name, email, password, role, departmentId);
        employee.setManagerId(managerId);
        
        return employee;
    }
}