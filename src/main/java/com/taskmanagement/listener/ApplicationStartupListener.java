package com.taskmanagement.listener;

import com.taskmanagement.config.DatabaseConfig;
import com.taskmanagement.dao.EmployeeDAO;
import com.taskmanagement.util.PasswordUtil;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * Application startup listener to initialize the system
 * Handles database connection testing and password hashing for existing users
 */
@WebListener
public class ApplicationStartupListener implements ServletContextListener {
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("=== Enterprise Task Management System Starting ===");
        
        // Test database connection
        if (DatabaseConfig.testConnection()) {
            System.out.println("✓ Database connection successful");
            
            // Hash existing plain text passwords
            hashExistingPasswords();
            
        } else {
            System.err.println("✗ Database connection failed!");
            System.err.println("Please ensure MySQL is running and database 'task_management' exists");
        }
        
        System.out.println("=== Application Started Successfully ===");
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("=== Enterprise Task Management System Shutting Down ===");
        
        // Note: Using DriverManager connections, no connection pool to close
        System.out.println("Database connections will be closed automatically");
        
        System.out.println("=== Application Shutdown Complete ===");
    }
    
    /**
     * Hash existing plain text passwords in the database
     * This is needed for the demo data which has plain text passwords
     */
    private void hashExistingPasswords() {
        String checkSql = "SELECT COUNT(*) FROM employees WHERE password = 'password123'";
        String updateSql = "UPDATE employees SET password = ? WHERE password = 'password123'";
        
        try (Connection conn = DatabaseConfig.getConnection()) {
            
            // Check if there are plain text passwords
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            var rs = checkStmt.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                System.out.println("Hashing plain text passwords...");
                
                // Hash the password
                String hashedPassword = PasswordUtil.hashPassword("password123");
                
                // Update all plain text passwords
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setString(1, hashedPassword);
                int updated = updateStmt.executeUpdate();
                
                System.out.println("✓ Hashed " + updated + " passwords");
            }
            
        } catch (SQLException e) {
            System.err.println("Error hashing passwords: " + e.getMessage());
        }
    }
}