-- ============================================================
-- HRIS App — Demo Seed Data
-- ============================================================
-- 20 employees across 4 departments
-- 2 weeks of attendance history (with late/absent variation)
-- 6 leave requests covering all statuses
-- Leave balances, notifications, contract expiry alerts
-- ============================================================
-- Prerequisites: all 12 migrations must be run first.
-- Run this in the Supabase SQL Editor (service role).
-- Requires: devresty2024@gmail.com must exist in auth.users
--           (run supabase/seed_admin.sql or sign in once first)
-- ============================================================

begin;

-- ── 0. Cleanup ────────────────────────────────────────────────────────────────

delete from hris.notifications;
delete from hris.leave_balances;
delete from hris.leave_requests;
delete from hris.attendance;
delete from hris.employee_documents;
update hris.departments set head_id = null;
delete from hris.employees;
delete from hris.positions;
delete from hris.departments;
delete from hris.user_roles;

-- Reset employee code sequence to match 20 seeded employees
insert into hris.company_settings (id, employee_code_pattern, employee_code_sequence)
values ('singleton', 'YY-E###-MM', 20)
on conflict (id) do update
  set employee_code_pattern  = 'YY-E###-MM',
      employee_code_sequence = 20,
      updated_at             = now();

-- ── 1. Departments (head_id filled later) ────────────────────────────────────

insert into hris.departments (id, name) values
  ('00000002-0000-0000-0000-000000000001', 'Human Resources'),
  ('00000002-0000-0000-0000-000000000002', 'Information Technology'),
  ('00000002-0000-0000-0000-000000000003', 'Finance & Accounting'),
  ('00000002-0000-0000-0000-000000000004', 'Operations');

-- ── 2. Positions ─────────────────────────────────────────────────────────────

insert into hris.positions (id, title, department_id) values
  -- Human Resources
  ('00000003-0000-0000-0000-000000000001', 'System Administrator',  '00000002-0000-0000-0000-000000000001'),
  ('00000003-0000-0000-0000-000000000002', 'HR Manager',            '00000002-0000-0000-0000-000000000001'),
  ('00000003-0000-0000-0000-000000000003', 'HR Officer',            '00000002-0000-0000-0000-000000000001'),
  -- Information Technology
  ('00000003-0000-0000-0000-000000000004', 'IT Manager',            '00000002-0000-0000-0000-000000000002'),
  ('00000003-0000-0000-0000-000000000005', 'Senior Developer',      '00000002-0000-0000-0000-000000000002'),
  ('00000003-0000-0000-0000-000000000006', 'Developer',             '00000002-0000-0000-0000-000000000002'),
  ('00000003-0000-0000-0000-000000000007', 'IT Support Specialist', '00000002-0000-0000-0000-000000000002'),
  -- Finance & Accounting
  ('00000003-0000-0000-0000-000000000008', 'Finance Manager',       '00000002-0000-0000-0000-000000000003'),
  ('00000003-0000-0000-0000-000000000009', 'Senior Accountant',     '00000002-0000-0000-0000-000000000003'),
  ('00000003-0000-0000-0000-000000000010', 'Accountant',            '00000002-0000-0000-0000-000000000003'),
  ('00000003-0000-0000-0000-000000000011', 'Finance Analyst',       '00000002-0000-0000-0000-000000000003'),
  -- Operations
  ('00000003-0000-0000-0000-000000000012', 'Operations Manager',    '00000002-0000-0000-0000-000000000004'),
  ('00000003-0000-0000-0000-000000000013', 'Operations Supervisor', '00000002-0000-0000-0000-000000000004'),
  ('00000003-0000-0000-0000-000000000014', 'Operations Staff',      '00000002-0000-0000-0000-000000000004'),
  ('00000003-0000-0000-0000-000000000015', 'Maintenance Staff',     '00000002-0000-0000-0000-000000000004'),
  ('00000003-0000-0000-0000-000000000016', 'Janitor',               '00000002-0000-0000-0000-000000000004');

-- ── 3. Employees (supervisor_id set via UPDATE below) ─────────────────────────

insert into hris.employees (
  id, user_id, employee_code,
  first_name, last_name, middle_name,
  email, phone, birthdate, civil_status,
  employment_type, employment_status,
  department_id, position_id,
  hire_date
) values

