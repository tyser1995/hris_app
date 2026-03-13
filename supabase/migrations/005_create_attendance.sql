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
  for each row execute function hris.update_updated_at_column();
