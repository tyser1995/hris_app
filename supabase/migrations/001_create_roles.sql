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