-- ── Human Resources ────────────────────────────────────────────────────────────

-- 01 — Admin (linked to real auth user)
( '00000004-0000-0000-0000-000000000001',
  (select id from auth.users where email = 'devresty2024@gmail.com' limit 1),
  '26-E001-01', 'Ricardo', 'Alvarez', 'M.',
  'devresty2024@gmail.com', '+63 912 001 0001', '1985-03-22', 'married',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000001', '00000003-0000-0000-0000-000000000001',
  '2020-01-06' ),

-- 02 — HR Manager
( '00000004-0000-0000-0000-000000000002', null,
  '26-E002-01', 'Maria', 'Santos', 'L.',
  'm.santos@westbridge.ph', '+63 912 002 0002', '1988-07-14', 'married',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000001', '00000003-0000-0000-0000-000000000002',
  '2021-03-01' ),

-- 03 — HR Officer
( '00000004-0000-0000-0000-000000000003', null,
  '26-E003-02', 'Jose', 'Reyes', 'A.',
  'j.reyes@westbridge.ph', '+63 912 003 0003', '1992-11-05', 'single',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000001', '00000003-0000-0000-0000-000000000003',
  '2022-02-14' ),

-- ── Information Technology ──────────────────────────────────────────────────────

-- 04 — IT Manager (Department Head)
( '00000004-0000-0000-0000-000000000004', null,
  '26-E004-01', 'Pedro', 'dela Rosa', 'C.',
  'p.delarosa@westbridge.ph', '+63 912 004 0004', '1980-09-30', 'married',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000002', '00000003-0000-0000-0000-000000000004',
  '2019-06-01' ),

-- 05 — Senior Developer (Supervisor)
( '00000004-0000-0000-0000-000000000005', null,
  '26-E005-06', 'Michael', 'Garcia', 'T.',
  'm.garcia@westbridge.ph', '+63 912 005 0005', '1990-12-18', 'single',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000002', '00000003-0000-0000-0000-000000000005',
  '2021-06-15' ),

-- 06 — Developer (contractual — expiring soon)
( '00000004-0000-0000-0000-000000000006', null,
  '26-E006-09', 'Carlos', 'Soriano', 'B.',
  'c.soriano@westbridge.ph', '+63 912 006 0006', '1995-04-12', 'single',
  'contractual', 'active',
  '00000002-0000-0000-0000-000000000002', '00000003-0000-0000-0000-000000000006',
  '2025-09-01' ),

-- 07 — Developer
( '00000004-0000-0000-0000-000000000007', null,
  '26-E007-09', 'Maria Elena', 'Aquino', 'D.',
  'me.aquino@westbridge.ph', '+63 912 007 0007', '1997-02-28', 'single',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000002', '00000003-0000-0000-0000-000000000006',
  '2023-09-04' ),

-- 08 — IT Support (contractual — expiring soon)
( '00000004-0000-0000-0000-000000000008', null,
  '26-E008-10', 'Juan', 'Flores', 'R.',
  'j.flores@westbridge.ph', '+63 912 008 0008', '1998-06-20', 'single',
  'contractual', 'active',
  '00000002-0000-0000-0000-000000000002', '00000003-0000-0000-0000-000000000007',
  '2025-10-01' ),

-- ── Finance & Accounting ───────────────────────────────────────────────────────

-- 09 — Finance Manager (Department Head)
( '00000004-0000-0000-0000-000000000009', null,
  '26-E009-01', 'Carmen', 'Villanueva', 'R.',
  'c.villanueva@westbridge.ph', '+63 912 009 0009', '1982-05-17', 'married',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000003', '00000003-0000-0000-0000-000000000008',
  '2020-01-13' ),

-- 10 — Senior Accountant (Supervisor)
( '00000004-0000-0000-0000-000000000010', null,
  '26-E010-04', 'Jennifer', 'Torres', 'M.',
  'j.torres@westbridge.ph', '+63 912 010 0010', '1987-08-25', 'married',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000003', '00000003-0000-0000-0000-000000000009',
  '2021-04-05' ),

-- 11 — Accountant
( '00000004-0000-0000-0000-000000000011', null,
  '26-E011-07', 'Angelica', 'Santos', 'P.',
  'a.santos@westbridge.ph', '+63 912 011 0011', '1994-01-09', 'single',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000003', '00000003-0000-0000-0000-000000000010',
  '2022-07-18' ),

