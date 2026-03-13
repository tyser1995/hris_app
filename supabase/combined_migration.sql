-- 001_create_roles.sql

create type user_role as enum ('admin', 'hr_staff', 'department_head', 'supervisor', 'employee');

create table roles (
  id uuid primary key default gen_random_uuid(),
  name user_role unique not null,
  created_at timestamptz default now()
);

insert into roles (name) values
  ('admin'),
  ('hr_staff'),
  ('department_head'),
  ('supervisor'),
  ('employee');

create table user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  role user_role not null default 'employee',
  created_at timestamptz default now(),
  unique(user_id, role)
);
-- 002_create_departments_positions.sql

create table departments (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  head_id uuid,  -- FK to employees added after employees table
  created_at timestamptz default now()
);

create table positions (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  department_id uuid references departments(id) on delete set null,
  created_at timestamptz default now()
);
-- 003_create_employees.sql

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
  schedule_id uuid,  -- FK added after schedules table
  hire_date date not null,
  employment_status employment_status not null default 'active',
  contract_start date,
  contract_end date,
  -- personal info
  address text,
  phone text,
  email text unique not null,
  birthdate date,
  civil_status civil_status,
  -- profile
  avatar_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Now add FK from departments.head_id to employees
alter table departments
  add constraint fk_dept_head
  foreign key (head_id) references employees(id) on delete set null;

-- Trigger to auto-update updated_at
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
-- 004_create_schedules.sql

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
  day_of_week int check (day_of_week between 0 and 6),  -- null = applies every day
  start_time time not null,
  end_time time not null,
  period_label text   -- e.g. 'Morning', 'Evening' for broken shifts
);

-- Link employees to schedules (FK deferred until after schedules table exists)
alter table employees
  add constraint fk_employee_schedule
  foreign key (schedule_id) references schedules(id) on delete set null;

-- Seed default schedules
insert into schedules (name, type) values
  ('Regular 8-5', 'regular'),
  ('Janitor Split', 'broken'),
  ('Faculty Flexible', 'flexible');

-- Regular shift details
insert into schedule_details (schedule_id, start_time, end_time, period_label)
select id, '08:00', '17:00', 'Full Day' from schedules where name = 'Regular 8-5';

-- Broken (split) shift details
insert into schedule_details (schedule_id, start_time, end_time, period_label)
select id, '04:00', '08:00', 'Morning' from schedules where name = 'Janitor Split';

insert into schedule_details (schedule_id, start_time, end_time, period_label)
select id, '17:00', '21:00', 'Evening' from schedules where name = 'Janitor Split';
-- 005_create_attendance.sql

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
-- 006_create_leave_requests.sql

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
-- 007_create_notifications.sql

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
-- 008_create_documents.sql

create type document_type as enum ('contract', 'id', 'certificate', 'other');

create table employee_documents (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references employees(id) on delete cascade not null,
  document_type document_type not null,
  file_name text not null,
  file_path text not null,   -- Supabase Storage path
  uploaded_by uuid references auth.users(id),
  created_at timestamptz default now()
);
-- 009_rls_policies.sql

-- Enable RLS
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

-- Helper: get current user's role
create or replace function get_my_role()
returns user_role language sql security definer stable as $$
  select role from user_roles where user_id = (select auth.uid()) limit 1;
$$;

-- Helper: get current user's employee id
create or replace function get_my_employee_id()
returns uuid language sql security definer stable as $$
  select id from employees where user_id = (select auth.uid()) limit 1;
$$;

-- ── user_roles ────────────────────────────────────────────────────────────────
create policy "user_roles_select_own" on user_roles for select
  to authenticated using (user_id = (select auth.uid()));

-- ── departments ───────────────────────────────────────────────────────────────
create policy "departments_select_all" on departments for select
  to authenticated using (true);

create policy "departments_write_admin_hr" on departments for all
  to authenticated using (get_my_role() in ('admin', 'hr_staff'));

-- ── positions ─────────────────────────────────────────────────────────────────
create policy "positions_select_all" on positions for select
  to authenticated using (true);

create policy "positions_write_admin_hr" on positions for all
  to authenticated using (get_my_role() in ('admin', 'hr_staff'));

-- ── schedules ─────────────────────────────────────────────────────────────────
create policy "schedules_select_all" on schedules for select
  to authenticated using (true);

create policy "schedules_write_admin_hr" on schedules for all
  to authenticated using (get_my_role() in ('admin', 'hr_staff'));

-- ── schedule_details ──────────────────────────────────────────────────────────
create policy "schedule_details_select_all" on schedule_details for select
  to authenticated using (true);

create policy "schedule_details_write_admin_hr" on schedule_details for all
  to authenticated using (get_my_role() in ('admin', 'hr_staff'));

-- ── employees ─────────────────────────────────────────────────────────────────
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

-- ── attendance ────────────────────────────────────────────────────────────────
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

-- ── leave_requests ────────────────────────────────────────────────────────────
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

-- ── leave_balances ────────────────────────────────────────────────────────────
create policy "leave_balances_select" on leave_balances for select
  to authenticated
  using (
    get_my_role() in ('admin', 'hr_staff')
    or employee_id = get_my_employee_id()
  );

-- ── notifications ─────────────────────────────────────────────────────────────
create policy "notifications_own" on notifications for select
  to authenticated
  using (user_id = (select auth.uid()));

create policy "notifications_mark_read" on notifications for update
  to authenticated
  using (user_id = (select auth.uid()));

-- ── employee_documents ────────────────────────────────────────────────────────
create policy "documents_select" on employee_documents for select
  to authenticated
  using (
    get_my_role() in ('admin', 'hr_staff')
    or employee_id = get_my_employee_id()
  );

create policy "documents_insert_admin_hr" on employee_documents for insert
  to authenticated
  with check (get_my_role() in ('admin', 'hr_staff'));
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
