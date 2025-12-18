-- Sample Data for Task Management System
-- This file contains comprehensive test data demonstrating all features
-- Passwords are 'password123' - will be hashed in the application

USE task_management;

-- Insert Departments
INSERT INTO departments (name, description) VALUES
('Engineering', 'Software development and technical operations'),
('Marketing', 'Marketing and customer outreach'),
('Sales', 'Sales and business development'),
('HR', 'Human resources and administration');

-- Insert Employees (Passwords will be hashed in Java application)
-- ADMINs
INSERT INTO employees (name, email, password, role, department_id, manager_id) VALUES
('John Admin', 'admin@company.com', 'password123', 'ADMIN', 1, NULL),
('Sarah Admin', 'sarah.admin@company.com', 'password123', 'ADMIN', 2, NULL),
('Mike Admin', 'mike.admin@company.com', 'password123', 'ADMIN', 3, NULL);

-- MANAGERs
INSERT INTO employees (name, email, password, role, department_id, manager_id) VALUES
('Alice Manager', 'alice.manager@company.com', 'password123', 'MANAGER', 1, 1),
('Bob Manager', 'bob.manager@company.com', 'password123', 'MANAGER', 1, 1),
('Carol Manager', 'carol.manager@company.com', 'password123', 'MANAGER', 2, 2),
('David Manager', 'david.manager@company.com', 'password123', 'MANAGER', 3, 3),
('Eve Manager', 'eve.manager@company.com', 'password123', 'MANAGER', 4, 1);

-- EMPLOYEEs
INSERT INTO employees (name, email, password, role, department_id, manager_id) VALUES
('Tom Employee', 'tom@company.com', 'password123', 'EMPLOYEE', 1, 4),
('Lisa Employee', 'lisa@company.com', 'password123', 'EMPLOYEE', 1, 4),
('Mark Employee', 'mark@company.com', 'password123', 'EMPLOYEE', 1, 5),
('Nina Employee', 'nina@company.com', 'password123', 'EMPLOYEE', 2, 6),
('Oscar Employee', 'oscar@company.com', 'password123', 'EMPLOYEE', 2, 6),
('Paula Employee', 'paula@company.com', 'password123', 'EMPLOYEE', 3, 7),
('Quinn Employee', 'quinn@company.com', 'password123', 'EMPLOYEE', 3, 7),
('Rachel Employee', 'rachel@company.com', 'password123', 'EMPLOYEE', 4, 8),
('Steve Employee', 'steve@company.com', 'password123', 'EMPLOYEE', 4, 8),
('Tina Employee', 'tina@company.com', 'password123', 'EMPLOYEE', 1, 4);

-- Insert Tasks with various statuses demonstrating workflow
INSERT INTO tasks (title, description, priority, status, due_date, department_id, created_by) VALUES
-- Engineering Tasks
('Setup CI/CD Pipeline', 'Configure automated build and deployment pipeline for faster releases', 'HIGH', 'IN_PROGRESS', '2024-12-25', 1, 4),
('Database Optimization', 'Optimize slow queries and add proper indexes for better performance', 'MEDIUM', 'PENDING', '2024-12-30', 1, 4),
('API Documentation', 'Complete REST API documentation with examples and schemas', 'LOW', 'UNDER_REVIEW', '2024-12-28', 1, 5),
('Security Audit', 'Perform comprehensive security vulnerability assessment', 'HIGH', 'PENDING', '2024-12-22', 1, 4),
('Mobile App Bug Fix', 'Fix critical bugs reported in mobile application', 'HIGH', 'IN_PROGRESS', '2024-12-20', 1, 5),
('Code Review Process', 'Implement standardized code review process', 'MEDIUM', 'COMPLETED', '2024-12-15', 1, 4),
('Unit Test Coverage', 'Increase unit test coverage to 80%', 'MEDIUM', 'REJECTED', '2024-12-27', 1, 5),

