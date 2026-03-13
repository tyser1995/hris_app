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
