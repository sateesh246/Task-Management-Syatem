package com.taskmanagement.servlet;

import com.taskmanagement.config.DatabaseConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Simple test servlet to verify basic functionality
 */
@WebServlet(name = "TestServlet", urlPatterns = {"/test", "/status"})
public class TestServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head><title>Task Management System - Status</title></head>");
        out.println("<body>");
        out.println("<h1>Task Management System - Status Check</h1>");
        out.println("<p>✅ Servlet container is working correctly.</p>");
        out.println("<p>⏰ Current time: " + new java.util.Date() + "</p>");
        
        // Test database connection
        out.println("<h2>Database Connection Test:</h2>");
        try {
            boolean dbConnected = DatabaseConfig.testConnection();
            if (dbConnected) {
                out.println("<p style='color: green; font-weight: bold;'>✅ Database connection: SUCCESS</p>");
                out.println("<p>MySQL database is accessible at localhost:3306/task_management</p>");
            } else {
                out.println("<p style='color: red; font-weight: bold;'>❌ Database connection: FAILED</p>");
                out.println("<p>Check if MySQL is running and database exists</p>");
            }
        } catch (Exception e) {
            out.println("<p style='color: red; font-weight: bold;'>❌ Database error: " + e.getMessage() + "</p>");
            out.println("<p>This usually means MySQL JDBC driver is missing from lib/ directory</p>");
        }
        
        out.println("<hr>");
        out.println("<p><a href='" + request.getContextPath() + "/'>← Back to Home</a></p>");
        out.println("</body>");
        out.println("</html>");
    }
}