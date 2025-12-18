package com.taskmanagement.dao;

import com.taskmanagement.config.DatabaseConfig;
import com.taskmanagement.model.WorkSession;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for WorkSession operations
 * Handles time tracking functionality for productivity analysis
 */
public class WorkSessionDAO {
    
    /**
     * Start a new work session
     */
    public boolean startSession(WorkSession session) {
        // First check if employee already has an active session for this task
        if (hasActiveSession(session.getTaskId(), session.getEmployeeId())) {
            return false; // Cannot start multiple sessions for same task
        }
        
        String sql = """
            INSERT INTO work_sessions (task_id, employee_id, start_time, notes)
            VALUES (?, ?, ?, ?)
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, session.getTaskId());
            stmt.setInt(2, session.getEmployeeId());
            stmt.setTimestamp(3, session.getStartTime());
            stmt.setString(4, session.getNotes());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    session.setId(generatedKeys.getInt(1));
                }
                return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * End a work session
     */
    public boolean endSession(int sessionId, String notes) {
        String sql = """
            UPDATE work_sessions 
            SET end_time = CURRENT_TIMESTAMP, notes = ?
            WHERE id = ? AND end_time IS NULL
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, notes);
            stmt.setInt(2, sessionId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get active session for employee and task
     */
    public WorkSession getActiveSession(int taskId, int employeeId) {
        String sql = """
            SELECT ws.id, ws.task_id, ws.employee_id, ws.start_time, ws.end_time, 
                   ws.duration_minutes, ws.notes, ws.created_at,
                   t.title as task_title, e.name as employee_name
            FROM work_sessions ws
            JOIN tasks t ON ws.task_id = t.id
            JOIN employees e ON ws.employee_id = e.id
            WHERE ws.task_id = ? AND ws.employee_id = ? AND ws.end_time IS NULL
            ORDER BY ws.start_time DESC
            LIMIT 1
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            stmt.setInt(2, employeeId);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToWorkSession(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get work sessions for a task
     */
    public List<WorkSession> getSessionsForTask(int taskId) {
        String sql = """
            SELECT ws.id, ws.task_id, ws.employee_id, ws.start_time, ws.end_time, 
                   ws.duration_minutes, ws.notes, ws.created_at,
                   t.title as task_title, e.name as employee_name
            FROM work_sessions ws
            JOIN tasks t ON ws.task_id = t.id
            JOIN employees e ON ws.employee_id = e.id
            WHERE ws.task_id = ?
            ORDER BY ws.start_time DESC
        """;
        
        List<WorkSession> sessions = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                sessions.add(mapResultSetToWorkSession(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return sessions;
    }
    
    /**
     * Get work sessions for an employee
     */
    public List<WorkSession> getSessionsForEmployee(int employeeId, LocalDateTime fromDate, LocalDateTime toDate) {
        StringBuilder sql = new StringBuilder("""
            SELECT ws.id, ws.task_id, ws.employee_id, ws.start_time, ws.end_time, 
                   ws.duration_minutes, ws.notes, ws.created_at,
                   t.title as task_title, e.name as employee_name
            FROM work_sessions ws
            JOIN tasks t ON ws.task_id = t.id
            JOIN employees e ON ws.employee_id = e.id
            WHERE ws.employee_id = ?
        """);
        
        List<Object> params = new ArrayList<>();
        params.add(employeeId);
        
        if (fromDate != null) {
            sql.append(" AND ws.start_time >= ?");
            params.add(Timestamp.valueOf(fromDate));
        }
        
        if (toDate != null) {
            sql.append(" AND ws.start_time <= ?");
            params.add(Timestamp.valueOf(toDate));
        }
        
        sql.append(" ORDER BY ws.start_time DESC");
        
        List<WorkSession> sessions = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                sessions.add(mapResultSetToWorkSession(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return sessions;
    }
    
    /**
     * Get total work time for employee on a task
     */
    public int getTotalWorkTimeMinutes(int taskId, int employeeId) {
        String sql = """
            SELECT COALESCE(SUM(duration_minutes), 0) as total_minutes
            FROM work_sessions 
            WHERE task_id = ? AND employee_id = ? AND end_time IS NOT NULL
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            stmt.setInt(2, employeeId);
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total_minutes");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Get total work time for all employees on a task
     */
    public int getTotalWorkTimeMinutes(int taskId, Integer employeeId) {
        String sql;
        if (employeeId == null) {
            sql = """
                SELECT COALESCE(SUM(duration_minutes), 0) as total_minutes
                FROM work_sessions 
                WHERE task_id = ? AND end_time IS NOT NULL
            """;
        } else {
            sql = """
                SELECT COALESCE(SUM(duration_minutes), 0) as total_minutes
                FROM work_sessions 
                WHERE task_id = ? AND employee_id = ? AND end_time IS NOT NULL
            """;
        }
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, taskId);
            if (employeeId != null) {
                stmt.setInt(2, employeeId);
            }
            
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total_minutes");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Get productivity statistics for employee
     */
    public List<Object[]> getEmployeeProductivityStats(int employeeId, LocalDateTime fromDate, LocalDateTime toDate) {
        String sql = """
            SELECT 
                DATE(ws.start_time) as work_date,
                COUNT(DISTINCT ws.task_id) as tasks_worked,
                COALESCE(SUM(ws.duration_minutes), 0) as total_minutes,
                COUNT(ws.id) as total_sessions
            FROM work_sessions ws
            WHERE ws.employee_id = ? 
            AND ws.start_time >= ? 
            AND ws.start_time <= ?
            AND ws.end_time IS NOT NULL
            GROUP BY DATE(ws.start_time)
            ORDER BY work_date DESC
        """;
        
        List<Object[]> stats = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            stmt.setTimestamp(2, Timestamp.valueOf(fromDate));
            stmt.setTimestamp(3, Timestamp.valueOf(toDate));
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Object[] row = {
                    rs.getDate("work_date"),
                    rs.getInt("tasks_worked"),
                    rs.getInt("total_minutes"),
                    rs.getInt("total_sessions")
                };
                stats.add(row);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
    
    /**
     * Get all active sessions (for monitoring)
     */
    public List<WorkSession> getAllActiveSessions() {
        String sql = """
            SELECT ws.id, ws.task_id, ws.employee_id, ws.start_time, ws.end_time, 
                   ws.duration_minutes, ws.notes, ws.created_at,
                   t.title as task_title, e.name as employee_name
            FROM work_sessions ws
            JOIN tasks t ON ws.task_id = t.id
            JOIN employees e ON ws.employee_id = e.id
            WHERE ws.end_time IS NULL
            ORDER BY ws.start_time ASC
        """;
        
        List<WorkSession> sessions = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                sessions.add(mapResultSetToWorkSession(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return sessions;
    }
    
    /**
     * Update session notes
     */
    public boolean updateSessionNotes(int sessionId, String notes) {
        String sql = "UPDATE work_sessions SET notes = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, notes);
            stmt.setInt(2, sessionId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Delete work session
     */
    public boolean deleteSession(int sessionId) {
        String sql = "DELETE FROM work_sessions WHERE id = ?";
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, sessionId);
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Check if employee has active session for task
     */
    private boolean hasActiveSession(int taskId, int employeeId) {
        String sql = """
            SELECT COUNT(*) FROM work_sessions 
            WHERE task_id = ? AND employee_id = ? AND end_time IS NULL
        """;
        
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
     * Map ResultSet to WorkSession object
     */
    private WorkSession mapResultSetToWorkSession(ResultSet rs) throws SQLException {
        WorkSession session = new WorkSession();
        session.setId(rs.getInt("id"));
        session.setTaskId(rs.getInt("task_id"));
        session.setTaskTitle(rs.getString("task_title"));
        session.setEmployeeId(rs.getInt("employee_id"));
        session.setEmployeeName(rs.getString("employee_name"));
        
        Timestamp startTime = rs.getTimestamp("start_time");
        if (startTime != null) {
            session.setStartTime(startTime);
        }
        
        Timestamp endTime = rs.getTimestamp("end_time");
        if (endTime != null) {
            session.setEndTime(endTime);
        }
        
        int durationMinutes = rs.getInt("duration_minutes");
        if (!rs.wasNull()) {
            session.setDurationMinutes(durationMinutes);
        }
        
        session.setNotes(rs.getString("notes"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            session.setCreatedAt(createdAt);
        }
        
        return session;
    }
    
    // Additional methods for servlet compatibility
    
    /**
     * Alias for getActiveSession method for servlet compatibility
     */
    public WorkSession getActiveSessionByTaskAndEmployee(int taskId, int employeeId) {
        return getActiveSession(taskId, employeeId);
    }
    
    /**
     * Create work session (alias for startSession)
     */
    public boolean createWorkSession(WorkSession session) {
        return startSession(session);
    }
    
    /**
     * Get active sessions for an employee
     */
    public List<WorkSession> getActiveSessionsByEmployee(int employeeId) {
        String sql = """
            SELECT ws.id, ws.task_id, ws.employee_id, ws.start_time, ws.end_time, 
                   ws.duration_minutes, ws.notes, ws.created_at,
                   t.title as task_title, e.name as employee_name
            FROM work_sessions ws
            JOIN tasks t ON ws.task_id = t.id
            JOIN employees e ON ws.employee_id = e.id
            WHERE ws.employee_id = ? AND ws.end_time IS NULL
            ORDER BY ws.start_time DESC
        """;
        
        List<WorkSession> sessions = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                sessions.add(mapResultSetToWorkSession(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return sessions;
    }
    
    /**
     * Get recent sessions for an employee
     */
    public List<WorkSession> getRecentSessionsByEmployee(int employeeId, int limit) {
        String sql = """
            SELECT ws.id, ws.task_id, ws.employee_id, ws.start_time, ws.end_time, 
                   ws.duration_minutes, ws.notes, ws.created_at,
                   t.title as task_title, e.name as employee_name
            FROM work_sessions ws
            JOIN tasks t ON ws.task_id = t.id
            JOIN employees e ON ws.employee_id = e.id
            WHERE ws.employee_id = ?
            ORDER BY ws.start_time DESC
            LIMIT ?
        """;
        
        List<WorkSession> sessions = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            stmt.setInt(2, limit);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                sessions.add(mapResultSetToWorkSession(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return sessions;
    }
    
    /**
     * Get sessions for employee with limit (overloaded method for JSP compatibility)
     */
    public List<WorkSession> getSessionsForEmployee(int employeeId, int limit) {
        String sql = """
            SELECT ws.id, ws.task_id, ws.employee_id, ws.start_time, ws.end_time, 
                   ws.duration_minutes, ws.notes, ws.created_at,
                   t.title as task_title, e.name as employee_name
            FROM work_sessions ws
            JOIN tasks t ON ws.task_id = t.id
            JOIN employees e ON ws.employee_id = e.id
            WHERE ws.employee_id = ?
            ORDER BY ws.start_time DESC
            LIMIT ?
        """;
        
        List<WorkSession> sessions = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            stmt.setInt(2, limit);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                sessions.add(mapResultSetToWorkSession(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return sessions;
    }
    
    /**
     * Get sessions for employee with pagination
     */
    public List<WorkSession> getSessionsByEmployee(int employeeId, int pageSize, int offset) {
        String sql = """
            SELECT ws.id, ws.task_id, ws.employee_id, ws.start_time, ws.end_time, 
                   ws.duration_minutes, ws.notes, ws.created_at,
                   t.title as task_title, e.name as employee_name
            FROM work_sessions ws
            JOIN tasks t ON ws.task_id = t.id
            JOIN employees e ON ws.employee_id = e.id
            WHERE ws.employee_id = ?
            ORDER BY ws.start_time DESC
            LIMIT ? OFFSET ?
        """;
        
        List<WorkSession> sessions = new ArrayList<>();
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            stmt.setInt(2, pageSize);
            stmt.setInt(3, offset);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                sessions.add(mapResultSetToWorkSession(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return sessions;
    }
    
    /**
     * Get total session count for employee
     */
    public int getTotalSessionCount(int employeeId) {
        String sql = "SELECT COUNT(*) FROM work_sessions WHERE employee_id = ?";
        
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
     * Get work session by ID
     */
    public WorkSession getWorkSessionById(int sessionId) {
        String sql = """
            SELECT ws.id, ws.task_id, ws.employee_id, ws.start_time, ws.end_time, 
                   ws.duration_minutes, ws.notes, ws.created_at,
                   t.title as task_title, e.name as employee_name
            FROM work_sessions ws
            JOIN tasks t ON ws.task_id = t.id
            JOIN employees e ON ws.employee_id = e.id
            WHERE ws.id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, sessionId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToWorkSession(rs);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Update work session
     */
    public boolean updateWorkSession(WorkSession session) {
        String sql = """
            UPDATE work_sessions 
            SET end_time = ?, duration_minutes = ?, notes = ?
            WHERE id = ?
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setTimestamp(1, session.getEndTime());
            stmt.setInt(2, session.getDurationMinutes());
            stmt.setString(3, session.getNotes());
            stmt.setInt(4, session.getId());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get total hours for employee
     */
    public double getTotalHoursForEmployee(int employeeId) {
        String sql = """
            SELECT COALESCE(SUM(duration_minutes), 0) / 60.0 as total_hours
            FROM work_sessions 
            WHERE employee_id = ? AND end_time IS NOT NULL
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("total_hours");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0.0;
    }
    
    /**
     * Get monthly hours for employee
     */
    public double getMonthlyHoursForEmployee(int employeeId) {
        String sql = """
            SELECT COALESCE(SUM(duration_minutes), 0) / 60.0 as monthly_hours
            FROM work_sessions 
            WHERE employee_id = ? AND end_time IS NOT NULL
            AND start_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("monthly_hours");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0.0;
    }
    
    /**
     * Get average session duration for employee
     */
    public double getAverageSessionDuration(int employeeId) {
        String sql = """
            SELECT COALESCE(AVG(duration_minutes), 0) as avg_duration
            FROM work_sessions 
            WHERE employee_id = ? AND end_time IS NOT NULL
        """;
        
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, employeeId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("avg_duration");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0.0;
    }
}