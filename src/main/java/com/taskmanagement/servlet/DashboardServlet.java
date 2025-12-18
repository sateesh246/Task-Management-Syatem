package com.taskmanagement.servlet;

import com.taskmanagement.dao.TaskDAO;
import com.taskmanagement.dao.EmployeeDAO;
import com.taskmanagement.dao.DepartmentDAO;
import com.taskmanagement.model.Department;
import com.taskmanagement.model.Employee;
import com.taskmanagement.model.Task;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Main dashboard servlet providing role-based dashboard views
 * Displays different information based on user role (EMPLOYEE, MANAGER, ADMIN)
 */
@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    
    private TaskDAO taskDAO;
    private EmployeeDAO employeeDAO;
    private DepartmentDAO departmentDAO;
    
    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
        employeeDAO = new EmployeeDAO();
        departmentDAO = new DepartmentDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String view = request.getParameter("view");
        
        try {
            // Default to admin view for demo purposes (no authentication)
            if (view == null) {
                view = "admin";
            }
            
            // Load dashboard data - default to admin view for full access
            loadAdminDashboard(request, null);
            
            request.setAttribute("view", view);
            request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading dashboard data: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Load dashboard data for EMPLOYEE role
     */
    private void loadEmployeeDashboard(HttpServletRequest request, Employee employee) {
        // Get employee's task statistics
        Map<String, Object> filters = new HashMap<>();
        filters.put("assignedTo", employee.getId());
        
        Map<String, Integer> taskCounts = taskDAO.getTaskCountByStatus(null, employee.getId());
        request.setAttribute("taskCounts", taskCounts);
        
        // Get employee's recent tasks (last 10)
        List<Task> recentTasks = taskDAO.getTasks(filters, 0, 10);
        request.setAttribute("recentTasks", recentTasks);
        
        // Get tasks needing attention (overdue, high priority)
        filters.put("status", "PENDING");
        filters.put("priority", "HIGH");
        List<Task> urgentTasks = taskDAO.getTasks(filters, 0, 5);
        request.setAttribute("urgentTasks", urgentTasks);
        
        // Get in-progress tasks
        filters.clear();
        filters.put("assignedTo", employee.getId());
        filters.put("status", "IN_PROGRESS");
        List<Task> inProgressTasks = taskDAO.getTasks(filters, 0, 10);
        request.setAttribute("inProgressTasks", inProgressTasks);
        
        // Calculate productivity metrics
        int totalTasks = taskCounts.values().stream().mapToInt(Integer::intValue).sum();
        int completedTasks = taskCounts.getOrDefault("COMPLETED", 0);
        double completionRate = totalTasks > 0 ? (double) completedTasks / totalTasks * 100 : 0;
        
        request.setAttribute("totalTasks", totalTasks);
        request.setAttribute("completedTasks", completedTasks);
        request.setAttribute("completionRate", Math.round(completionRate));
    }
    
    /**
     * Load dashboard data for MANAGER role
     */
    private void loadManagerDashboard(HttpServletRequest request, Employee manager) {
        // Get department task statistics
        Map<String, Integer> departmentTaskCounts = taskDAO.getTaskCountByStatus(manager.getDepartmentId(), null);
        request.setAttribute("departmentTaskCounts", departmentTaskCounts);
        
        // Get tasks needing review
        Map<String, Object> filters = new HashMap<>();
        filters.put("status", "UNDER_REVIEW");
        filters.put("departmentId", manager.getDepartmentId());
        List<Task> tasksNeedingReview = taskDAO.getTasks(filters, 0, 10);
        request.setAttribute("tasksNeedingReview", tasksNeedingReview);
        
        // Get overdue tasks in department
        List<Task> overdueTasks = taskDAO.getOverdueTasks();
        overdueTasks.removeIf(task -> task.getDepartmentId() != manager.getDepartmentId());
        request.setAttribute("overdueTasks", overdueTasks.subList(0, Math.min(5, overdueTasks.size())));
        
        // Get team members
        List<Employee> teamMembers = employeeDAO.getByDepartment(manager.getDepartmentId());
        request.setAttribute("teamMembers", teamMembers);
        
        // Get recent department tasks
        filters.clear();
        filters.put("departmentId", manager.getDepartmentId());
        List<Task> recentDepartmentTasks = taskDAO.getTasks(filters, 0, 10);
        request.setAttribute("recentDepartmentTasks", recentDepartmentTasks);
        
        // Team workload analysis
        List<Employee> teamWorkload = employeeDAO.getEmployeeWorkload(manager.getDepartmentId());
        request.setAttribute("teamWorkload", teamWorkload);
    }
    
    /**
     * Load dashboard data for ADMIN role
     */
    private void loadAdminDashboard(HttpServletRequest request, Employee admin) {
        // System-wide statistics
        Map<String, Integer> systemTaskCounts = taskDAO.getTaskCountByStatus(null, null);
        request.setAttribute("systemTaskCounts", systemTaskCounts);
        
        // All departments overview
        List<Department> departments = departmentDAO.getAllWithStats();
        request.setAttribute("departments", departments);
        
        // System-wide overdue tasks
        List<Task> systemOverdueTasks = taskDAO.getOverdueTasks();
        request.setAttribute("systemOverdueTasks", systemOverdueTasks.subList(0, Math.min(10, systemOverdueTasks.size())));
        
        // Recent system activity (all tasks)
        Map<String, Object> filters = new HashMap<>();
        List<Task> recentSystemTasks = taskDAO.getTasks(filters, 0, 15);
        request.setAttribute("recentSystemTasks", recentSystemTasks);
        
        // Employee statistics
        List<Employee> allEmployees = employeeDAO.getAll(null, null, true);
        request.setAttribute("totalEmployees", allEmployees.size());
        
        long managerCount = allEmployees.stream().filter(Employee::isManager).count();
        long employeeCount = allEmployees.stream().filter(Employee::isEmployee).count();
        
        request.setAttribute("managerCount", managerCount);
        request.setAttribute("employeeCount", employeeCount);
        
        // System workload overview
        List<Employee> systemWorkload = employeeDAO.getEmployeeWorkload(null);
        request.setAttribute("systemWorkload", systemWorkload.subList(0, Math.min(10, systemWorkload.size())));
        
        // Calculate system metrics
        int totalSystemTasks = systemTaskCounts.values().stream().mapToInt(Integer::intValue).sum();
        int completedSystemTasks = systemTaskCounts.getOrDefault("COMPLETED", 0);
        double systemCompletionRate = totalSystemTasks > 0 ? (double) completedSystemTasks / totalSystemTasks * 100 : 0;
        
        request.setAttribute("totalSystemTasks", totalSystemTasks);
        request.setAttribute("completedSystemTasks", completedSystemTasks);
        request.setAttribute("systemCompletionRate", Math.round(systemCompletionRate));
    }
}