-- 12 — Finance Analyst (late today)
( '00000004-0000-0000-0000-000000000012', null,
  '26-E012-08', 'Mark', 'Tan', 'K.',
  'm.tan@westbridge.ph', '+63 912 012 0012', '1996-10-03', 'single',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000003', '00000003-0000-0000-0000-000000000011',
  '2023-08-21' ),

-- 13 — Finance Analyst (on approved leave today)
( '00000004-0000-0000-0000-000000000013', null,
  '26-E013-11', 'Nina', 'Castillo', 'V.',
  'n.castillo@westbridge.ph', '+63 912 013 0013', '1993-03-07', 'single',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000003', '00000003-0000-0000-0000-000000000011',
  '2022-11-07' ),

-- ── Operations ────────────────────────────────────────────────────────────────

-- 14 — Operations Manager (Department Head)
( '00000004-0000-0000-0000-000000000014', null,
  '26-E014-01', 'Roberto', 'Bautista', 'G.',
  'r.bautista@westbridge.ph', '+63 912 014 0014', '1979-12-01', 'married',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000004', '00000003-0000-0000-0000-000000000012',
  '2018-01-15' ),

-- 15 — Operations Supervisor
( '00000004-0000-0000-0000-000000000015', null,
  '26-E015-03', 'Eduardo', 'Cruz', 'L.',
  'e.cruz@westbridge.ph', '+63 912 015 0015', '1984-07-22', 'married',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000004', '00000003-0000-0000-0000-000000000013',
  '2020-03-02' ),

-- 16 — Operations Staff (absent today)
( '00000004-0000-0000-0000-000000000016', null,
  '26-E016-05', 'Dave', 'Morales', 'F.',
  'd.morales@westbridge.ph', '+63 912 016 0016', '1991-11-11', 'single',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000004', '00000003-0000-0000-0000-000000000014',
  '2021-05-10' ),

-- 17 — Operations Staff
( '00000004-0000-0000-0000-000000000017', null,
  '26-E017-05', 'Grace', 'Uy', 'S.',
  'g.uy@westbridge.ph', '+63 912 017 0017', '1999-09-15', 'single',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000004', '00000003-0000-0000-0000-000000000014',
  '2024-05-06' ),

-- 18 — Operations Staff (late today)
( '00000004-0000-0000-0000-000000000018', null,
  '26-E018-07', 'Alan', 'Pascual', 'N.',
  'a.pascual@westbridge.ph', '+63 912 018 0018', '1989-04-19', 'married',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000004', '00000003-0000-0000-0000-000000000014',
  '2022-07-25' ),

-- 19 — Maintenance Staff
( '00000004-0000-0000-0000-000000000019', null,
  '26-E019-02', 'Rose', 'Medina', 'C.',
  'r.medina@westbridge.ph', '+63 912 019 0019', '1986-06-30', 'separated',
  'regular', 'active',
  '00000002-0000-0000-0000-000000000004', '00000003-0000-0000-0000-000000000015',
  '2021-02-01' ),

-- 20 — Janitor (absent today)
( '00000004-0000-0000-0000-000000000020', null,
  '26-E020-08', 'Ben', 'Corpuz', 'O.',
  'b.corpuz@westbridge.ph', '+63 912 020 0020', '1975-08-04', 'married',
  'janitorial', 'active',
  '00000002-0000-0000-0000-000000000004', '00000003-0000-0000-0000-000000000016',
  '2019-08-12' );

-- Set contract dates for contractual employees (expiring within 30 days)
update hris.employees
set contract_start = '2025-09-01', contract_end = CURRENT_DATE + 18
where id = '00000004-0000-0000-0000-000000000006';  -- Carlos Soriano

update hris.employees
set contract_start = '2025-10-01', contract_end = CURRENT_DATE + 33
where id = '00000004-0000-0000-0000-000000000008';  -- Juan Flores

-- ── 4. Supervisor hierarchy ───────────────────────────────────────────────────

-- Maria Santos manages Jose Reyes
update hris.employees set supervisor_id = '00000004-0000-0000-0000-000000000002'
where id = '00000004-0000-0000-0000-000000000003';

