package com.taskmanagement.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class DatabaseConfig {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/task_management";
    private static final String DB_USERNAME = "root";
    private static final String DB_PASSWORD = "root";
    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    
    // Static block to load the MySQL driver when class is loaded
    static {
        try {
            Class.forName(DB_DRIVER);
            System.out.println("MySQL Driver loaded successfully: " + DB_DRIVER);
        } catch (ClassNotFoundException e) {
            System.err.println("Failed to load MySQL Driver: " + e.getMessage());
            e.printStackTrace();
        }
    }
   
    public static Connection getConnection() throws SQLException {
        try {
            // Explicitly load the MySQL driver using the DB_DRIVER constant
            Class.forName(DB_DRIVER);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver not found: " + e.getMessage(), e);
        }
        return DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
    }
    
    /**
     * Test database connectivity
     * @return true if connection is successful
     */
    public static boolean testConnection() {
        try {
            // Explicitly load the MySQL driver
            Class.forName(DB_DRIVER);
            try (Connection conn = getConnection()) {
                return conn != null && !conn.isClosed();
            }
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL Driver not found: " + e.getMessage());
            return false;
        } catch (SQLException e) {
            System.err.println("Database connection failed: " + e.getMessage());
            return false;
        }
    }
}