package com.taskmanagement.dao;

import com.taskmanagement.config.DatabaseConfig;
import com.taskmanagement.model.Task;
import com.taskmanagement.model.TaskAssignment;
import com.taskmanagement.model.TaskDependency;
import com.taskmanagement.model.Employee;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * Data Access Object for Task operations
 * Handles all database operations related to tasks including complex business logic
 */
public class TaskDAO {
    
    /**
     * Create new task with optimistic locking
     */
    public boolean create(Task task) {
        String sql = """
            INSERT INTO tasks (title, description, priority, status, due_date, department_id, created_by, version)
            VALUES (?, ?, ?, ?, ?, ?, ?, 1)
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, task.getTitle());
            stmt.setString(2, task.getDescription());
            stmt.setString(3, task.getPriority().name());
            stmt.setString(4, task.getStatus().name());
            stmt.setDate(5, Date.valueOf(task.getDueDate()));
            stmt.setInt(6, task.getDepartmentId());
            stmt.setInt(7, task.getCreatedBy());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    task.setId(generatedKeys.getInt(1));
                }
                return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get task by ID with full details
     */
    public Task getById(int id) {
        String sql = """
            SELECT t.id, t.title, t.description, t.priority, t.status, t.due_date,
                   t.department_id, t.created_by, t.version, t.created_at, t.updated_at,
                   d.name as department_name, e.name as created_by_name
            FROM tasks t
            JOIN departments d ON t.department_id = d.id
            JOIN employees e ON t.created_by = e.id
            WHERE t.id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Task task = mapResultSetToTask(rs);
                
                // Load assignments
                task.setAssignments(getTaskAssignments(id));
                
                // Load dependencies
                task.setDependencies(getTaskDependencies(id));
                
                // Check if task is blocked
                task.setBlocked(isTaskBlocked(id));
                
                return task;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get tasks with filtering and pagination
     */
    public List<Task> getTasks(Map<String, Object> filters, int offset, int limit) {
        StringBuilder sql = new StringBuilder("""
            SELECT t.id, t.title, t.description, t.priority, t.status, t.due_date,
                   t.department_id, t.created_by, t.version, t.created_at, t.updated_at,
                   d.name as department_name, e.name as created_by_name
            FROM tasks t
            JOIN departments d ON t.department_id = d.id
            JOIN employees e ON t.created_by = e.id
            WHERE 1=1
        """);
        
        List<Object> params = new ArrayList<>();
        
        // Apply filters
        if (filters.get("status") != null) {
            sql.append(" AND t.status = ?");
            params.add(filters.get("status"));
        }
        
        if (filters.get("priority") != null) {
            sql.append(" AND t.priority = ?");
            params.add(filters.get("priority"));
        }
        
        if (filters.get("departmentId") != null) {
            sql.append(" AND t.department_id = ?");
            params.add(filters.get("departmentId"));
        }
        
        if (filters.get("assignedTo") != null) {
            sql.append(" AND EXISTS (SELECT 1 FROM task_assignments ta WHERE ta.task_id = t.id AND ta.employee_id = ?)");
            params.add(filters.get("assignedTo"));
        }
        
        if (filters.get("createdBy") != null) {
            sql.append(" AND t.created_by = ?");
            params.add(filters.get("createdBy"));
        }
        
        if (filters.get("dueDateFrom") != null) {
            sql.append(" AND t.due_date >= ?");
            params.add(filters.get("dueDateFrom"));
        }
        
        if (filters.get("dueDateTo") != null) {
            sql.append(" AND t.due_date <= ?");
            params.add(filters.get("dueDateTo"));
        }
        
        if (filters.get("search") != null) {
            sql.append(" AND (t.title LIKE ? OR t.description LIKE ?)");
            String searchTerm = "%" + filters.get("search") + "%";
            params.add(searchTerm);
            params.add(searchTerm);
        }
        
        // Add ordering
        sql.append(" ORDER BY ");
        String sortBy = (String) filters.get("sortBy");
        if ("priority".equals(sortBy)) {
            sql.append("FIELD(t.priority, 'HIGH', 'MEDIUM', 'LOW'), t.due_date");
        } else if ("dueDate".equals(sortBy)) {
            sql.append("t.due_date");
        } else if ("status".equals(sortBy)) {
            sql.append("FIELD(t.status, 'PENDING', 'IN_PROGRESS', 'UNDER_REVIEW', 'REJECTED', 'COMPLETED', 'CANCELLED')");
        } else {
            sql.append("t.created_at DESC");
        }
        
        // Add pagination
        sql.append(" LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);
        
        List<Task> tasks = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Task task = mapResultSetToTask(rs);
                
                // Load basic assignment info for list view
                task.setAssignments(getTaskAssignments(task.getId()));
                
                tasks.add(task);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return tasks;
    }
    
    /**
     * Update task with optimistic locking
     */
    public boolean update(Task task) {
        String sql = """
            UPDATE tasks 
            SET title = ?, description = ?, priority = ?, due_date = ?, version = version + 1
            WHERE id = ? AND version = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, task.getTitle());
            stmt.setString(2, task.getDescription());
            stmt.setString(3, task.getPriority().name());
            stmt.setDate(4, Date.valueOf(task.getDueDate()));
            stmt.setInt(5, task.getId());
            stmt.setInt(6, task.getVersion());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                task.setVersion(task.getVersion() + 1);
                return true;
            } else {
                // Optimistic locking conflict
                return false;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Update task status with workflow validation
     */
    public boolean updateStatus(int taskId, Task.Status newStatus, int updatedBy, int currentVersion) {
        // First check if transition is valid and task is not blocked
        Task task = getById(taskId);
        if (task == null) return false;
        
        // Check version for optimistic locking
        if (task.getVersion() != currentVersion) {
            return false; // Concurrent modification
        }
        
        // Check if task is blocked by dependencies (except for ADMIN override)
        if (newStatus == Task.Status.COMPLETED && isTaskBlocked(taskId)) {
            return false;
        }
        
        String sql = """
            UPDATE tasks 
            SET status = ?, version = version + 1
            WHERE id = ? AND version = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, newStatus.name());
            stmt.setInt(2, taskId);
            stmt.setInt(3, currentVersion);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Delete task (with dependency checks)
     */
    public boolean delete(int taskId) {
        // Check if other tasks depend on this task
        if (hasDependendTasks(taskId)) {
            return false;
        }
        
        String sql = "DELETE FROM tasks WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get task assignments
     */
    public List<TaskAssignment> getTaskAssignments(int taskId) {
        String sql = """
            SELECT ta.id, ta.task_id, ta.employee_id, ta.assignment_type, ta.assigned_at, ta.assigned_by,
                   e.name as employee_name, e.email as employee_email, ab.name as assigned_by_name
            FROM task_assignments ta
            JOIN employees e ON ta.employee_id = e.id
            JOIN employees ab ON ta.assigned_by = ab.id
            WHERE ta.task_id = ?
            ORDER BY ta.assignment_type, e.name
        """;
        
        List<TaskAssignment> assignments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                TaskAssignment assignment = new TaskAssignment();
                assignment.setId(rs.getInt("id"));
                assignment.setTaskId(rs.getInt("task_id"));
                assignment.setEmployeeId(rs.getInt("employee_id"));
                assignment.setEmployeeName(rs.getString("employee_name"));
                assignment.setEmployeeEmail(rs.getString("employee_email"));
                assignment.setAssignmentType(TaskAssignment.AssignmentType.valueOf(rs.getString("assignment_type")));
                assignment.setAssignedAt(rs.getTimestamp("assigned_at"));
                assignment.setAssignedBy(rs.getInt("assigned_by"));
                assignment.setAssignedByName(rs.getString("assigned_by_name"));
                
                assignments.add(assignment);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return assignments;
    }
    
    /**
     * Assign employee to task
     */
    public boolean assignEmployee(int taskId, int employeeId, TaskAssignment.AssignmentType type, int assignedBy) {
        String sql = """
            INSERT INTO task_assignments (task_id, employee_id, assignment_type, assigned_by)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE assignment_type = VALUES(assignment_type), assigned_by = VALUES(assigned_by)
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            stmt.setInt(2, employeeId);
            stmt.setString(3, type.name());
            stmt.setInt(4, assignedBy);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Remove employee assignment
     */
    public boolean removeAssignment(int taskId, int employeeId) {
        String sql = "DELETE FROM task_assignments WHERE task_id = ? AND employee_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            stmt.setInt(2, employeeId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get task dependencies
     */
    public List<TaskDependency> getTaskDependencies(int taskId) {
        String sql = """
            SELECT td.id, td.task_id, td.depends_on_task_id, td.created_at, td.created_by,
                   t.title as depends_on_task_title, t.status as depends_on_task_status,
                   e.name as created_by_name
            FROM task_dependencies td
            JOIN tasks t ON td.depends_on_task_id = t.id
            JOIN employees e ON td.created_by = e.id
            WHERE td.task_id = ?
            ORDER BY td.created_at
        """;
        
        List<TaskDependency> dependencies = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                TaskDependency dependency = new TaskDependency();
                dependency.setId(rs.getInt("id"));
                dependency.setTaskId(rs.getInt("task_id"));
                dependency.setDependsOnTaskId(rs.getInt("depends_on_task_id"));
                dependency.setDependsOnTaskTitle(rs.getString("depends_on_task_title"));
                dependency.setDependsOnTaskStatus(Task.Status.valueOf(rs.getString("depends_on_task_status")));
                dependency.setCreatedAt(rs.getTimestamp("created_at"));
                dependency.setCreatedBy(rs.getInt("created_by"));
                dependency.setCreatedByName(rs.getString("created_by_name"));
                
                dependencies.add(dependency);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return dependencies;
    }
    
    /**
     * Add task dependency with circular dependency check
     */
    public boolean addDependency(int taskId, int dependsOnTaskId, int createdBy) {
        // Check for circular dependency
        if (wouldCreateCircularDependency(taskId, dependsOnTaskId)) {
            return false;
        }
        
        String sql = """
            INSERT INTO task_dependencies (task_id, depends_on_task_id, created_by)
            VALUES (?, ?, ?)
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            stmt.setInt(2, dependsOnTaskId);
            stmt.setInt(3, createdBy);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Remove task dependency
     */
    public boolean removeDependency(int taskId, int dependsOnTaskId) {
        String sql = "DELETE FROM task_dependencies WHERE task_id = ? AND depends_on_task_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            stmt.setInt(2, dependsOnTaskId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Check if task is blocked by incomplete dependencies
     */
    public boolean isTaskBlocked(int taskId) {
        String sql = """
            SELECT COUNT(*) FROM task_dependencies td
            JOIN tasks t ON td.depends_on_task_id = t.id
            WHERE td.task_id = ? AND t.status != 'COMPLETED'
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Check if adding dependency would create circular dependency
     */
    private boolean wouldCreateCircularDependency(int taskId, int dependsOnTaskId) {
        // Use depth-first search to detect cycles
        return hasPath(dependsOnTaskId, taskId, new ArrayList<>());
    }
    
    /**
     * Recursive method to check if there's a path from source to target
     */
    private boolean hasPath(int sourceTaskId, int targetTaskId, List<Integer> visited) {
        if (sourceTaskId == targetTaskId) {
            return true;
        }
        
        if (visited.contains(sourceTaskId)) {
            return false; // Already visited this node
        }
        
        visited.add(sourceTaskId);
        
        String sql = "SELECT depends_on_task_id FROM task_dependencies WHERE task_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, sourceTaskId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                int nextTaskId = rs.getInt("depends_on_task_id");
                if (hasPath(nextTaskId, targetTaskId, new ArrayList<>(visited))) {
                    return true;
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Check if task has dependent tasks
     */
    private boolean hasDependendTasks(int taskId) {
        String sql = "SELECT COUNT(*) FROM task_dependencies WHERE depends_on_task_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get overdue tasks for escalation
     */
    public List<Task> getOverdueTasks() {
        String sql = """
            SELECT t.id, t.title, t.description, t.priority, t.status, t.due_date,
                   t.department_id, t.created_by, t.version, t.created_at, t.updated_at,
                   d.name as department_name, e.name as created_by_name
            FROM tasks t
            JOIN departments d ON t.department_id = d.id
            JOIN employees e ON t.created_by = e.id
            WHERE t.due_date < CURDATE() 
            AND t.status IN ('PENDING', 'IN_PROGRESS', 'UNDER_REVIEW')
            AND TIMESTAMPDIFF(HOUR, t.due_date, NOW()) >= 24
        """;
        
        List<Task> tasks = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                tasks.add(mapResultSetToTask(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return tasks;
    }
    
    /**
     * Get task count by status for dashboard
     */
    public Map<String, Integer> getTaskCountByStatus(Integer departmentId, Integer employeeId) {
        StringBuilder sql = new StringBuilder("""
            SELECT t.status, COUNT(*) as count
            FROM tasks t
        """);
        
        List<Object> params = new ArrayList<>();
        
        if (employeeId != null) {
            sql.append(" JOIN task_assignments ta ON t.id = ta.task_id");
        }
        
        sql.append(" WHERE 1=1");
        
        if (departmentId != null) {
            sql.append(" AND t.department_id = ?");
            params.add(departmentId);
        }
        
        if (employeeId != null) {
            sql.append(" AND ta.employee_id = ?");
            params.add(employeeId);
        }
        
        sql.append(" GROUP BY t.status");
        
        Map<String, Integer> statusCounts = new HashMap<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                statusCounts.put(rs.getString("status"), rs.getInt("count"));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return statusCounts;
    }
    
    /**
     * Map ResultSet to Task object
     */
    private Task mapResultSetToTask(ResultSet rs) throws SQLException {
        Task task = new Task();
        task.setId(rs.getInt("id"));
        task.setTitle(rs.getString("title"));
        task.setDescription(rs.getString("description"));
        task.setPriority(Task.Priority.valueOf(rs.getString("priority")));
        task.setStatus(Task.Status.valueOf(rs.getString("status")));
        task.setDueDate(rs.getDate("due_date").toLocalDate());
        task.setDepartmentId(rs.getInt("department_id"));
        task.setDepartmentName(rs.getString("department_name"));
        task.setCreatedBy(rs.getInt("created_by"));
        task.setCreatedByName(rs.getString("created_by_name"));
        task.setVersion(rs.getInt("version"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            task.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            task.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        // Set workload score
        task.setWorkloadScore(task.calculateWorkloadScore());
        
        return task;
    }
    
    // Additional methods for servlet compatibility
    
    /**
     * Alias for getById() method for servlet compatibility
     */
    public Task getTaskById(int id) {
        return getById(id);
    }
    
    /**
     * Check if employee is assigned to task
     */
    public boolean isEmployeeAssignedToTask(int taskId, int employeeId) {
        String sql = "SELECT COUNT(*) FROM task_assignments WHERE task_id = ? AND employee_id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            stmt.setInt(2, employeeId);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Check if user can access task (assigned or admin/manager)
     */
    public boolean canAccessTask(Employee currentUser, Task task) {
        // Admin can access all tasks
        if (currentUser.getRole() == Employee.Role.ADMIN) {
            return true;
        }
        
        // Manager can access tasks in their department
        if (currentUser.getRole() == Employee.Role.MANAGER && 
            currentUser.getDepartmentId() == task.getDepartmentId()) {
            return true;
        }
        
        // Employee can access tasks assigned to them
        return isEmployeeAssignedToTask(task.getId(), currentUser.getId());
    }
    
    /**
     * Get tasks for dependency selection (exclude current task and completed/cancelled)
     */
    public List<Task> getTasksForDependency(int excludeTaskId) {
        String sql = """
            SELECT t.id, t.title, t.description, t.priority, t.status, t.due_date,
                   t.department_id, t.created_by, t.version, t.created_at, t.updated_at,
                   d.name as department_name, e.name as created_by_name
            FROM tasks t
            JOIN departments d ON t.department_id = d.id
            JOIN employees e ON t.created_by = e.id
            WHERE t.id != ? AND t.status NOT IN ('COMPLETED', 'CANCELLED')
            ORDER BY t.title
        """;
        
        List<Task> tasks = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, excludeTaskId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                tasks.add(mapResultSetToTask(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return tasks;
    }
    
    /**
     * Update task with related data (assignments, dependencies)
     */
    public boolean updateTaskWithRelatedData(Task task, List<TaskAssignment> assignments, List<TaskDependency> dependencies) {
        // For now, just update the basic task - full implementation would handle related data
        return update(task);
    }
    
    /**
     * Update task with related data changes (for servlet compatibility)
     */
    public boolean updateTaskWithRelatedData(Task task, Map<String, Object> assignmentChanges, 
                                           Map<String, Object> dependencyChanges, int updatedBy) {
        Connection conn = null;
        try {
            conn = DatabaseConfig.getConnection();
            conn.setAutoCommit(false);
            
            // Update the basic task first
            if (!update(task)) {
                conn.rollback();
                return false;
            }
            
            // Process assignment changes
            if (assignmentChanges != null) {
                processAssignmentChanges(task.getId(), assignmentChanges, updatedBy, conn);
            }
            
            // Process dependency changes
            if (dependencyChanges != null) {
                processDependencyChanges(task.getId(), dependencyChanges, updatedBy, conn);
            }
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    private void processAssignmentChanges(int taskId, Map<String, Object> changes, int updatedBy, Connection conn) 
            throws SQLException {
        
        // Handle added assignments
        @SuppressWarnings("unchecked")
        List<Integer> addedAssignees = (List<Integer>) changes.get("added");
        if (addedAssignees != null) {
            String sql = "INSERT INTO task_assignments (task_id, employee_id, assigned_by, assigned_at) VALUES (?, ?, ?, CURRENT_TIMESTAMP)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                for (Integer employeeId : addedAssignees) {
                    stmt.setInt(1, taskId);
                    stmt.setInt(2, employeeId);
                    stmt.setInt(3, updatedBy);
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }
        }
        
        // Handle removed assignments
        @SuppressWarnings("unchecked")
        List<Integer> removedAssignees = (List<Integer>) changes.get("removed");
        if (removedAssignees != null) {
            String sql = "DELETE FROM task_assignments WHERE task_id = ? AND employee_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                for (Integer employeeId : removedAssignees) {
                    stmt.setInt(1, taskId);
                    stmt.setInt(2, employeeId);
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }
        }
    }
    
    private void processDependencyChanges(int taskId, Map<String, Object> changes, int updatedBy, Connection conn) 
            throws SQLException {
        
        // Handle added dependencies
        @SuppressWarnings("unchecked")
        List<Integer> addedDependencies = (List<Integer>) changes.get("added");
        if (addedDependencies != null) {
            String sql = "INSERT INTO task_dependencies (task_id, depends_on_task_id, created_by) VALUES (?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                for (Integer dependsOnTaskId : addedDependencies) {
                    stmt.setInt(1, taskId);
                    stmt.setInt(2, dependsOnTaskId);
                    stmt.setInt(3, updatedBy);
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }
        }
        
        // Handle removed dependencies
        @SuppressWarnings("unchecked")
        List<Integer> removedDependencies = (List<Integer>) changes.get("removed");
        if (removedDependencies != null) {
            String sql = "DELETE FROM task_dependencies WHERE task_id = ? AND depends_on_task_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                for (Integer dependsOnTaskId : removedDependencies) {
                    stmt.setInt(1, taskId);
                    stmt.setInt(2, dependsOnTaskId);
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }
        }
    }
    

    
    /**
     * Get tasks assigned to employee with pagination
     */
    public List<Task> getTasksAssignedToEmployee(int employeeId, int offset, int limit) {
        String sql = """
            SELECT t.id, t.title, t.description, t.priority, t.status, t.due_date,
                   t.department_id, t.created_by, t.version, t.created_at, t.updated_at,
                   d.name as department_name, e.name as created_by_name
            FROM tasks t
            JOIN departments d ON t.department_id = d.id
            JOIN employees e ON t.created_by = e.id
            JOIN task_assignments ta ON t.id = ta.task_id
            WHERE ta.employee_id = ?
            ORDER BY t.created_at DESC
            LIMIT ? OFFSET ?
        """;
        
        List<Task> tasks = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            stmt.setInt(2, limit);
            stmt.setInt(3, offset);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Task task = mapResultSetToTask(rs);
                
                // Load basic assignment info for list view
                task.setAssignments(getTaskAssignments(task.getId()));
                
                tasks.add(task);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return tasks;
    }
    
    /**
     * Get total tasks for employee
     */
    public int getTotalTasksForEmployee(int employeeId) {
        String sql = """
            SELECT COUNT(*) FROM task_assignments ta
            JOIN tasks t ON ta.task_id = t.id
            WHERE ta.employee_id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Get completed tasks for employee
     */
    public int getCompletedTasksForEmployee(int employeeId) {
        String sql = """
            SELECT COUNT(*) FROM task_assignments ta
            JOIN tasks t ON ta.task_id = t.id
            WHERE ta.employee_id = ? AND t.status = 'COMPLETED'
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Get in progress tasks for employee
     */
    public int getInProgressTasksForEmployee(int employeeId) {
        String sql = """
            SELECT COUNT(*) FROM task_assignments ta
            JOIN tasks t ON ta.task_id = t.id
            WHERE ta.employee_id = ? AND t.status = 'IN_PROGRESS'
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Get overdue tasks for employee
     */
    public int getOverdueTasksForEmployee(int employeeId) {
        String sql = """
            SELECT COUNT(*) FROM task_assignments ta
            JOIN tasks t ON ta.task_id = t.id
            WHERE ta.employee_id = ? AND t.due_date < CURDATE() 
            AND t.status IN ('PENDING', 'IN_PROGRESS', 'UNDER_REVIEW')
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
}