-- Marketing Tasks
('Campaign Launch', 'Launch Q1 marketing campaign across all channels', 'HIGH', 'IN_PROGRESS', '2024-12-31', 2, 6),
('Social Media Content', 'Create engaging social media content for December', 'MEDIUM', 'COMPLETED', '2024-12-18', 2, 6),
('Market Research', 'Conduct comprehensive competitor analysis', 'MEDIUM', 'UNDER_REVIEW', '2024-12-27', 2, 6),
('Email Newsletter', 'Design and send monthly newsletter to subscribers', 'LOW', 'PENDING', '2024-12-25', 2, 6),
('Brand Guidelines', 'Update brand guidelines and style guide', 'LOW', 'CANCELLED', '2024-12-29', 2, 6),

-- Sales Tasks
('Client Presentation', 'Prepare comprehensive presentation for major client', 'HIGH', 'IN_PROGRESS', '2024-12-21', 3, 7),
('Lead Generation', 'Generate qualified leads for Q1 sales pipeline', 'MEDIUM', 'PENDING', '2024-12-29', 3, 7),
('Contract Review', 'Review and update standard service contracts', 'LOW', 'REJECTED', '2024-12-26', 3, 7),
('Sales Training', 'Conduct comprehensive sales training for new hires', 'MEDIUM', 'COMPLETED', '2024-12-19', 3, 7),
('CRM Migration', 'Migrate customer data to new CRM system', 'HIGH', 'UNDER_REVIEW', '2024-12-24', 3, 7),

-- HR Tasks
('Employee Onboarding', 'Streamline onboarding process for January new hires', 'HIGH', 'IN_PROGRESS', '2024-12-30', 4, 8),
('Performance Reviews', 'Complete Q4 performance reviews for all employees', 'HIGH', 'UNDER_REVIEW', '2024-12-23', 4, 8),
('Policy Update', 'Update employee handbook with new policies', 'MEDIUM', 'PENDING', '2024-12-28', 4, 8),
('Benefits Enrollment', 'Process benefits enrollment for 2025', 'HIGH', 'COMPLETED', '2024-12-17', 4, 8),
('Training Program', 'Develop leadership training program', 'MEDIUM', 'PENDING', '2024-12-31', 4, 8);

-- Insert Task Assignments demonstrating primary/secondary roles
INSERT INTO task_assignments (task_id, employee_id, assignment_type, assigned_by) VALUES
-- Engineering assignments
(1, 9, 'PRIMARY', 4), (1, 10, 'SECONDARY', 4),
(2, 11, 'PRIMARY', 4),
(3, 18, 'PRIMARY', 5),
(4, 9, 'PRIMARY', 4), (4, 10, 'SECONDARY', 4),
(5, 11, 'PRIMARY', 5),
(6, 9, 'PRIMARY', 4),
(7, 18, 'PRIMARY', 5),

-- Marketing assignments
(8, 12, 'PRIMARY', 6), (8, 13, 'SECONDARY', 6),
(9, 12, 'PRIMARY', 6),
(10, 13, 'PRIMARY', 6),
(11, 12, 'PRIMARY', 6),
(12, 13, 'PRIMARY', 6),

-- Sales assignments
(13, 14, 'PRIMARY', 7), (13, 15, 'SECONDARY', 7),
(14, 14, 'PRIMARY', 7),
(15, 15, 'PRIMARY', 7),
(16, 14, 'PRIMARY', 7),
(17, 15, 'PRIMARY', 7),

-- HR assignments
(18, 16, 'PRIMARY', 8), (18, 17, 'SECONDARY', 8),
(19, 16, 'PRIMARY', 8),
(20, 17, 'PRIMARY', 8),
(21, 16, 'PRIMARY', 8),
(22, 17, 'PRIMARY', 8);

-- Insert Task Dependencies demonstrating complex dependency chains
INSERT INTO task_dependencies (task_id, depends_on_task_id, created_by) VALUES
(2, 1, 4), -- Database optimization depends on CI/CD setup
(3, 2, 5), -- API docs depend on database optimization
(5, 4, 5), -- Bug fix depends on security audit
(7, 6, 5), -- Unit tests depend on code review process
(10, 9, 6), -- Market research depends on social media content
(14, 13, 7), -- Lead generation depends on client presentation
(17, 16, 7), -- CRM migration depends on sales training
(20, 19, 8), -- Policy update depends on performance reviews
(22, 21, 8); -- Training program depends on benefits enrollment