-- Pedro manages Michael
update hris.employees set supervisor_id = '00000004-0000-0000-0000-000000000004'
where id = '00000004-0000-0000-0000-000000000005';

-- Michael manages Carlos, Maria Elena, Juan
update hris.employees set supervisor_id = '00000004-0000-0000-0000-000000000005'
where id in (
  '00000004-0000-0000-0000-000000000006',
  '00000004-0000-0000-0000-000000000007',
  '00000004-0000-0000-0000-000000000008'
);

-- Carmen manages Jennifer
update hris.employees set supervisor_id = '00000004-0000-0000-0000-000000000009'
where id = '00000004-0000-0000-0000-000000000010';

-- Jennifer manages Angelica, Mark, Nina
update hris.employees set supervisor_id = '00000004-0000-0000-0000-000000000010'
where id in (
  '00000004-0000-0000-0000-000000000011',
  '00000004-0000-0000-0000-000000000012',
  '00000004-0000-0000-0000-000000000013'
);

-- Roberto manages Eduardo
update hris.employees set supervisor_id = '00000004-0000-0000-0000-000000000014'
where id = '00000004-0000-0000-0000-000000000015';

-- Eduardo manages operations staff
update hris.employees set supervisor_id = '00000004-0000-0000-0000-000000000015'
where id in (
  '00000004-0000-0000-0000-000000000016',
  '00000004-0000-0000-0000-000000000017',
  '00000004-0000-0000-0000-000000000018',
  '00000004-0000-0000-0000-000000000019',
  '00000004-0000-0000-0000-000000000020'
);

-- ── 5. User role for admin ────────────────────────────────────────────────────

insert into hris.user_roles (user_id, role)
select id, 'admin'
from auth.users
where email = 'devresty2024@gmail.com'
on conflict (user_id, role) do nothing;

-- ── 6. Department heads ───────────────────────────────────────────────────────

update hris.departments set head_id = '00000004-0000-0000-0000-000000000002'
where id = '00000002-0000-0000-0000-000000000001';  -- HR → Maria Santos

update hris.departments set head_id = '00000004-0000-0000-0000-000000000004'
where id = '00000002-0000-0000-0000-000000000002';  -- IT → Pedro dela Rosa

update hris.departments set head_id = '00000004-0000-0000-0000-000000000009'
where id = '00000002-0000-0000-0000-000000000003';  -- Finance → Carmen Villanueva

update hris.departments set head_id = '00000004-0000-0000-0000-000000000014'
where id = '00000002-0000-0000-0000-000000000004';  -- Operations → Roberto Bautista

-- ── 7. Employee schedules ─────────────────────────────────────────────────────

-- All employees default to Regular 8-5
update hris.employees
set schedule_id = (select id from hris.schedules where name = 'Regular 8-5' limit 1);

-- Janitor uses split shift
update hris.employees
set schedule_id = (select id from hris.schedules where name = 'Janitor Split' limit 1)
where id = '00000004-0000-0000-0000-000000000020';

-- ── 8. Leave requests ─────────────────────────────────────────────────────────

insert into hris.leave_requests (
  id, employee_id, leave_type,
  start_date, end_date, days_requested,
  reason, status,
  supervisor_id, supervisor_action_at, supervisor_remarks,
  hr_approver_id, hr_action_at, hr_remarks
) values

-- APPROVED — Nina Castillo, vacation, covering today
( gen_random_uuid(),
  '00000004-0000-0000-0000-000000000013', 'vacation',
  CURRENT_DATE - 2, CURRENT_DATE + 1, 4.0,
  'Family vacation planned for the long weekend.',
  'approved',
  '00000004-0000-0000-0000-000000000010', CURRENT_DATE - 5, 'Approved. Have a good rest.',
  '00000004-0000-0000-0000-000000000002', CURRENT_DATE - 4, 'Approved.' ),

-- APPROVED — Carlos Soriano, sick leave (2 weeks ago)
( gen_random_uuid(),
  '00000004-0000-0000-0000-000000000006', 'sick',
  CURRENT_DATE - 14, CURRENT_DATE - 13, 2.0,
  'Fever and flu symptoms.',
  'approved',
  '00000004-0000-0000-0000-000000000005', CURRENT_DATE - 14, 'Get well soon. Approved.',
  '00000004-0000-0000-0000-000000000002', CURRENT_DATE - 13, 'Approved.' ),

