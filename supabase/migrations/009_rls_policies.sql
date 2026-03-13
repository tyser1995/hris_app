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
