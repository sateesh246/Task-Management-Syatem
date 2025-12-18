package com.taskmanagement.servlet;

import com.taskmanagement.dao.*;
import com.taskmanagement.model.Employee;
import com.google.gson.Gson;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.*;

/**
 * Servlet for generating analytics and reports
 * Provides comprehensive reporting capabilities for different user roles
 */
@WebServlet("/reports/*")
public class ReportsServlet extends HttpServlet {
    
    private TaskDAO taskDAO;
    private EmployeeDAO employeeDAO;
    private DepartmentDAO departmentDAO;
    private WorkSessionDAO workSessionDAO;
    private TaskActivityLogDAO activityLogDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
        employeeDAO = new EmployeeDAO();
        departmentDAO = new DepartmentDAO();
        workSessionDAO = new WorkSessionDAO();
        activityLogDAO = new TaskActivityLogDAO();
        gson = new Gson();
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
        
        // Check permissions - only managers and admins can access reports
        if (!currentUser.hasManagerPrivileges()) {
            request.setAttribute("errorMessage", "Access denied. You don't have permission to view reports.");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }
        
        try {
            String reportType = getReportType(pathInfo);
            String format = request.getParameter("format"); // json, html
            
            switch (reportType) {
                case "dashboard":
                    handleDashboardReport(request, response, currentUser, format);
                    break;
                case "productivity":
                    handleProductivityReport(request, response, currentUser, format);
                    break;
                case "task-aging":
                    handleTaskAgingReport(request, response, currentUser, format);
                    break;
                case "bottleneck":
                    handleBottleneckReport(request, response, currentUser, format);
                    break;
                case "department-comparison":
                    handleDepartmentComparisonReport(request, response, currentUser, format);
                    break;
                case "sla-compliance":
                    handleSLAComplianceReport(request, response, currentUser, format);
                    break;
                default:
                    // Show reports index page
                    request.getRequestDispatcher("/reports.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error generating report: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle dashboard statistics report
     */
    private void handleDashboardReport(HttpServletRequest request, HttpServletResponse response, 
                                     Employee currentUser, String format) throws ServletException, IOException {
        
        Map<String, Object> reportData = new HashMap<>();
        
        // Get task statistics based on user role
        Integer departmentId = currentUser.hasAdminPrivileges() ? null : currentUser.getDepartmentId();
        
        Map<String, Integer> taskCounts = taskDAO.getTaskCountByStatus(departmentId, null);
        reportData.put("taskCounts", taskCounts);
        
        // Calculate totals and percentages
        int totalTasks = taskCounts.values().stream().mapToInt(Integer::intValue).sum();
        int completedTasks = taskCounts.getOrDefault("COMPLETED", 0);
        double completionRate = totalTasks > 0 ? (double) completedTasks / totalTasks * 100 : 0;
        
        reportData.put("totalTasks", totalTasks);
        reportData.put("completedTasks", completedTasks);
        reportData.put("completionRate", Math.round(completionRate * 100.0) / 100.0);
        
        // Get overdue tasks count
        List<com.taskmanagement.model.Task> overdueTasks = taskDAO.getOverdueTasks();
        if (!currentUser.hasAdminPrivileges()) {
            overdueTasks.removeIf(task -> task.getDepartmentId() != currentUser.getDepartmentId());
        }
        reportData.put("overdueTasksCount", overdueTasks.size());
        
        // Get employee statistics
        List<Employee> employees = currentUser.hasAdminPrivileges() 
            ? employeeDAO.getAll(null, null, true)
            : employeeDAO.getByDepartment(currentUser.getDepartmentId());
        
        reportData.put("totalEmployees", employees.size());
        reportData.put("activeEmployees", employees.stream().mapToInt(e -> e.isActive() ? 1 : 0).sum());
        
        if ("json".equals(format)) {
            response.setContentType("application/json");
            response.getWriter().write(gson.toJson(reportData));
        } else {
            request.setAttribute("reportData", reportData);
            request.setAttribute("reportTitle", "Dashboard Statistics");
            request.getRequestDispatcher("/reports/dashboard.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle employee productivity report
     */
    private void handleProductivityReport(HttpServletRequest request, HttpServletResponse response, 
                                        Employee currentUser, String format) throws ServletException, IOException {
        
        // Parse date range parameters
        LocalDateTime fromDate = parseDateTime(request.getParameter("fromDate"), LocalDateTime.now().minusDays(30));
        LocalDateTime toDate = parseDateTime(request.getParameter("toDate"), LocalDateTime.now());
        
        Map<String, Object> reportData = new HashMap<>();
        List<Map<String, Object>> employeeStats = new ArrayList<>();
        
        // Get employees based on user role
        List<Employee> employees = currentUser.hasAdminPrivileges() 
            ? employeeDAO.getAll(null, null, true)
            : employeeDAO.getByDepartment(currentUser.getDepartmentId());
        
        for (Employee employee : employees) {
            Map<String, Object> stats = new HashMap<>();
            stats.put("employeeId", employee.getId());
            stats.put("employeeName", employee.getName());
            stats.put("department", employee.getDepartmentName());
            
            // Get task statistics for employee
            Map<String, Integer> taskCounts = taskDAO.getTaskCountByStatus(null, employee.getId());
            stats.put("taskCounts", taskCounts);
            
            int totalTasks = taskCounts.values().stream().mapToInt(Integer::intValue).sum();
            int completedTasks = taskCounts.getOrDefault("COMPLETED", 0);
            double completionRate = totalTasks > 0 ? (double) completedTasks / totalTasks * 100 : 0;
            
            stats.put("totalTasks", totalTasks);
            stats.put("completedTasks", completedTasks);
            stats.put("completionRate", Math.round(completionRate * 100.0) / 100.0);
            
            // Get work session statistics
            List<Object[]> productivityStats = workSessionDAO.getEmployeeProductivityStats(
                employee.getId(), fromDate, toDate);
            
            int totalWorkMinutes = 0;
            int totalSessions = 0;
            Set<Integer> uniqueTasksWorked = new HashSet<>();
            
            for (Object[] row : productivityStats) {
                totalWorkMinutes += (Integer) row[2]; // total_minutes
                totalSessions += (Integer) row[3]; // total_sessions
                uniqueTasksWorked.add((Integer) row[1]); // tasks_worked
            }
            
            stats.put("totalWorkHours", Math.round(totalWorkMinutes / 60.0 * 100.0) / 100.0);
            stats.put("totalSessions", totalSessions);
            stats.put("uniqueTasksWorked", uniqueTasksWorked.size());
            stats.put("avgSessionLength", totalSessions > 0 ? 
                Math.round(totalWorkMinutes / (double) totalSessions * 100.0) / 100.0 : 0);
            
            employeeStats.add(stats);
        }
        
        // Sort by completion rate descending
        employeeStats.sort((a, b) -> Double.compare(
            (Double) b.get("completionRate"), 
            (Double) a.get("completionRate")
        ));
        
        reportData.put("employeeStats", employeeStats);
        reportData.put("fromDate", fromDate.toLocalDate().toString());
        reportData.put("toDate", toDate.toLocalDate().toString());
        reportData.put("totalEmployees", employeeStats.size());
        
        if ("json".equals(format)) {
            response.setContentType("application/json");
            response.getWriter().write(gson.toJson(reportData));
        } else {
            request.setAttribute("reportData", reportData);
            request.setAttribute("reportTitle", "Employee Productivity Report");
            request.getRequestDispatcher("/reports/productivity.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle task aging analysis report
     */
    private void handleTaskAgingReport(HttpServletRequest request, HttpServletResponse response, 
                                     Employee currentUser, String format) throws ServletException, IOException {
        
        Map<String, Object> reportData = new HashMap<>();
        
        // Get tasks based on user role
        Map<String, Object> filters = new HashMap<>();
        if (!currentUser.hasAdminPrivileges()) {
            filters.put("departmentId", currentUser.getDepartmentId());
        }
        
        List<com.taskmanagement.model.Task> tasks = taskDAO.getTasks(filters, 0, 1000);
        
        // Categorize tasks by age
        Map<String, Integer> agingCategories = new HashMap<>();
        agingCategories.put("0-3 days", 0);
        agingCategories.put("4-7 days", 0);
        agingCategories.put("8-14 days", 0);
        agingCategories.put("15-30 days", 0);
        agingCategories.put("30+ days", 0);
        
        Map<String, Integer> statusDistribution = new HashMap<>();
        int overdueCount = 0;
        
        LocalDateTime now = LocalDateTime.now();
        
        for (com.taskmanagement.model.Task task : tasks) {
            // Calculate age in days
            long ageInDays = java.time.Duration.between(task.getCreatedAt(), now).toDays();
            
            // Categorize by age
            if (ageInDays <= 3) {
                agingCategories.put("0-3 days", agingCategories.get("0-3 days") + 1);
            } else if (ageInDays <= 7) {
                agingCategories.put("4-7 days", agingCategories.get("4-7 days") + 1);
            } else if (ageInDays <= 14) {
                agingCategories.put("8-14 days", agingCategories.get("8-14 days") + 1);
            } else if (ageInDays <= 30) {
                agingCategories.put("15-30 days", agingCategories.get("15-30 days") + 1);
            } else {
                agingCategories.put("30+ days", agingCategories.get("30+ days") + 1);
            }
            
            // Status distribution
            String status = task.getStatus().name();
            statusDistribution.put(status, statusDistribution.getOrDefault(status, 0) + 1);
            
            // Check if overdue
            if (task.isOverdue()) {
                overdueCount++;
            }
        }
        
        reportData.put("agingCategories", agingCategories);
        reportData.put("statusDistribution", statusDistribution);
        reportData.put("totalTasks", tasks.size());
        reportData.put("overdueCount", overdueCount);
        reportData.put("overduePercentage", tasks.size() > 0 ? 
            Math.round((double) overdueCount / tasks.size() * 100 * 100.0) / 100.0 : 0);
        
        if ("json".equals(format)) {
            response.setContentType("application/json");
            response.getWriter().write(gson.toJson(reportData));
        } else {
            request.setAttribute("reportData", reportData);
            request.setAttribute("reportTitle", "Task Aging Analysis");
            request.getRequestDispatcher("/reports/task-aging.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle bottleneck analysis report
     */
    private void handleBottleneckReport(HttpServletRequest request, HttpServletResponse response, 
                                      Employee currentUser, String format) throws ServletException, IOException {
        
        Map<String, Object> reportData = new HashMap<>();
        
        // This is a simplified bottleneck analysis
        // In a real system, this would involve more complex dependency chain analysis
        
        Map<String, Object> filters = new HashMap<>();
        if (!currentUser.hasAdminPrivileges()) {
            filters.put("departmentId", currentUser.getDepartmentId());
        }
        
        List<com.taskmanagement.model.Task> tasks = taskDAO.getTasks(filters, 0, 1000);
        
        List<Map<String, Object>> bottlenecks = new ArrayList<>();
        
        for (com.taskmanagement.model.Task task : tasks) {
            if (task.isBlocked()) {
                Map<String, Object> bottleneck = new HashMap<>();
                bottleneck.put("taskId", task.getId());
                bottleneck.put("taskTitle", task.getTitle());
                bottleneck.put("status", task.getStatus().name());
                bottleneck.put("priority", task.getPriority().name());
                bottleneck.put("dueDate", task.getDueDate().toString());
                bottleneck.put("dependencyCount", task.getDependencies().size());
                bottleneck.put("isOverdue", task.isOverdue());
                
                // Calculate blocking duration (simplified)
                long blockingDays = java.time.Duration.between(task.getCreatedAt(), LocalDateTime.now()).toDays();
                bottleneck.put("blockingDays", blockingDays);
                
                bottlenecks.add(bottleneck);
            }
        }
        
        // Sort by blocking duration descending
        bottlenecks.sort((a, b) -> Long.compare((Long) b.get("blockingDays"), (Long) a.get("blockingDays")));
        
        reportData.put("bottlenecks", bottlenecks);
        reportData.put("totalBottlenecks", bottlenecks.size());
        reportData.put("totalTasks", tasks.size());
        reportData.put("bottleneckPercentage", tasks.size() > 0 ? 
            Math.round((double) bottlenecks.size() / tasks.size() * 100 * 100.0) / 100.0 : 0);
        
        if ("json".equals(format)) {
            response.setContentType("application/json");
            response.getWriter().write(gson.toJson(reportData));
        } else {
            request.setAttribute("reportData", reportData);
            request.setAttribute("reportTitle", "Bottleneck Analysis");
            request.getRequestDispatcher("/reports/bottleneck.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle department comparison report
     */
    private void handleDepartmentComparisonReport(HttpServletRequest request, HttpServletResponse response, 
                                                Employee currentUser, String format) throws ServletException, IOException {
        
        // Only admins can see department comparison
        if (!currentUser.hasAdminPrivileges()) {
            request.setAttribute("errorMessage", "Access denied. Only administrators can view department comparison reports.");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }
        
        Map<String, Object> reportData = new HashMap<>();
        List<Map<String, Object>> departmentStats = new ArrayList<>();
        
        List<com.taskmanagement.model.Department> departments = departmentDAO.getAllWithStats();
        
        for (com.taskmanagement.model.Department dept : departments) {
            Map<String, Object> stats = new HashMap<>();
            stats.put("departmentId", dept.getId());
            stats.put("departmentName", dept.getName());
            stats.put("employeeCount", dept.getEmployeeCount());
            stats.put("activeTaskCount", dept.getActiveTaskCount());
            stats.put("completedTaskCount", dept.getCompletedTaskCount());
            
            int totalTasks = dept.getActiveTaskCount() + dept.getCompletedTaskCount();
            double completionRate = totalTasks > 0 ? 
                (double) dept.getCompletedTaskCount() / totalTasks * 100 : 0;
            stats.put("completionRate", Math.round(completionRate * 100.0) / 100.0);
            
            // Calculate average tasks per employee
            double avgTasksPerEmployee = dept.getEmployeeCount() > 0 ? 
                (double) totalTasks / dept.getEmployeeCount() : 0;
            stats.put("avgTasksPerEmployee", Math.round(avgTasksPerEmployee * 100.0) / 100.0);
            
            departmentStats.add(stats);
        }
        
        // Sort by completion rate descending
        departmentStats.sort((a, b) -> Double.compare(
            (Double) b.get("completionRate"), 
            (Double) a.get("completionRate")
        ));
        
        reportData.put("departmentStats", departmentStats);
        reportData.put("totalDepartments", departmentStats.size());
        
        if ("json".equals(format)) {
            response.setContentType("application/json");
            response.getWriter().write(gson.toJson(reportData));
        } else {
            request.setAttribute("reportData", reportData);
            request.setAttribute("reportTitle", "Department Comparison");
            request.getRequestDispatcher("/reports/department-comparison.jsp").forward(request, response);
        }
    }
    
    /**
     * Handle SLA compliance report
     */
    private void handleSLAComplianceReport(HttpServletRequest request, HttpServletResponse response, 
                                         Employee currentUser, String format) throws ServletException, IOException {
        
        Map<String, Object> reportData = new HashMap<>();
        
        Map<String, Object> filters = new HashMap<>();
        if (!currentUser.hasAdminPrivileges()) {
            filters.put("departmentId", currentUser.getDepartmentId());
        }
        
        List<com.taskmanagement.model.Task> tasks = taskDAO.getTasks(filters, 0, 1000);
        
        int totalTasks = 0;
        int onTimeTasks = 0;
        int overdueTasks = 0;
        long totalDelayDays = 0;
        
        for (com.taskmanagement.model.Task task : tasks) {
            if (task.getStatus() == com.taskmanagement.model.Task.Status.COMPLETED) {
                totalTasks++;
                
                // For completed tasks, check if they were completed on time
                // This is simplified - in reality you'd compare completion date with due date
                if (!task.isOverdue()) {
                    onTimeTasks++;
                } else {
                    overdueTasks++;
                    // Calculate delay (simplified)
                    long delay = java.time.Duration.between(
                        task.getDueDate().atStartOfDay(), 
                        task.getUpdatedAt()
                    ).toDays();
                    totalDelayDays += Math.max(0, delay);
                }
            }
        }
        
        double slaCompliance = totalTasks > 0 ? (double) onTimeTasks / totalTasks * 100 : 0;
        double avgDelay = overdueTasks > 0 ? (double) totalDelayDays / overdueTasks : 0;
        
        reportData.put("totalCompletedTasks", totalTasks);
        reportData.put("onTimeTasks", onTimeTasks);
        reportData.put("overdueTasks", overdueTasks);
        reportData.put("slaCompliance", Math.round(slaCompliance * 100.0) / 100.0);
        reportData.put("avgDelayDays", Math.round(avgDelay * 100.0) / 100.0);
        
        if ("json".equals(format)) {
            response.setContentType("application/json");
            response.getWriter().write(gson.toJson(reportData));
        } else {
            request.setAttribute("reportData", reportData);
            request.setAttribute("reportTitle", "SLA Compliance Report");
            request.getRequestDispatcher("/reports/sla-compliance.jsp").forward(request, response);
        }
    }
    
    /**
     * Extract report type from path info
     */
    private String getReportType(String pathInfo) {
        if (pathInfo == null || pathInfo.length() <= 1) {
            return "index";
        }
        return pathInfo.substring(1); // Remove leading slash
    }
    
    /**
     * Parse date time parameter with fallback
     */
    private LocalDateTime parseDateTime(String dateStr, LocalDateTime fallback) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return fallback;
        }
        
        try {
            return LocalDateTime.parse(dateStr + "T00:00:00");
        } catch (DateTimeParseException e) {
            return fallback;
        }
    }
}