-- APPROVED — Juan Flores, emergency leave (1 week ago)
( gen_random_uuid(),
  '00000004-0000-0000-0000-000000000008', 'emergency',
  CURRENT_DATE - 7, CURRENT_DATE - 6, 2.0,
  'Family emergency — hospitalization of parent.',
  'approved',
  '00000004-0000-0000-0000-000000000005', CURRENT_DATE - 7, 'Approved. Hope everything is okay.',
  '00000004-0000-0000-0000-000000000002', CURRENT_DATE - 7, 'Approved per emergency leave policy.' ),

-- PENDING HR — Grace Uy, vacation next week (supervisor approved, waiting on HR)
( gen_random_uuid(),
  '00000004-0000-0000-0000-000000000017', 'vacation',
  CURRENT_DATE + 9, CURRENT_DATE + 13, 5.0,
  'Going home to province for a family event.',
  'pending_hr',
  '00000004-0000-0000-0000-000000000015', CURRENT_DATE - 1, 'Approved by supervisor. Endorsed to HR.',
  null, null, null ),

-- PENDING SUPERVISOR — Mark Tan, vacation in 3 weeks
( gen_random_uuid(),
  '00000004-0000-0000-0000-000000000012', 'vacation',
  CURRENT_DATE + 16, CURRENT_DATE + 20, 5.0,
  'Annual family vacation.',
  'pending_supervisor',
  null, null, null,
  null, null, null ),

-- REJECTED — Alan Pascual, sick (3 days ago, no medical cert)
( gen_random_uuid(),
  '00000004-0000-0000-0000-000000000018', 'sick',
  CURRENT_DATE - 3, CURRENT_DATE - 3, 1.0,
  'Not feeling well.',
  'rejected',
  '00000004-0000-0000-0000-000000000015', CURRENT_DATE - 3,
  'Please provide medical certificate. Application rejected.',
  null, null, null );

-- ── 9. Historical attendance (past 14 calendar days, Mon–Fri only) ────────────
-- Most employees present. Approved leave days are automatically skipped.

do $$
declare
  work_date  date;
  emp        record;
  sched_id   uuid;
  mins_in    int;
  mins_out   int;
begin
  select id into sched_id from hris.schedules where name = 'Regular 8-5' limit 1;

  for work_date in
    select d::date
    from generate_series(current_date - 14, current_date - 1, '1 day'::interval) d
    where extract(dow from d) between 1 and 5   -- Mon–Fri only
  loop
    for emp in
      select id from hris.employees where employment_status = 'active'
    loop
      -- Skip days covered by approved leave
      continue when exists (
        select 1 from hris.leave_requests
        where employee_id = emp.id
          and status       = 'approved'
          and start_date  <= work_date
          and end_date    >= work_date
      );

      -- Deterministic time variation per employee (07:45 → 08:14 check-in)
      mins_in  := (abs(hashtext(emp.id::text))                  % 30);
      mins_out := (abs(hashtext(emp.id::text || work_date::text)) % 75);

      insert into hris.attendance (
        employee_id, date,
        time_in,
        time_out,
        status, source, schedule_id
      ) values (
        emp.id, work_date,
        work_date + interval '07:45' + mins_in  * interval '1 minute',
        work_date + interval '17:00' + mins_out * interval '1 minute',
        'present', 'web', sched_id
      )
      on conflict (employee_id, date) do nothing;
    end loop;
  end loop;
end $$;

-- ── Historical overrides: late and absent days ────────────────────────────────

-- Mark Tan: late two separate days (history)
update hris.attendance
set time_in = date + interval '09:12', late_minutes = 57, status = 'late'
where employee_id = '00000004-0000-0000-0000-000000000012'
  and date = current_date - 7
  and extract(dow from date) between 1 and 5;

update hris.attendance
set time_in = date + interval '08:43', late_minutes = 28, status = 'late'
where employee_id = '00000004-0000-0000-0000-000000000012'
  and date = current_date - 3
  and extract(dow from date) between 1 and 5;

