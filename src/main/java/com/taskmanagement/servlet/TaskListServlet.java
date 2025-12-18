package com.taskmanagement.servlet;

import com.taskmanagement.dao.TaskDAO;
import com.taskmanagement.dao.DepartmentDAO;
import com.taskmanagement.dao.EmployeeDAO;
import com.taskmanagement.model.Employee;
import com.taskmanagement.model.Task;
import com.taskmanagement.model.Department;
import com.taskmanagement.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet for displaying and filtering task lists
 * Provides role-based task visibility and advanced filtering options
 */
@WebServlet("/tasks")
public class TaskListServlet extends HttpServlet {
    
    private TaskDAO taskDAO;
    private DepartmentDAO departmentDAO;
    private EmployeeDAO employeeDAO;
    
    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
        departmentDAO = new DepartmentDAO();
        employeeDAO = new EmployeeDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Parse pagination parameters
            int page = parseIntParameter(request.getParameter("page"), 1);
            int pageSize = parseIntParameter(request.getParameter("pageSize"), 20);
            int offset = (page - 1) * pageSize;
            
            // Build filters based on request parameters (no authentication required)
            Map<String, Object> filters = buildFilters(request);
            
            // Get tasks with filters and pagination
            List<Task> tasks = taskDAO.getTasks(filters, offset, pageSize);
            
            // Get total count for pagination (simplified - would need separate count query in production)
            int totalTasks = tasks.size(); // This is a simplification
            int totalPages = (int) Math.ceil((double) totalTasks / pageSize);
            
            // Load reference data for filters
            loadReferenceData(request);
            
            // Set attributes for JSP
            request.setAttribute("tasks", tasks);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalTasks", totalTasks);
            request.setAttribute("filters", filters);
            
            // Forward to task list JSP
            request.getRequestDispatcher("/tasks.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading tasks: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Build filters based on request parameters (no authentication required)
     */
    private Map<String, Object> buildFilters(HttpServletRequest request) {
        Map<String, Object> filters = new HashMap<>();
        
        // No role-based filtering - show all tasks
        
        // Apply user-specified filters
        String status = request.getParameter("status");
        if (ValidationUtil.isNotEmpty(status) && !status.equals("ALL")) {
            filters.put("status", status);
        }
        
        String priority = request.getParameter("priority");
        if (ValidationUtil.isNotEmpty(priority) && !priority.equals("ALL")) {
            filters.put("priority", priority);
        }
        
        String departmentId = request.getParameter("departmentId");
        if (ValidationUtil.isNotEmpty(departmentId) && !departmentId.equals("ALL")) {
            try {
                int deptId = Integer.parseInt(departmentId);
                filters.put("departmentId", deptId);
            } catch (NumberFormatException e) {
                // Invalid department ID - ignore
            }
        }
        
        String assignedTo = request.getParameter("assignedTo");
        if (ValidationUtil.isNotEmpty(assignedTo) && !assignedTo.equals("ALL")) {
            try {
                int empId = Integer.parseInt(assignedTo);
                filters.put("assignedTo", empId);
            } catch (NumberFormatException e) {
                // Invalid employee ID - ignore
            }
        }
        
        String createdBy = request.getParameter("createdBy");
        if (ValidationUtil.isNotEmpty(createdBy) && !createdBy.equals("ALL")) {
            try {
                int creatorId = Integer.parseInt(createdBy);
                filters.put("createdBy", creatorId);
            } catch (NumberFormatException e) {
                // Invalid creator ID - ignore
            }
        }
        
        // Date range filters
        String dueDateFrom = request.getParameter("dueDateFrom");
        if (ValidationUtil.isNotEmpty(dueDateFrom)) {
            try {
                LocalDate fromDate = LocalDate.parse(dueDateFrom);
                filters.put("dueDateFrom", fromDate);
            } catch (DateTimeParseException e) {
                // Invalid date format - ignore
            }
        }
        
        String dueDateTo = request.getParameter("dueDateTo");
        if (ValidationUtil.isNotEmpty(dueDateTo)) {
            try {
                LocalDate toDate = LocalDate.parse(dueDateTo);
                filters.put("dueDateTo", toDate);
            } catch (DateTimeParseException e) {
                // Invalid date format - ignore
            }
        }
        
        // Search filter
        String search = request.getParameter("search");
        if (ValidationUtil.isNotEmpty(search)) {
            filters.put("search", ValidationUtil.sanitizeInput(search));
        }
        
        // Sort filter
        String sortBy = request.getParameter("sortBy");
        if (ValidationUtil.isNotEmpty(sortBy)) {
            filters.put("sortBy", sortBy);
        }
        
        return filters;
    }
    
    /**
     * Load reference data for filter dropdowns
     */
    private void loadReferenceData(HttpServletRequest request) {
        // Load all departments
        List<Department> departments = departmentDAO.getAll();
        request.setAttribute("departments", departments);
        
        // Load all employees for assignment filter
        List<Employee> employees = employeeDAO.getAll(null, null, true);
        request.setAttribute("employees", employees);
        
        // Task statuses
        request.setAttribute("taskStatuses", Task.Status.values());
        
        // Task priorities
        request.setAttribute("taskPriorities", Task.Priority.values());
    }
    
    /**
     * Parse integer parameter with default value
     */
    private int parseIntParameter(String param, int defaultValue) {
        if (param == null || param.trim().isEmpty()) {
            return defaultValue;
        }
        
        try {
            int value = Integer.parseInt(param);
            return value > 0 ? value : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}