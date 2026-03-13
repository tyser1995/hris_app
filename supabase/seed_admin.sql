-- seed_admin.sql
-- Run this AFTER combined_migration.sql
-- Sets up the admin account for devresty2024@gmail.com

-- Step 1: Assign admin role to the user
-- (replace the email lookup with your actual user UUID if needed)
insert into user_roles (user_id, role)
select id, 'admin'
from auth.users
where email = 'devresty2024@gmail.com'
on conflict (user_id, role) do nothing;

-- Step 2: Create a department and position for the admin
insert into departments (name) values ('Administration')
on conflict do nothing;

insert into positions (title, department_id)
select 'System Administrator', id
from departments
where name = 'Administration'
on conflict do nothing;

-- Step 3: Create the employee record linked to the admin user
insert into employees (
  user_id,
  employee_code,
  first_name,
  last_name,
  email,
  employment_type,
  hire_date,
  department_id,
  position_id
)
select
  u.id,
  'EMP-001',
  'Admin',
  'User',
  u.email,
  'regular',
  current_date,
  d.id,
  p.id
from auth.users u
cross join departments d
cross join positions p
where u.email = 'devresty2024@gmail.com'
  and d.name = 'Administration'
  and p.title = 'System Administrator'
on conflict (email) do nothing;

-- Verify setup
select
  u.email,
  ur.role,
  e.employee_code,
  e.first_name || ' ' || e.last_name as full_name,
  d.name as department,
  p.title as position
from auth.users u
left join user_roles ur on ur.user_id = u.id
left join employees e on e.user_id = u.id
left join departments d on d.id = e.department_id
left join positions p on p.id = e.position_id
where u.email = 'devresty2024@gmail.com';
