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
