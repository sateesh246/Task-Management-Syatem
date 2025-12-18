package com.taskmanagement.dao;

import com.taskmanagement.config.DatabaseConfig;
import com.taskmanagement.model.Employee;
import com.taskmanagement.util.PasswordUtil;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Employee operations
 * Handles all database operations related to employees/users
 */
public class EmployeeDAO {
    
    /**
     * Authenticate user login
     */
    public Employee authenticate(String email, String password) {
        String sql = """
            SELECT e.id, e.name, e.email, e.password, e.role, e.department_id, 
                   e.manager_id, e.is_active, e.created_at, e.updated_at,
                   d.name as department_name, m.name as manager_name
            FROM employees e
            LEFT JOIN departments d ON e.department_id = d.id
            LEFT JOIN employees m ON e.manager_id = m.id
            WHERE e.email = ? AND e.is_active = TRUE
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                String storedPassword = rs.getString("password");
                
                // For demo purposes, check both hashed and plain text passwords
                if (PasswordUtil.verifyPassword(password, storedPassword) || 
                    password.equals(storedPassword)) {
                    
                    Employee employee = mapResultSetToEmployee(rs);
                    return employee;
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get employee by ID
     */
    public Employee getById(int id) {
        String sql = """
            SELECT e.id, e.name, e.email, e.password, e.role, e.department_id, 
                   e.manager_id, e.is_active, e.created_at, e.updated_at,
                   d.name as department_name, m.name as manager_name
            FROM employees e
            LEFT JOIN departments d ON e.department_id = d.id
            LEFT JOIN employees m ON e.manager_id = m.id
            WHERE e.id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToEmployee(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get employee by ID (alias for servlet compatibility)
     */
    public Employee getEmployeeById(int id) {
        return getById(id);
    }
    
    /**
     * Get all employees with optional filtering
     */
    public List<Employee> getAll(Employee.Role role, Integer departmentId, boolean activeOnly) {
        StringBuilder sql = new StringBuilder("""
            SELECT e.id, e.name, e.email, e.password, e.role, e.department_id, 
                   e.manager_id, e.is_active, e.created_at, e.updated_at,
                   d.name as department_name, m.name as manager_name
            FROM employees e
            LEFT JOIN departments d ON e.department_id = d.id
            LEFT JOIN employees m ON e.manager_id = m.id
            WHERE 1=1
        """);
        
        List<Object> params = new ArrayList<>();
        
        if (role != null) {
            sql.append(" AND e.role = ?");
            params.add(role.name());
        }
        
        if (departmentId != null) {
            sql.append(" AND e.department_id = ?");
            params.add(departmentId);
        }
        
        if (activeOnly) {
            sql.append(" AND e.is_active = TRUE");
        }
        
        sql.append(" ORDER BY e.name");
        
        List<Employee> employees = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                employees.add(mapResultSetToEmployee(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return employees;
    }
    
    /**
     * Get all active employees
     */
    public List<Employee> getAllActiveEmployees() {
        return getAll(null, null, true);
    }
    
    /**
     * Get employees by department
     */
    public List<Employee> getByDepartment(int departmentId) {
        return getAll(null, departmentId, true);
    }
    
    /**
     * Get employees by department (alias for servlet compatibility)
     */
    public List<Employee> getEmployeesByDepartment(int departmentId) {
        return getByDepartment(departmentId);
    }
    
    /**
     * Get subordinates of a manager
     */
    public List<Employee> getSubordinates(int managerId) {
        String sql = """
            SELECT e.id, e.name, e.email, e.password, e.role, e.department_id, 
                   e.manager_id, e.is_active, e.created_at, e.updated_at,
                   d.name as department_name, m.name as manager_name
            FROM employees e
            LEFT JOIN departments d ON e.department_id = d.id
            LEFT JOIN employees m ON e.manager_id = m.id
            WHERE e.manager_id = ? AND e.is_active = TRUE
            ORDER BY e.name
        """;
        
        List<Employee> employees = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, managerId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                employees.add(mapResultSetToEmployee(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return employees;
    }
    
    /**
     * Create new employee
     */
    public boolean create(Employee employee) {
        String sql = """
            INSERT INTO employees (name, email, password, role, department_id, manager_id, is_active)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, employee.getName());
            stmt.setString(2, employee.getEmail());
            stmt.setString(3, PasswordUtil.hashPassword(employee.getPassword()));
            stmt.setString(4, employee.getRole().name());
            stmt.setInt(5, employee.getDepartmentId());
            
            if (employee.getManagerId() != null) {
                stmt.setInt(6, employee.getManagerId());
            } else {
                stmt.setNull(6, Types.INTEGER);
            }
            
            stmt.setBoolean(7, employee.isActive());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    employee.setId(generatedKeys.getInt(1));
                }
                return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Update employee
     */
    public boolean update(Employee employee) {
        String sql = """
            UPDATE employees 
            SET name = ?, email = ?, role = ?, department_id = ?, manager_id = ?, is_active = ?
            WHERE id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, employee.getName());
            stmt.setString(2, employee.getEmail());
            stmt.setString(3, employee.getRole().name());
            stmt.setInt(4, employee.getDepartmentId());
            
            if (employee.getManagerId() != null) {
                stmt.setInt(5, employee.getManagerId());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }
            
            stmt.setBoolean(6, employee.isActive());
            stmt.setInt(7, employee.getId());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Update employee (alias for servlet compatibility)
     */
    public boolean updateEmployee(Employee employee) {
        return update(employee);
    }
    
    /**
     * Update password
     */
    public boolean updatePassword(int employeeId, String newPassword) {
        String sql = "UPDATE employees SET password = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, PasswordUtil.hashPassword(newPassword));
            stmt.setInt(2, employeeId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Soft delete employee (deactivate)
     */
    public boolean deactivate(int employeeId) {
        String sql = "UPDATE employees SET is_active = FALSE WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Check if email already exists
     */
    public boolean emailExists(String email, Integer excludeId) {
        String sql = "SELECT COUNT(*) FROM employees WHERE email = ?";
        if (excludeId != null) {
            sql += " AND id != ?";
        }
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            if (excludeId != null) {
                stmt.setInt(2, excludeId);
            }
            
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
     * Get employee workload (for workload management)
     */
    public List<Employee> getEmployeeWorkload(Integer departmentId) {
        String sql = """
            SELECT e.id, e.name, e.email, e.role, e.department_id,
                   d.name as department_name,
                   COUNT(CASE WHEN t.status = 'IN_PROGRESS' THEN 1 END) as in_progress_tasks,
                   COUNT(ta.task_id) as total_assigned_tasks,
                   SUM(CASE 
                       WHEN t.priority = 'HIGH' THEN 3
                       WHEN t.priority = 'MEDIUM' THEN 2
                       WHEN t.priority = 'LOW' THEN 1
                       ELSE 0
                   END) as workload_score
            FROM employees e
            JOIN departments d ON e.department_id = d.id
            LEFT JOIN task_assignments ta ON e.id = ta.employee_id
            LEFT JOIN tasks t ON ta.task_id = t.id AND t.status NOT IN ('COMPLETED', 'CANCELLED')
            WHERE e.is_active = TRUE
        """;
        
        if (departmentId != null) {
            sql += " AND e.department_id = ?";
        }
        
        sql += """
            GROUP BY e.id, e.name, e.email, e.role, e.department_id, d.name
            ORDER BY workload_score ASC, e.name
        """;
        
        List<Employee> employees = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            if (departmentId != null) {
                stmt.setInt(1, departmentId);
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Employee employee = new Employee();
                employee.setId(rs.getInt("id"));
                employee.setName(rs.getString("name"));
                employee.setEmail(rs.getString("email"));
                employee.setRole(Employee.Role.valueOf(rs.getString("role")));
                employee.setDepartmentId(rs.getInt("department_id"));
                employee.setDepartmentName(rs.getString("department_name"));
                
                employees.add(employee);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return employees;
    }
    
    /**
     * Map ResultSet to Employee object
     */
    private Employee mapResultSetToEmployee(ResultSet rs) throws SQLException {
        Employee employee = new Employee();
        employee.setId(rs.getInt("id"));
        employee.setName(rs.getString("name"));
        employee.setEmail(rs.getString("email"));
        employee.setPassword(rs.getString("password"));
        employee.setRole(Employee.Role.valueOf(rs.getString("role")));
        employee.setDepartmentId(rs.getInt("department_id"));
        employee.setDepartmentName(rs.getString("department_name"));
        
        int managerId = rs.getInt("manager_id");
        if (!rs.wasNull()) {
            employee.setManagerId(managerId);
            employee.setManagerName(rs.getString("manager_name"));
        }
        
        employee.setActive(rs.getBoolean("is_active"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            employee.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            employee.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return employee;
    }
}