-- Migration: 012_create_permissions.sql
-- Role-based permission matrix: stores per-role permission toggles.

create table if not exists role_permissions (
  id             bigint generated always as identity primary key,
  role           text        not null,
  permission_key text        not null,
  granted        boolean     not null default true,
  updated_at     timestamptz not null default now(),
  constraint uq_role_permission unique (role, permission_key)
);

-- ── Trigger: keep updated_at fresh ───────────────────────────────────────────
create or replace function hris.set_updated_at()
returns trigger language plpgsql
set search_path = hris, extensions
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_role_permissions_updated_at on role_permissions;
create trigger trg_role_permissions_updated_at
  before update on role_permissions
  for each row execute function hris.set_updated_at();

-- ── Default seed data ─────────────────────────────────────────────────────────

-- Admin: all permissions
insert into role_permissions (role, permission_key, granted) values
  ('admin', 'employees.view',       true),
  ('admin', 'employees.create',     true),
  ('admin', 'employees.edit',       true),
  ('admin', 'employees.delete',     true),
  ('admin', 'attendance.view',      true),
  ('admin', 'attendance.manage',    true),
  ('admin', 'leave.view',           true),
  ('admin', 'leave.request',        true),
  ('admin', 'leave.approve',        true),
  ('admin', 'scheduling.view',      true),
  ('admin', 'scheduling.manage',    true),
  ('admin', 'reports.view',         true),
  ('admin', 'reports.export',       true),
  ('admin', 'notifications.view',   true),
  ('admin', 'settings.view',        true)
on conflict (role, permission_key) do nothing;

-- HR Staff
insert into role_permissions (role, permission_key, granted) values
  ('hr_staff', 'employees.view',       true),
  ('hr_staff', 'employees.create',     true),
  ('hr_staff', 'employees.edit',       true),
  ('hr_staff', 'employees.delete',     false),
  ('hr_staff', 'attendance.view',      true),
  ('hr_staff', 'attendance.manage',    true),
  ('hr_staff', 'leave.view',           true),
  ('hr_staff', 'leave.request',        true),
  ('hr_staff', 'leave.approve',        true),
  ('hr_staff', 'scheduling.view',      true),
  ('hr_staff', 'scheduling.manage',    false),
  ('hr_staff', 'reports.view',         true),
  ('hr_staff', 'reports.export',       true),
  ('hr_staff', 'notifications.view',   true),
  ('hr_staff', 'settings.view',        true)
on conflict (role, permission_key) do nothing;

-- Department Head
insert into role_permissions (role, permission_key, granted) values
  ('department_head', 'employees.view',       true),
  ('department_head', 'employees.create',     false),
  ('department_head', 'employees.edit',       false),
  ('department_head', 'employees.delete',     false),
  ('department_head', 'attendance.view',      true),
  ('department_head', 'attendance.manage',    false),
  ('department_head', 'leave.view',           true),
  ('department_head', 'leave.request',        true),
  ('department_head', 'leave.approve',        true),
  ('department_head', 'scheduling.view',      true),
  ('department_head', 'scheduling.manage',    false),
  ('department_head', 'reports.view',         true),
  ('department_head', 'reports.export',       false),
  ('department_head', 'notifications.view',   true),
  ('department_head', 'settings.view',        false)
on conflict (role, permission_key) do nothing;

-- Supervisor
insert into role_permissions (role, permission_key, granted) values
  ('supervisor', 'employees.view',       true),
  ('supervisor', 'employees.create',     false),
  ('supervisor', 'employees.edit',       false),
  ('supervisor', 'employees.delete',     false),
  ('supervisor', 'attendance.view',      true),
  ('supervisor', 'attendance.manage',    false),
  ('supervisor', 'leave.view',           true),
  ('supervisor', 'leave.request',        true),
  ('supervisor', 'leave.approve',        true),
  ('supervisor', 'scheduling.view',      true),
  ('supervisor', 'scheduling.manage',    false),
  ('supervisor', 'reports.view',         false),
  ('supervisor', 'reports.export',       false),
  ('supervisor', 'notifications.view',   true),
  ('supervisor', 'settings.view',        false)
on conflict (role, permission_key) do nothing;

-- Employee
insert into role_permissions (role, permission_key, granted) values
  ('employee', 'employees.view',       false),
  ('employee', 'employees.create',     false),
  ('employee', 'employees.edit',       false),
  ('employee', 'employees.delete',     false),
  ('employee', 'attendance.view',      true),
  ('employee', 'attendance.manage',    false),
  ('employee', 'leave.view',           true),
  ('employee', 'leave.request',        true),
  ('employee', 'leave.approve',        false),
  ('employee', 'scheduling.view',      false),
  ('employee', 'scheduling.manage',    false),
  ('employee', 'reports.view',         false),
  ('employee', 'reports.export',       false),
  ('employee', 'notifications.view',   true),
  ('employee', 'settings.view',        false)
on conflict (role, permission_key) do nothing;

-- ── Row-Level Security ────────────────────────────────────────────────────────
alter table role_permissions enable row level security;

create policy "Authenticated users can read permissions"
  on role_permissions for select
  to authenticated
  using (true);

create policy "Admins can manage permissions"
  on role_permissions for all
  to authenticated
  using (get_my_role() = 'admin');