-- Ben Corpuz: absent two days (no-show, no reason)
update hris.attendance
set time_in = null, time_out = null, status = 'absent'
where employee_id = '00000004-0000-0000-0000-000000000020'
  and date in (current_date - 5, current_date - 4);

-- Alan Pascual: absent the day his sick leave was rejected
update hris.attendance
set time_in = null, time_out = null, status = 'absent'
where employee_id = '00000004-0000-0000-0000-000000000018'
  and date = current_date - 3;

-- Dave Morales: one absent day mid-week
update hris.attendance
set time_in = null, time_out = null, status = 'absent'
where employee_id = '00000004-0000-0000-0000-000000000016'
  and date = current_date - 9
  and extract(dow from date) between 1 and 5;

-- ── 10. Today's attendance ────────────────────────────────────────────────────
-- present: 15, late: 2, absent: 2, on leave: 1 (Nina — no record)

do $$
declare
  sched_id uuid;
begin
  select id into sched_id from hris.schedules where name = 'Regular 8-5' limit 1;

  -- Present (15 employees)
  insert into hris.attendance (employee_id, date, time_in, status, source, schedule_id)
  select
    id, current_date,
    current_date + interval '07:45' + (abs(hashtext(id::text)) % 30) * interval '1 minute',
    'present', 'web', sched_id
  from hris.employees
  where id in (
    '00000004-0000-0000-0000-000000000001',  -- Ricardo
    '00000004-0000-0000-0000-000000000002',  -- Maria Santos
    '00000004-0000-0000-0000-000000000003',  -- Jose Reyes
    '00000004-0000-0000-0000-000000000004',  -- Pedro dela Rosa
    '00000004-0000-0000-0000-000000000005',  -- Michael Garcia
    '00000004-0000-0000-0000-000000000006',  -- Carlos Soriano
    '00000004-0000-0000-0000-000000000007',  -- Maria Elena Aquino
    '00000004-0000-0000-0000-000000000008',  -- Juan Flores
    '00000004-0000-0000-0000-000000000009',  -- Carmen Villanueva
    '00000004-0000-0000-0000-000000000010',  -- Jennifer Torres
    '00000004-0000-0000-0000-000000000011',  -- Angelica Santos
    '00000004-0000-0000-0000-000000000014',  -- Roberto Bautista
    '00000004-0000-0000-0000-000000000015',  -- Eduardo Cruz
    '00000004-0000-0000-0000-000000000017',  -- Grace Uy
    '00000004-0000-0000-0000-000000000019'   -- Rose Medina
  )
  on conflict (employee_id, date) do nothing;

  -- Late (2 employees)
  insert into hris.attendance (employee_id, date, time_in, late_minutes, status, source, schedule_id)
  values
    -- Mark Tan: 09:03 → 48 min late (08:15 grace end)
    ( '00000004-0000-0000-0000-000000000012', current_date,
      current_date + interval '09:03', 48, 'late', 'web', sched_id ),
    -- Alan Pascual: 09:28 → 73 min late
    ( '00000004-0000-0000-0000-000000000018', current_date,
      current_date + interval '09:28', 73, 'late', 'web', sched_id )
  on conflict (employee_id, date) do nothing;

  -- Absent (2 employees)
  insert into hris.attendance (employee_id, date, status, source, schedule_id)
  values
    ( '00000004-0000-0000-0000-000000000016', current_date, 'absent', 'web', sched_id ),  -- Dave Morales
    ( '00000004-0000-0000-0000-000000000020', current_date, 'absent', 'web', sched_id )   -- Ben Corpuz
  on conflict (employee_id, date) do nothing;

  -- Nina Castillo (013): no record — she is on approved leave.
end $$;

-- ── 11. Leave balances (current year) ────────────────────────────────────────

insert into hris.leave_balances (employee_id, year, leave_type, total_days, used_days)
select
  e.id,
  extract(year from current_date)::int,
  lt.leave_type,
  lt.total,
  0  -- used_days set per-employee below
from hris.employees e
cross join (values
  ('vacation'::leave_type, 15.0),
  ('sick'::leave_type,     10.0),
  ('emergency'::leave_type, 3.0)
) as lt(leave_type, total)
on conflict (employee_id, year, leave_type) do nothing;