-- Insert Work Sessions for productivity tracking
INSERT INTO work_sessions (task_id, employee_id, start_time, end_time, notes) VALUES
(1, 9, '2024-12-16 09:00:00', '2024-12-16 12:30:00', 'Initial CI/CD setup and Docker configuration'),
(1, 9, '2024-12-16 13:30:00', '2024-12-16 17:00:00', 'Jenkins pipeline configuration and testing'),
(2, 11, '2024-12-15 10:00:00', '2024-12-15 15:00:00', 'Database query analysis and index optimization'),
(8, 12, '2024-12-14 08:00:00', '2024-12-14 11:00:00', 'Q1 campaign planning and strategy development'),
(13, 14, '2024-12-13 14:00:00', '2024-12-13 18:00:00', 'Client presentation preparation and research'),
(18, 16, '2024-12-12 09:00:00', '2024-12-12 12:00:00', 'Onboarding process documentation'),
(5, 11, '2024-12-11 10:30:00', '2024-12-11 16:00:00', 'Mobile app debugging and testing'),
(19, 16, '2024-12-10 14:00:00', '2024-12-10 17:30:00', 'Performance review template updates'),
-- Active sessions (no end_time)
(1, 10, '2024-12-16 14:00:00', NULL, 'Currently working on deployment automation scripts'),
(8, 13, '2024-12-16 10:00:00', NULL, 'Working on campaign asset creation');

-- Insert Comments for collaboration demonstration
INSERT INTO comments (task_id, employee_id, comment_text) VALUES
(1, 9, 'Started working on the CI/CD pipeline. Docker configuration is complete and tested.'),
(1, 4, 'Great progress! Make sure to include automated testing stages in the pipeline.'),
(1, 10, 'Added Jenkins configuration with automated deployment. Ready for review.'),
(2, 11, 'Found several slow queries in the user management module. Working on optimization strategies.'),
(2, 4, 'Please prioritize the login query optimization as it affects user experience.'),
(8, 12, 'Campaign assets are ready and approved by design team. Waiting for final budget approval.'),
(8, 6, 'Budget approved! Please proceed with the campaign launch as planned.'),
(13, 14, 'Presentation slides are 80% complete. Adding financial projections and ROI analysis.'),
(13, 7, 'Make sure to include competitive analysis in the presentation.'),
(19, 16, 'Performance review templates have been updated according to new HR guidelines.'),
(5, 11, 'Fixed the critical login bug. Running comprehensive tests before deployment.'),
(18, 17, 'Onboarding checklist has been streamlined. New process reduces time by 40%.'),
(3, 18, 'API documentation is complete. Added interactive examples using Swagger.'),
(10, 13, 'Market research shows strong demand for our new product features.');

-- Insert Activity Log entries for audit trail
INSERT INTO task_activity_log (task_id, employee_id, action, field_name, old_value, new_value, description) VALUES
(1, 4, 'CREATED', NULL, NULL, NULL, 'Task created: Setup CI/CD Pipeline'),
(1, 4, 'ASSIGNED', NULL, NULL, 'Tom Employee (PRIMARY)', 'Assigned Tom Employee as primary assignee'),
(1, 4, 'ASSIGNED', NULL, NULL, 'Lisa Employee (SECONDARY)', 'Assigned Lisa Employee as secondary assignee'),
(1, 9, 'STATUS_CHANGED', 'status', 'PENDING', 'IN_PROGRESS', 'Started working on CI/CD pipeline setup'),
(2, 4, 'CREATED', NULL, NULL, NULL, 'Task created: Database Optimization'),
(3, 18, 'STATUS_CHANGED', 'status', 'IN_PROGRESS', 'UNDER_REVIEW', 'Submitted API documentation for review'),
(6, 9, 'STATUS_CHANGED', 'status', 'IN_PROGRESS', 'COMPLETED', 'Code review process implementation completed'),
(7, 5, 'STATUS_CHANGED', 'status', 'UNDER_REVIEW', 'REJECTED', 'Unit test coverage needs more comprehensive approach'),
(8, 12, 'STATUS_CHANGED', 'status', 'PENDING', 'IN_PROGRESS', 'Started Q1 campaign development'),
(9, 12, 'STATUS_CHANGED', 'status', 'IN_PROGRESS', 'COMPLETED', 'Social media content creation completed'),
(15, 15, 'STATUS_CHANGED', 'status', 'UNDER_REVIEW', 'REJECTED', 'Contract terms need legal review and revision'),
(16, 14, 'STATUS_CHANGED', 'status', 'IN_PROGRESS', 'COMPLETED', 'Sales training session completed successfully'),
(21, 16, 'STATUS_CHANGED', 'status', 'IN_PROGRESS', 'COMPLETED', 'Benefits enrollment process completed for 2025'),
(4, 4, 'PRIORITY_CHANGED', 'priority', 'MEDIUM', 'HIGH', 'Escalated priority due to security concerns'),
(18, 8, 'ASSIGNED', NULL, NULL, 'Rachel Employee (PRIMARY)', 'Assigned Rachel Employee to onboarding task');

