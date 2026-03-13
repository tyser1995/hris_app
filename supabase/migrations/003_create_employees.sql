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
create or replace function hris.update_updated_at_column()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger employees_updated_at
  before update on employees
  for each row execute function hris.update_updated_at_column();
