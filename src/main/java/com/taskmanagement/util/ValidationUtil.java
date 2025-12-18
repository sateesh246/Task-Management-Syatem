package com.taskmanagement.util;

import java.time.LocalDate;
import java.util.regex.Pattern;

/**
 * Utility class for input validation
 * Provides comprehensive validation for all user inputs
 */
public class ValidationUtil {
    
    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@([A-Za-z0-9.-]+\\.[A-Za-z]{2,})$");
    
    private static final Pattern NAME_PATTERN = 
        Pattern.compile("^[A-Za-z\\s]{2,50}$");
    
    private static final Pattern TITLE_PATTERN = 
        Pattern.compile("^[A-Za-z0-9\\s\\-_.,!?()]{3,200}$");
    
    /**
     * Validate email format
     */
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }
    
    /**
     * Validate name format (letters and spaces only)
     */
    public static boolean isValidName(String name) {
        return name != null && NAME_PATTERN.matcher(name).matches();
    }
    
    /**
     * Validate password strength
     * Must be at least 8 characters with uppercase, lowercase, number, and special character
     */
    public static boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        
        boolean hasUpper = password.chars().anyMatch(Character::isUpperCase);
        boolean hasLower = password.chars().anyMatch(Character::isLowerCase);
        boolean hasDigit = password.chars().anyMatch(Character::isDigit);
        boolean hasSpecial = password.chars().anyMatch(ch -> "!@#$%^&*()_+-=[]{}|;:,.<>?".indexOf(ch) >= 0);
        
        return hasUpper && hasLower && hasDigit && hasSpecial;
    }
    
    /**
     * Validate task title
     */
    public static boolean isValidTitle(String title) {
        return title != null && TITLE_PATTERN.matcher(title).matches();
    }
    
    /**
     * Validate task title (alias for servlet compatibility)
     */
    public static boolean isValidTaskTitle(String title) {
        return isValidTitle(title);
    }
    
    /**
     * Validate description (not empty, reasonable length)
     */
    public static boolean isValidDescription(String description) {
        return description != null && 
               description.trim().length() >= 10 && 
               description.trim().length() <= 2000;
    }
    
    /**
     * Validate task description (alias for servlet compatibility)
     */
    public static boolean isValidTaskDescription(String description) {
        return isValidDescription(description);
    }
    
    /**
     * Validate due date (must be in the future)
     */
    public static boolean isValidDueDate(LocalDate dueDate) {
        return dueDate != null && !dueDate.isBefore(LocalDate.now());
    }
    
    /**
     * Validate ID (positive integer)
     */
    public static boolean isValidId(int id) {
        return id > 0;
    }
    
    /**
     * Validate string is not null or empty
     */
    public static boolean isNotEmpty(String str) {
        return str != null && !str.trim().isEmpty();
    }
    
    /**
     * Sanitize string input to prevent XSS
     */
    public static String sanitizeInput(String input) {
        if (input == null) return null;
        
        return input.trim()
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#x27;")
                   .replace("/", "&#x2F;");
    }
    
    /**
     * Validate comment text
     */
    public static boolean isValidComment(String comment) {
        return comment != null && 
               comment.trim().length() >= 1 && 
               comment.trim().length() <= 1000;
    }
    
    /**
     * Validate work session notes
     */
    public static boolean isValidSessionNotes(String notes) {
        return notes == null || notes.length() <= 500;
    }
    
    /**
     * Check if string contains only alphanumeric characters and common symbols
     */
    public static boolean isSafeString(String str) {
        if (str == null) return true;
        return str.matches("^[A-Za-z0-9\\s\\-_.,!?()@#$%^&*+=\\[\\]{}|;:\"'<>/\\\\]*$");
    }
    
    /**
     * Validate department name
     */
    public static boolean isValidDepartmentName(String name) {
        return name != null && 
               name.trim().length() >= 2 && 
               name.trim().length() <= 100 &&
               name.matches("^[A-Za-z0-9\\s\\-&]+$");
    }
    
    /**
     * Validate notification message
     */
    public static boolean isValidNotificationMessage(String message) {
        return message != null && 
               message.trim().length() >= 1 && 
               message.trim().length() <= 500;
    }
}