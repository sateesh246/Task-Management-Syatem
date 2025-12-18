package com.taskmanagement.dao;

import com.taskmanagement.config.DatabaseConfig;
import com.taskmanagement.model.Department;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Department operations
 */
public class DepartmentDAO {
    
    /**
     * Get all departments
     */
    public List<Department> getAll() {
        String sql = "SELECT id, name, description, created_at, updated_at FROM departments ORDER BY name";
        List<Department> departments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                departments.add(mapResultSetToDepartment(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return departments;
    }
    
    /**
     * Get all departments with statistics
     */
    public List<Department> getAllWithStats() {
        String sql = """
            SELECT d.id, d.name, d.description, d.created_at, d.updated_at,
                   COUNT(DISTINCT e.id) as employee_count,
                   COUNT(DISTINCT CASE WHEN t.status NOT IN ('COMPLETED', 'CANCELLED') THEN t.id END) as active_task_count,
                   COUNT(DISTINCT CASE WHEN t.status = 'COMPLETED' THEN t.id END) as completed_task_count
            FROM departments d
            LEFT JOIN employees e ON d.id = e.department_id AND e.is_active = TRUE
            LEFT JOIN tasks t ON d.id = t.department_id
            GROUP BY d.id, d.name, d.description, d.created_at, d.updated_at
            ORDER BY d.name
        """;
        
        List<Department> departments = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Department dept = mapResultSetToDepartment(rs);
                dept.setEmployeeCount(rs.getInt("employee_count"));
                dept.setActiveTaskCount(rs.getInt("active_task_count"));
                dept.setCompletedTaskCount(rs.getInt("completed_task_count"));
                departments.add(dept);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return departments;
    }
    
    /**
     * Get department by ID
     */
    public Department getById(int id) {
        String sql = "SELECT id, name, description, created_at, updated_at FROM departments WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToDepartment(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Create new department
     */
    public boolean create(Department department) {
        String sql = "INSERT INTO departments (name, description) VALUES (?, ?)";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, department.getName());
            stmt.setString(2, department.getDescription());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    department.setId(generatedKeys.getInt(1));
                }
                return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Update department
     */
    public boolean update(Department department) {
        String sql = "UPDATE departments SET name = ?, description = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, department.getName());
            stmt.setString(2, department.getDescription());
            stmt.setInt(3, department.getId());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Delete department (only if no employees or tasks)
     */
    public boolean delete(int departmentId) {
        // Check if department has employees or tasks
        if (hasEmployeesOrTasks(departmentId)) {
            return false;
        }
        
        String sql = "DELETE FROM departments WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, departmentId);
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Check if department name already exists
     */
    public boolean nameExists(String name, Integer excludeId) {
        String sql = "SELECT COUNT(*) FROM departments WHERE name = ?";
        if (excludeId != null) {
            sql += " AND id != ?";
        }
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, name);
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
     * Check if department has employees or tasks
     */
    private boolean hasEmployeesOrTasks(int departmentId) {
        String sql = """
            SELECT 
                (SELECT COUNT(*) FROM employees WHERE department_id = ?) +
                (SELECT COUNT(*) FROM tasks WHERE department_id = ?) as total_count
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, departmentId);
            stmt.setInt(2, departmentId);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("total_count") > 0;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Map ResultSet to Department object
     */
    private Department mapResultSetToDepartment(ResultSet rs) throws SQLException {
        Department department = new Department();
        department.setId(rs.getInt("id"));
        department.setName(rs.getString("name"));
        department.setDescription(rs.getString("description"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            department.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            department.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return department;
    }
    
    /**
     * Get all departments with statistics
     */
    
}