-- ============================================================
-- RESET AND SEED
-- Drops everything and rebuilds from scratch
-- Run in Supabase SQL Editor
-- ============================================================

-- ── DROP TABLES (order matters for FK constraints) ──────────
drop table if exists employee_documents cascade;
drop table if exists notifications cascade;
drop table if exists leave_balances cascade;
drop table if exists leave_requests cascade;
drop table if exists attendance cascade;
drop table if exists schedule_details cascade;
drop table if exists schedules cascade;
drop table if exists employees cascade;
drop table if exists positions cascade;
drop table if exists departments cascade;
drop table if exists user_roles cascade;
drop table if exists roles cascade;

-- ── DROP TYPES ───────────────────────────────────────────────
drop type if exists user_role cascade;
drop type if exists employment_type cascade;
drop type if exists employment_status cascade;
drop type if exists civil_status cascade;
drop type if exists schedule_type cascade;
drop type if exists attendance_status cascade;
drop type if exists checkin_source cascade;
drop type if exists leave_type cascade;
drop type if exists leave_status cascade;
drop type if exists notification_type cascade;
drop type if exists document_type cascade;

-- ── DROP FUNCTIONS ───────────────────────────────────────────
drop function if exists get_my_role() cascade;
drop function if exists get_my_employee_id() cascade;
drop function if exists update_updated_at_column() cascade;
drop function if exists increment_leave_used(uuid, int, leave_type, numeric) cascade;

-- ============================================================
-- 001 ROLES
-- ============================================================
create type user_role as enum ('admin', 'hr_staff', 'department_head', 'supervisor', 'employee');

create table roles (
  id uuid primary key default gen_random_uuid(),
  name user_role unique not null,
  created_at timestamptz default now()
);

insert into roles (name) values
  ('admin'), ('hr_staff'), ('department_head'), ('supervisor'), ('employee');

create table user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  role user_role not null default 'employee',
  created_at timestamptz default now(),
  unique(user_id, role)
);

-- ============================================================
-- 002 DEPARTMENTS & POSITIONS
-- ============================================================
create table departments (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  head_id uuid,
  created_at timestamptz default now()
);

create table positions (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  department_id uuid references departments(id) on delete set null,
  created_at timestamptz default now()
);

-- ============================================================
-- 003 EMPLOYEES
-- ============================================================
create type employment_type as enum (
  'regular', 'job_order', 'contractual', 'faculty', 'janitorial'
);
create type employment_status as enum ('active', 'inactive', 'terminated', 'on_leave');
create type civil_status as enum ('single', 'married', 'widowed', 'separated');