-- Insert Notifications for user engagement
INSERT INTO notifications (recipient_id, task_id, notification_type, message, is_read) VALUES
(9, 1, 'TASK_ASSIGNED', 'You have been assigned as PRIMARY to task: Setup CI/CD Pipeline', TRUE),
(10, 1, 'TASK_ASSIGNED', 'You have been assigned as SECONDARY to task: Setup CI/CD Pipeline', FALSE),
(11, 2, 'TASK_ASSIGNED', 'You have been assigned to task: Database Optimization', FALSE),
(4, 3, 'STATUS_CHANGED', 'Task "API Documentation" is now under review and needs your approval', FALSE),
(12, 8, 'TASK_ASSIGNED', 'You have been assigned as PRIMARY to task: Campaign Launch', TRUE),
(14, 13, 'TASK_ASSIGNED', 'You have been assigned to task: Client Presentation', TRUE),
(7, 15, 'STATUS_CHANGED', 'Task "Contract Review" has been rejected and needs revision', FALSE),
(16, 18, 'TASK_ASSIGNED', 'You have been assigned to task: Employee Onboarding', TRUE),
(8, 19, 'STATUS_CHANGED', 'Task "Performance Reviews" is now under review', FALSE),
(9, 4, 'PRIORITY_ESCALATED', 'Task "Security Audit" has been escalated to HIGH priority', FALSE),
(11, 5, 'TASK_OVERDUE', 'Task "Mobile App Bug Fix" is approaching deadline', FALSE),
(12, 8, 'APPROVAL_NEEDED', 'Campaign Launch task requires manager approval to proceed', TRUE),
(15, 17, 'DEPENDENCY_RESOLVED', 'Task "CRM Migration" dependencies have been completed', FALSE),
(17, 22, 'TASK_ASSIGNED', 'You have been assigned to task: Training Program', FALSE);

-- Insert sample attachments metadata (bonus feature)
INSERT INTO task_attachments (task_id, filename, file_path, file_size, mime_type, uploaded_by) VALUES
(1, 'ci-cd-architecture.pdf', '/uploads/tasks/1/ci-cd-architecture.pdf', 2048576, 'application/pdf', 9),
(1, 'jenkins-config.xml', '/uploads/tasks/1/jenkins-config.xml', 8192, 'application/xml', 10),
(8, 'campaign-assets.zip', '/uploads/tasks/8/campaign-assets.zip', 15728640, 'application/zip', 12),
(13, 'client-presentation.pptx', '/uploads/tasks/13/client-presentation.pptx', 5242880, 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 14),
(19, 'performance-review-template.docx', '/uploads/tasks/19/performance-review-template.docx', 1048576, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 16),
(3, 'api-specification.json', '/uploads/tasks/3/api-specification.json', 32768, 'application/json', 18),
(2, 'database-schema.sql', '/uploads/tasks/2/database-schema.sql', 16384, 'application/sql', 11);