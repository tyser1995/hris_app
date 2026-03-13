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