create table employees (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  employee_code text unique not null,
  first_name text not null,
  last_name text not null,
  middle_name text,
  employment_type employment_type not null default 'regular',
  department_id uuid references departments(id) on delete set null,
  position_id uuid references positions(id) on delete set null,
  supervisor_id uuid references employees(id) on delete set null,
  schedule_id uuid,
  hire_date date not null,
  employment_status employment_status not null default 'active',
  contract_start date,
  contract_end date,
  address text,
  phone text,
  email text unique not null,
  birthdate date,
  civil_status civil_status,
  avatar_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table departments
  add constraint fk_dept_head
  foreign key (head_id) references employees(id) on delete set null;

create or replace function update_updated_at_column()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger employees_updated_at
  before update on employees
  for each row execute function update_updated_at_column();

-- ============================================================
-- 004 SCHEDULES
-- ============================================================
create type schedule_type as enum ('regular', 'broken', 'flexible');

create table schedules (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type schedule_type not null default 'regular',
  created_at timestamptz default now()
);

create table schedule_details (
  id uuid primary key default gen_random_uuid(),
  schedule_id uuid references schedules(id) on delete cascade not null,
  day_of_week int check (day_of_week between 0 and 6),
  start_time time not null,
  end_time time not null,
  period_label text
);

alter table employees
  add constraint fk_employee_schedule
  foreign key (schedule_id) references schedules(id) on delete set null;

-- ============================================================
-- 005 ATTENDANCE
-- ============================================================
create type attendance_status as enum ('present', 'late', 'absent', 'half_day', 'overtime');
create type checkin_source as enum ('biometric', 'rfid', 'mobile', 'web', 'manual');

create table attendance (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references employees(id) on delete cascade not null,
  date date not null,
  time_in timestamptz,
  time_out timestamptz,
  schedule_id uuid references schedules(id) on delete set null,
  late_minutes int not null default 0,
  undertime_minutes int not null default 0,
  overtime_minutes int not null default 0,
  status attendance_status not null default 'absent',
  source checkin_source default 'web',
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(employee_id, date)
);

create trigger attendance_updated_at
  before update on attendance
  for each row execute function update_updated_at_column();

-- ============================================================
-- 006 LEAVE
-- ============================================================
create type leave_type as enum (
  'vacation', 'sick', 'emergency', 'maternity', 'paternity', 'without_pay'
);
create type leave_status as enum (
  'pending_supervisor', 'pending_hr', 'approved', 'rejected', 'cancelled'
);

create table leave_requests (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references employees(id) on delete cascade not null,
  leave_type leave_type not null,
  start_date date not null,
  end_date date not null,
  days_requested numeric(4,1) not null,
  reason text,
  status leave_status not null default 'pending_supervisor',
  supervisor_id uuid references employees(id),
  supervisor_action_at timestamptz,
  supervisor_remarks text,
  hr_approver_id uuid references employees(id),
  hr_action_at timestamptz,
  hr_remarks text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table leave_balances (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references employees(id) on delete cascade not null,
  year int not null,
  leave_type leave_type not null,
  total_days numeric(4,1) not null default 0,
  used_days numeric(4,1) not null default 0,
  unique(employee_id, year, leave_type)
);

create trigger leave_requests_updated_at
  before update on leave_requests
  for each row execute function update_updated_at_column();

-- ============================================================
-- 007 NOTIFICATIONS
-- ============================================================
create type notification_type as enum (
  'leave_approved', 'leave_rejected', 'shift_reminder',
  'late_alert', 'contract_expiring', 'general'
);

create table notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  type notification_type not null,
  title text not null,
  body text not null,
  is_read boolean not null default false,
  metadata jsonb not null default '{}',
  created_at timestamptz default now()
);

-- ============================================================
-- 008 DOCUMENTS
-- ============================================================
create type document_type as enum ('contract', 'id', 'certificate', 'other');

create table employee_documents (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references employees(id) on delete cascade not null,
  document_type document_type not null,
  file_name text not null,
  file_path text not null,
  uploaded_by uuid references auth.users(id),
  created_at timestamptz default now()
);

-- ============================================================
-- 009 RLS POLICIES
-- ============================================================
alter table employees enable row level security;
alter table attendance enable row level security;
alter table leave_requests enable row level security;
alter table leave_balances enable row level security;
alter table notifications enable row level security;
alter table departments enable row level security;
alter table positions enable row level security;
alter table schedules enable row level security;
alter table schedule_details enable row level security;
alter table employee_documents enable row level security;
alter table user_roles enable row level security;

create or replace function get_my_role()
returns user_role language sql security definer stable as $$
  select role from user_roles where user_id = (select auth.uid()) limit 1;
$$;

create or replace function get_my_employee_id()
returns uuid language sql security definer stable as $$
  select id from employees where user_id = (select auth.uid()) limit 1;
$$;

-- user_roles
create policy "user_roles_select_own" on user_roles for select
  to authenticated using (user_id = (select auth.uid()));

-- departments
create policy "departments_select_all" on departments for select
  to authenticated using (true);
create policy "departments_write_admin_hr" on departments for all
  to authenticated using (get_my_role() in ('admin', 'hr_staff'));

-- positions
create policy "positions_select_all" on positions for select
  to authenticated using (true);
create policy "positions_write_admin_hr" on positions for all
  to authenticated using (get_my_role() in ('admin', 'hr_staff'));

-- schedules
create policy "schedules_select_all" on schedules for select
  to authenticated using (true);
create policy "schedules_write_admin_hr" on schedules for all
  to authenticated using (get_my_role() in ('admin', 'hr_staff'));

-- schedule_details
create policy "schedule_details_select_all" on schedule_details for select
  to authenticated using (true);
create policy "schedule_details_write_admin_hr" on schedule_details for all
  to authenticated using (get_my_role() in ('admin', 'hr_staff'));

-- employees
create policy "employees_select" on employees for select
  to authenticated
  using (
    get_my_role() in ('admin', 'hr_staff', 'department_head')
    or id = get_my_employee_id()
    or supervisor_id = get_my_employee_id()
  );
create policy "employees_insert_admin_hr" on employees for insert
  to authenticated
  with check (get_my_role() in ('admin', 'hr_staff'));
create policy "employees_update_admin_hr" on employees for update
  to authenticated
  using (get_my_role() in ('admin', 'hr_staff'))
  with check (get_my_role() in ('admin', 'hr_staff'));
create policy "employees_delete_admin" on employees for delete
  to authenticated
  using (get_my_role() = 'admin');

-- attendance
create policy "attendance_select" on attendance for select
  to authenticated
  using (
    get_my_role() in ('admin', 'hr_staff', 'department_head')
    or employee_id = get_my_employee_id()
    or employee_id in (
      select id from employees where supervisor_id = get_my_employee_id()
    )
  );
create policy "attendance_insert" on attendance for insert
  to authenticated
  with check (
    get_my_role() in ('admin', 'hr_staff')
    or employee_id = get_my_employee_id()
  );
create policy "attendance_update_admin_hr" on attendance for update
  to authenticated
  using (get_my_role() in ('admin', 'hr_staff'));

-- leave_requests
create policy "leave_select" on leave_requests for select
  to authenticated
  using (
    get_my_role() in ('admin', 'hr_staff')
    or employee_id = get_my_employee_id()
    or supervisor_id = get_my_employee_id()
  );
create policy "leave_insert_own" on leave_requests for insert
  to authenticated
  with check (employee_id = get_my_employee_id());
create policy "leave_update_approvers" on leave_requests for update
  to authenticated
  using (
    get_my_role() in ('admin', 'hr_staff')
    or supervisor_id = get_my_employee_id()
  );

-- leave_balances
create policy "leave_balances_select" on leave_balances for select
  to authenticated
  using (
    get_my_role() in ('admin', 'hr_staff')
    or employee_id = get_my_employee_id()
  );

-- notifications
create policy "notifications_own" on notifications for select
  to authenticated
  using (user_id = (select auth.uid()));
create policy "notifications_mark_read" on notifications for update
  to authenticated
  using (user_id = (select auth.uid()));

-- employee_documents
create policy "documents_select" on employee_documents for select
  to authenticated
  using (
    get_my_role() in ('admin', 'hr_staff')
    or employee_id = get_my_employee_id()
  );
create policy "documents_insert_admin_hr" on employee_documents for insert
  to authenticated
  with check (get_my_role() in ('admin', 'hr_staff'));

-- ============================================================
-- 010 INDEXES
-- ============================================================
create index idx_attendance_employee_date on attendance(employee_id, date desc);
create index idx_attendance_date on attendance(date desc);
create index idx_attendance_status on attendance(status);
create index idx_attendance_date_status on attendance(date, status);
create index idx_employees_department on employees(department_id);
create index idx_employees_supervisor on employees(supervisor_id);
create index idx_employees_status on employees(employment_status);
create index idx_employees_contract_end on employees(contract_end) where contract_end is not null;
create index idx_employees_user_id on employees(user_id);
create index idx_employees_employment_type on employees(employment_type);
create index idx_leave_employee on leave_requests(employee_id);
create index idx_leave_status on leave_requests(status);
create index idx_leave_dates on leave_requests(start_date, end_date);
create index idx_leave_supervisor on leave_requests(supervisor_id);
create index idx_notifications_user_unread on notifications(user_id, is_read) where is_read = false;
create index idx_notifications_user_created on notifications(user_id, created_at desc);
create index idx_user_roles_user_id on user_roles(user_id);
create index idx_schedule_details_schedule on schedule_details(schedule_id);

-- ============================================================
-- SEED — Default Schedules
-- ============================================================
insert into schedules (name, type) values
  ('Regular 8-5', 'regular'),
  ('Janitor Split', 'broken'),
  ('Faculty Flexible', 'flexible');

insert into schedule_details (schedule_id, start_time, end_time, period_label)
select id, '08:00', '17:00', 'Full Day' from schedules where name = 'Regular 8-5';

insert into schedule_details (schedule_id, start_time, end_time, period_label)
select id, '04:00', '08:00', 'Morning' from schedules where name = 'Janitor Split';

insert into schedule_details (schedule_id, start_time, end_time, period_label)
select id, '17:00', '21:00', 'Evening' from schedules where name = 'Janitor Split';

-- ============================================================
-- SEED — Sample Departments & Positions
-- ============================================================
insert into departments (name) values
  ('Administration'),
  ('Human Resources'),
  ('Finance'),
  ('Operations'),
  ('Information Technology'),
  ('Facilities');

insert into positions (title, department_id)
select 'System Administrator', id from departments where name = 'Administration';
insert into positions (title, department_id)
select 'HR Manager', id from departments where name = 'Human Resources';
insert into positions (title, department_id)
select 'HR Staff', id from departments where name = 'Human Resources';
insert into positions (title, department_id)
select 'Finance Officer', id from departments where name = 'Finance';
insert into positions (title, department_id)
select 'Operations Manager', id from departments where name = 'Operations';
insert into positions (title, department_id)
select 'IT Specialist', id from departments where name = 'Information Technology';
insert into positions (title, department_id)
select 'Janitorial Staff', id from departments where name = 'Facilities';

-- ============================================================
-- SEED — Admin User Account (devresty2024@gmail.com)
-- ============================================================

-- Assign admin role
insert into user_roles (user_id, role)
select id, 'admin'
from auth.users
where email = 'devresty2024@gmail.com'
on conflict (user_id, role) do nothing;

-- Create employee record for admin
insert into employees (
  user_id, employee_code, first_name, last_name, email,
  employment_type, hire_date, department_id, position_id,
  schedule_id
)
select
  u.id,
  'EMP-0001',
  'Admin',
  'User',
  u.email,
  'regular',
  current_date,
  d.id,
  p.id,
  s.id
from auth.users u
cross join departments d
cross join positions p
cross join schedules s
where u.email   = 'devresty2024@gmail.com'
  and d.name    = 'Administration'
  and p.title   = 'System Administrator'
  and s.name    = 'Regular 8-5'
on conflict (email) do nothing;

-- ============================================================
-- SEED — Sample Employees (for testing)
-- ============================================================
do $$
declare
  dept_hr       uuid;
  dept_finance  uuid;
  dept_ops      uuid;
  dept_it       uuid;
  dept_fac      uuid;
  pos_hr_mgr    uuid;
  pos_hr_staff  uuid;
  pos_finance   uuid;
  pos_ops       uuid;
  pos_it        uuid;
  pos_jan       uuid;
  sched_reg     uuid;
  sched_split   uuid;
  sched_flex    uuid;
  admin_id      uuid;
begin
  select id into dept_hr      from departments where name = 'Human Resources';
  select id into dept_finance from departments where name = 'Finance';
  select id into dept_ops     from departments where name = 'Operations';
  select id into dept_it      from departments where name = 'Information Technology';
  select id into dept_fac     from departments where name = 'Facilities';

  select id into pos_hr_mgr   from positions where title = 'HR Manager';
  select id into pos_hr_staff from positions where title = 'HR Staff';
  select id into pos_finance  from positions where title = 'Finance Officer';
  select id into pos_ops      from positions where title = 'Operations Manager';
  select id into pos_it       from positions where title = 'IT Specialist';
  select id into pos_jan      from positions where title = 'Janitorial Staff';

  select id into sched_reg    from schedules where name = 'Regular 8-5';
  select id into sched_split  from schedules where name = 'Janitor Split';
  select id into sched_flex   from schedules where name = 'Faculty Flexible';

  select id into admin_id     from employees where employee_code = 'EMP-0001';

  insert into employees (employee_code, first_name, last_name, email, employment_type, hire_date, department_id, position_id, schedule_id, supervisor_id) values
    ('EMP-0002', 'Maria',    'Santos',   'maria.santos@hris.local',   'regular',     '2021-03-15', dept_hr,      pos_hr_mgr,   sched_reg,   admin_id),
    ('EMP-0003', 'Jose',     'Reyes',    'jose.reyes@hris.local',     'regular',     '2020-07-01', dept_finance, pos_finance,  sched_reg,   admin_id),
    ('EMP-0004', 'Ana',      'Cruz',     'ana.cruz@hris.local',       'regular',     '2022-01-10', dept_it,      pos_it,       sched_reg,   admin_id),
    ('EMP-0005', 'Carlos',   'Ramos',    'carlos.ramos@hris.local',   'regular',     '2019-05-20', dept_ops,     pos_ops,      sched_reg,   admin_id),
    ('EMP-0006', 'Liza',     'Mendoza',  'liza.mendoza@hris.local',   'regular',     '2023-02-01', dept_hr,      pos_hr_staff, sched_reg,   admin_id),
    ('EMP-0007', 'Ramon',    'Garcia',   'ramon.garcia@hris.local',   'contractual', '2024-01-01', dept_it,      pos_it,       sched_reg,   admin_id),
    ('EMP-0008', 'Elena',    'Torres',   'elena.torres@hris.local',   'job_order',   '2024-06-01', dept_ops,     pos_ops,      sched_reg,   admin_id),
    ('EMP-0009', 'Pedro',    'Villanueva','pedro.v@hris.local',       'janitorial',  '2020-11-15', dept_fac,     pos_jan,      sched_split, admin_id),
    ('EMP-0010', 'Rosa',     'Aquino',   'rosa.aquino@hris.local',    'janitorial',  '2021-08-01', dept_fac,     pos_jan,      sched_split, admin_id),
    ('EMP-0011', 'Miguel',   'Dela Cruz','miguel.dc@hris.local',      'faculty',     '2018-06-01', dept_ops,     pos_ops,      sched_flex,  admin_id),
    ('EMP-0012', 'Gloria',   'Navarro',  'gloria.n@hris.local',       'regular',     '2022-09-05', dept_finance, pos_finance,  sched_reg,   admin_id),
    ('EMP-0013', 'Antonio',  'Bautista', 'antonio.b@hris.local',      'contractual', '2024-03-01', dept_hr,      pos_hr_staff, sched_reg,   admin_id)
  on conflict (email) do nothing;

  -- Set HR manager as dept head
  update departments set head_id = (select id from employees where employee_code = 'EMP-0002')
  where name = 'Human Resources';

  -- Set contract end for contractual staff
  update employees set contract_start = '2024-01-01', contract_end = '2024-12-31' where employee_code = 'EMP-0007';
  update employees set contract_start = '2024-06-01', contract_end = '2025-01-31' where employee_code = 'EMP-0008';
  update employees set contract_start = '2024-03-01', contract_end = '2025-03-01' where employee_code = 'EMP-0013';

end $$;

-- ============================================================
-- SEED — Sample Attendance (last 7 days)
-- ============================================================
do $$
declare
  emp record;
  d date;
  sched_reg uuid;
  t_in timestamptz;
  t_out timestamptz;
  stat attendance_status;
  late_min int;
  ot_min int;
begin
  select id into sched_reg from schedules where name = 'Regular 8-5';

  for emp in select id from employees where employment_type != 'janitorial' loop
    for d in select generate_series(current_date - 6, current_date - 1, '1 day'::interval)::date loop
      -- skip weekends
      if extract(dow from d) in (0, 6) then continue; end if;

      -- Randomize status
      case floor(random() * 10)::int
        when 0 then
          stat := 'absent'; t_in := null; t_out := null; late_min := 0; ot_min := 0;
        when 1, 2 then
          stat := 'late';
          late_min := 10 + floor(random() * 50)::int;
          t_in  := (d::timestamptz + interval '8 hours' + (interval '1 minute' * (15 + late_min)));
          t_out := (d::timestamptz + interval '17 hours');
          ot_min := 0;
        when 9 then
          stat := 'overtime';
          t_in  := (d::timestamptz + interval '8 hours');
          t_out := (d::timestamptz + interval '19 hours');
          late_min := 0; ot_min := 90;
        else
          stat := 'present';
          t_in  := (d::timestamptz + interval '8 hours' - interval '5 minutes' + (interval '1 minute' * floor(random()*10)::int));
          t_out := (d::timestamptz + interval '17 hours' + (interval '1 minute' * floor(random()*15)::int));
          late_min := 0; ot_min := 0;
      end case;

      insert into attendance (employee_id, date, time_in, time_out, schedule_id, late_minutes, overtime_minutes, status, source)
      values (emp.id, d, t_in, t_out, sched_reg, late_min, ot_min, stat, 'web')
      on conflict (employee_id, date) do nothing;
    end loop;
  end loop;
end $$;

-- ============================================================
-- SEED — Sample Leave Requests
-- ============================================================
do $$
declare
  emp2 uuid; emp3 uuid; emp6 uuid;
begin
  select id into emp2 from employees where employee_code = 'EMP-0002';
  select id into emp3 from employees where employee_code = 'EMP-0003';
  select id into emp6 from employees where employee_code = 'EMP-0006';

  insert into leave_requests (employee_id, leave_type, start_date, end_date, days_requested, reason, status) values
    (emp2, 'vacation',  current_date + 7,  current_date + 11, 5, 'Family vacation',      'approved'),
    (emp3, 'sick',      current_date - 3,  current_date - 2,  2, 'Fever and flu',        'approved'),
    (emp6, 'emergency', current_date + 1,  current_date + 1,  1, 'Family emergency',     'pending_supervisor'),
    (emp2, 'sick',      current_date - 10, current_date - 9,  2, 'Medical check-up',     'approved'),
    (emp3, 'vacation',  current_date + 14, current_date + 18, 5, 'Anniversary leave',    'pending_hr');

  -- Leave balances
  insert into leave_balances (employee_id, year, leave_type, total_days, used_days)
  select id, extract(year from now())::int, lt, 15, 0
  from employees, unnest(enum_range(null::leave_type)) as lt
  on conflict do nothing;

  update leave_balances set used_days = 7
  where employee_id = emp2 and year = extract(year from now())::int and leave_type = 'vacation';
  update leave_balances set used_days = 2
  where employee_id = emp3 and year = extract(year from now())::int and leave_type = 'sick';
end $$;

-- ============================================================
-- SEED — Sample Notifications for admin
-- ============================================================
insert into notifications (user_id, type, title, body)
select
  u.id,
  'general',
  'Welcome to HRIS',
  'Your admin account has been set up. The system is ready to use.'
from auth.users u
where u.email = 'devresty2024@gmail.com';

insert into notifications (user_id, type, title, body)
select
  u.id,
  'leave_approved',
  'Leave Request Approved',
  'Maria Santos'' vacation leave (5 days) has been approved.'
from auth.users u
where u.email = 'devresty2024@gmail.com';

-- ============================================================
-- VERIFY
-- ============================================================
select 'departments'  as tbl, count(*) from departments  union all
select 'positions',          count(*) from positions     union all
select 'schedules',          count(*) from schedules     union all
select 'employees',          count(*) from employees     union all
select 'attendance',         count(*) from attendance    union all
select 'leave_requests',     count(*) from leave_requests union all
select 'leave_balances',     count(*) from leave_balances union all
select 'notifications',      count(*) from notifications  union all
select 'user_roles',         count(*) from user_roles
order by tbl;
