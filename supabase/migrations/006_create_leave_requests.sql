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