-- Mark used_days from approved leaves
update hris.leave_balances lb
set used_days = (
  select coalesce(sum(lr.days_requested), 0)
  from hris.leave_requests lr
  where lr.employee_id = lb.employee_id
    and lr.leave_type  = lb.leave_type
    and extract(year from lr.start_date) = lb.year
    and lr.status = 'approved'
)
where lb.year = extract(year from current_date)::int;

-- ── 12. Notifications (for admin user) ───────────────────────────────────────

insert into hris.notifications (user_id, type, title, body, is_read, metadata, created_at)
select uid, type, title, body, is_read, metadata, created_at
from (
  select
    (select id from auth.users where email = 'devresty2024@gmail.com') as uid,
    v.*
  from (values
    -- Contract expiry alerts
    ( 'contract_expiring'::notification_type,
      'Contract Expiring Soon — Carlos Soriano',
      'EMP-06 Carlos Soriano''s contract expires in 18 days (contractual). Please prepare renewal or separation documents.',
      false,
      '{"employee_id":"00000004-0000-0000-0000-000000000006"}'::jsonb,
      now() - interval '1 hour' ),

    ( 'contract_expiring'::notification_type,
      'Contract Expiring Soon — Juan Flores',
      'EMP-08 Juan Flores''s contract expires in 33 days (contractual). Action required.',
      false,
      '{"employee_id":"00000004-0000-0000-0000-000000000008"}'::jsonb,
      now() - interval '2 hours' ),

    -- Leave approved
    ( 'leave_approved'::notification_type,
      'Leave Request Approved — Nina Castillo',
      'Vacation leave for Nina Castillo (Mar ' || to_char(current_date - 2, 'DD') || '–' || to_char(current_date + 1, 'DD') || ') has been fully approved.',
      true,
      '{"employee_id":"00000004-0000-0000-0000-000000000013"}'::jsonb,
      now() - interval '4 days' ),

    -- Pending leave waiting for HR action
    ( 'general'::notification_type,
      'Leave Pending HR Approval — Grace Uy',
      'Grace Uy''s vacation leave request (5 days) has been approved by supervisor and is waiting for your HR approval.',
      false,
      '{"employee_id":"00000004-0000-0000-0000-000000000017"}'::jsonb,
      now() - interval '1 day' ),

    -- Late alerts
    ( 'late_alert'::notification_type,
      'Late Arrival — Mark Tan',
      'Mark Tan checked in at 09:03 today — 48 minutes late.',
      false,
      '{"employee_id":"00000004-0000-0000-0000-000000000012"}'::jsonb,
      now() - interval '30 minutes' ),

    ( 'late_alert'::notification_type,
      'Late Arrival — Alan Pascual',
      'Alan Pascual checked in at 09:28 today — 73 minutes late.',
      false,
      '{"employee_id":"00000004-0000-0000-0000-000000000018"}'::jsonb,
      now() - interval '25 minutes' ),

    -- Leave rejected
    ( 'leave_rejected'::notification_type,
      'Leave Rejected — Alan Pascual',
      'Sick leave application filed by Alan Pascual was rejected by supervisor (no medical certificate provided).',
      true,
      '{"employee_id":"00000004-0000-0000-0000-000000000018"}'::jsonb,
      now() - interval '3 days' ),

    -- Emergency leave approved
    ( 'leave_approved'::notification_type,
      'Emergency Leave Approved — Juan Flores',
      'Juan Flores'' emergency leave (2 days) has been approved.',
      true,
      '{"employee_id":"00000004-0000-0000-0000-000000000008"}'::jsonb,
      now() - interval '7 days' )

  ) as v(type, title, body, is_read, metadata, created_at)
) data
where uid is not null;

-- ── Done ──────────────────────────────────────────────────────────────────────

commit;

-- Quick verification
select
  (select count(*) from hris.employees)            as total_employees,
  (select count(*) from hris.departments)          as departments,
  (select count(*) from hris.attendance
   where date = current_date)                        as attendance_today,
  (select count(*) from hris.attendance
   where date = current_date and status = 'present') as present_today,
  (select count(*) from hris.attendance
   where date = current_date and status = 'late')    as late_today,
  (select count(*) from hris.attendance
   where date = current_date and status = 'absent')  as absent_today,
  (select count(*) from hris.leave_requests)       as leave_requests,
  (select count(*) from hris.notifications)        as notifications;
