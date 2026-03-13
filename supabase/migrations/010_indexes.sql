-- 010_indexes.sql
-- Performance indexes for 8,000-employee scale (~2.9M attendance rows/year)

-- Attendance (largest table)
create index idx_attendance_employee_date on attendance(employee_id, date desc);
create index idx_attendance_date on attendance(date desc);
create index idx_attendance_status on attendance(status);
create index idx_attendance_date_status on attendance(date, status);

-- Employees
create index idx_employees_department on employees(department_id);
create index idx_employees_supervisor on employees(supervisor_id);
create index idx_employees_status on employees(employment_status);
create index idx_employees_contract_end on employees(contract_end)
  where contract_end is not null;
create index idx_employees_user_id on employees(user_id);
create index idx_employees_employment_type on employees(employment_type);

-- Leave requests
create index idx_leave_employee on leave_requests(employee_id);
create index idx_leave_status on leave_requests(status);
create index idx_leave_dates on leave_requests(start_date, end_date);
create index idx_leave_supervisor on leave_requests(supervisor_id);

-- Notifications
create index idx_notifications_user_unread on notifications(user_id, is_read)
  where is_read = false;
create index idx_notifications_user_created on notifications(user_id, created_at desc);

-- user_roles
create index idx_user_roles_user_id on user_roles(user_id);

-- Schedule details
create index idx_schedule_details_schedule on schedule_details(schedule_id);
