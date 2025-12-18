-- Enterprise Task Management System Database Schema
-- This script creates the complete database structure for the task management system
-- Author: Sateesh Velaga
-- Date: December 2024

DROP DATABASE IF EXISTS task_management;
CREATE DATABASE task_management;
USE task_management;

-- 1. Departments Table
-- Stores organizational departments
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Employees Table (Users)
-- Central user management with role-based access control
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Will store hashed passwords
    role ENUM('EMPLOYEE', 'MANAGER', 'ADMIN') NOT NULL DEFAULT 'EMPLOYEE',
    department_id INT,
    manager_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (manager_id) REFERENCES employees(id),
    INDEX idx_employee_email (email),
    INDEX idx_employee_role (role),
    INDEX idx_employee_department (department_id)
);

-- 3. Tasks Table
-- Core task management with status workflow and optimistic locking
CREATE TABLE tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    priority ENUM('LOW', 'MEDIUM', 'HIGH') NOT NULL DEFAULT 'MEDIUM',
    status ENUM('PENDING', 'IN_PROGRESS', 'UNDER_REVIEW', 'COMPLETED', 'CANCELLED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    due_date DATE NOT NULL,
    department_id INT NOT NULL,
    created_by INT NOT NULL,
    version INT DEFAULT 1, -- For optimistic locking to handle concurrent updates
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (created_by) REFERENCES employees(id),
    INDEX idx_task_status (status),
    INDEX idx_task_priority (priority),
    INDEX idx_task_due_date (due_date),
    INDEX idx_task_department (department_id),
    INDEX idx_task_creator (created_by)
);

-- 4. Task Assignments Table (Many-to-Many)
-- Manages task assignments with primary/secondary roles
CREATE TABLE task_assignments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT NOT NULL,
    employee_id INT NOT NULL,
    assignment_type ENUM('PRIMARY', 'SECONDARY') NOT NULL DEFAULT 'PRIMARY',
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INT NOT NULL,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (assigned_by) REFERENCES employees(id),
    UNIQUE KEY unique_task_employee (task_id, employee_id),
    INDEX idx_assignment_task (task_id),
    INDEX idx_assignment_employee (employee_id)
);

-- 5. Task Dependencies Table
-- Manages task dependencies with circular dependency prevention
CREATE TABLE task_dependencies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT NOT NULL, -- The task that depends on another
    depends_on_task_id INT NOT NULL, -- The task it depends on
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (depends_on_task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES employees(id),
    UNIQUE KEY unique_dependency (task_id, depends_on_task_id),
    INDEX idx_dependency_task (task_id),
    INDEX idx_dependency_depends_on (depends_on_task_id),
    -- Prevent self-dependency
    CONSTRAINT chk_no_self_dependency CHECK (task_id != depends_on_task_id)
);

-- 6. Task Activity Log (Audit Trail)
-- Complete audit trail for all task changes
CREATE TABLE task_activity_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT NOT NULL,
    employee_id INT NOT NULL,
    action VARCHAR(50) NOT NULL, -- 'CREATED', 'STATUS_CHANGED', 'ASSIGNED', 'UPDATED', etc.
    field_name VARCHAR(50), -- Which field was changed
    old_value TEXT, -- Previous value
    new_value TEXT, -- New value
    description TEXT, -- Human readable description
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    INDEX idx_activity_task (task_id),
    INDEX idx_activity_employee (employee_id),
    INDEX idx_activity_action (action),
    INDEX idx_activity_date (created_at)
);

-- 7. Work Sessions Table (Time Tracking)
-- Time tracking for productivity analysis
CREATE TABLE work_sessions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT NOT NULL,
    employee_id INT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NULL,
    duration_minutes INT GENERATED ALWAYS AS (
        CASE 
            WHEN end_time IS NOT NULL THEN TIMESTAMPDIFF(MINUTE, start_time, end_time)
            ELSE NULL 
        END
    ) STORED,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    INDEX idx_session_task (task_id),
    INDEX idx_session_employee (employee_id),
    INDEX idx_session_start (start_time),
    -- Constraint: end_time must be after start_time
    CONSTRAINT chk_session_time CHECK (end_time IS NULL OR end_time > start_time)
);

-- 8. Comments Table
-- Task comments for collaboration
CREATE TABLE comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT NOT NULL,
    employee_id INT NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    INDEX idx_comment_task (task_id),
    INDEX idx_comment_employee (employee_id),
    INDEX idx_comment_date (created_at)
);

-- 9. Notifications Table
-- System notifications for users
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    recipient_id INT NOT NULL,
    task_id INT,
    notification_type VARCHAR(50) NOT NULL, -- 'TASK_ASSIGNED', 'STATUS_CHANGED', 'OVERDUE', etc.
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    FOREIGN KEY (recipient_id) REFERENCES employees(id),
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    INDEX idx_notification_recipient (recipient_id),
    INDEX idx_notification_task (task_id),
    INDEX idx_notification_type (notification_type),
    INDEX idx_notification_read (is_read),
    INDEX idx_notification_date (created_at)
);

-- 10. Task Attachments Table (Bonus Feature)
-- File attachment metadata
CREATE TABLE task_attachments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100),
    uploaded_by INT NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES employees(id),
    INDEX idx_attachment_task (task_id),
    INDEX idx_attachment_uploader (uploaded_by)
);

-- Performance Indexes for Complex Queries
CREATE INDEX idx_tasks_composite ON tasks(status, priority, due_date);
CREATE INDEX idx_assignments_composite ON task_assignments(employee_id, assignment_type);
CREATE INDEX idx_activity_composite ON task_activity_log(task_id, created_at);
CREATE INDEX idx_sessions_composite ON work_sessions(employee_id, start_time);

-- Views for Common Queries
-- View: Active tasks with assignee info
CREATE VIEW active_tasks_view AS
SELECT 
    t.id,
    t.title,
    t.description,
    t.priority,
    t.status,
    t.due_date,
    d.name as department_name,
    creator.name as created_by_name,
    GROUP_CONCAT(CONCAT(e.name, ' (', ta.assignment_type, ')') SEPARATOR ', ') as assigned_to
FROM tasks t
JOIN departments d ON t.department_id = d.id
JOIN employees creator ON t.created_by = creator.id
LEFT JOIN task_assignments ta ON t.id = ta.task_id
LEFT JOIN employees e ON ta.employee_id = e.id
WHERE t.status NOT IN ('COMPLETED', 'CANCELLED')
GROUP BY t.id, t.title, t.description, t.priority, t.status, t.due_date, d.name, creator.name;

-- View: Employee workload for workload management
CREATE VIEW employee_workload_view AS
SELECT 
    e.id,
    e.name,
    e.email,
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
GROUP BY e.id, e.name, e.email, d.name;