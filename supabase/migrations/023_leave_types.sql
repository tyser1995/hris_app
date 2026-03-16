-- 023_leave_types.sql
-- Creates a dynamic leave_types table per organization.
-- Migrates leave_requests.leave_type and leave_balances.leave_type
-- from the hris.leave_type ENUM to plain TEXT.

set search_path to hris, extensions;

-- ── 1. Create leave_types table ───────────────────────────────────────────────
create table hris.leave_types (
  id              uuid        primary key default gen_random_uuid(),
  organization_id uuid        not null references hris.organizations(id) on delete cascade,
  name            text        not null,
  created_at      timestamptz default now(),
  unique (organization_id, name)
);

-- ── 2. Seed default types for every existing organization ─────────────────────
insert into hris.leave_types (organization_id, name)
select o.id, t.name
from hris.organizations o
cross join (
  values
    ('Vacation'),
    ('Sick'),
    ('Emergency'),
    ('Maternity'),
    ('Paternity'),
    ('Leave Without Pay')
) as t(name)
on conflict (organization_id, name) do nothing;

-- ── 3. RLS ────────────────────────────────────────────────────────────────────
alter table hris.leave_types enable row level security;

create policy "leave_types_select_own_org"
  on hris.leave_types for select
  to authenticated
  using (organization_id = hris.get_my_organization_id());

create policy "leave_types_insert_admin_hr"
  on hris.leave_types for insert
  to authenticated
  with check (
    organization_id = hris.get_my_organization_id()
    and hris.get_my_role() in ('admin', 'hr_staff')
  );

create policy "leave_types_update_admin_hr"
  on hris.leave_types for update
  to authenticated
  using    (organization_id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'))
  with check (organization_id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'));

create policy "leave_types_delete_admin_hr"
  on hris.leave_types for delete
  to authenticated
  using (organization_id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'));

-- ── 4. Migrate leave_requests.leave_type from ENUM to TEXT ───────────────────
alter table hris.leave_requests add column if not exists leave_type_text text;

update hris.leave_requests set leave_type_text = case leave_type::text
  when 'vacation'    then 'Vacation'
  when 'sick'        then 'Sick'
  when 'emergency'   then 'Emergency'
  when 'maternity'   then 'Maternity'
  when 'paternity'   then 'Paternity'
  when 'without_pay' then 'Leave Without Pay'
  else initcap(replace(leave_type::text, '_', ' '))
end;

alter table hris.leave_requests drop column leave_type;
alter table hris.leave_requests rename column leave_type_text to leave_type;
alter table hris.leave_requests alter column leave_type set not null;
alter table hris.leave_requests alter column leave_type set default 'Vacation';

-- ── 5. Migrate leave_balances.leave_type from ENUM to TEXT ───────────────────
alter table hris.leave_balances drop constraint if exists leave_balances_employee_id_year_leave_type_key;

alter table hris.leave_balances add column if not exists leave_type_text text;

update hris.leave_balances set leave_type_text = case leave_type::text
  when 'vacation'    then 'Vacation'
  when 'sick'        then 'Sick'
  when 'emergency'   then 'Emergency'
  when 'maternity'   then 'Maternity'
  when 'paternity'   then 'Paternity'
  when 'without_pay' then 'Leave Without Pay'
  else initcap(replace(leave_type::text, '_', ' '))
end;

alter table hris.leave_balances drop column leave_type;
alter table hris.leave_balances rename column leave_type_text to leave_type;
alter table hris.leave_balances alter column leave_type set not null;

alter table hris.leave_balances
  add constraint leave_balances_employee_id_year_leave_type_key
  unique (employee_id, year, leave_type);

-- ── 6. Drop the old enum type ─────────────────────────────────────────────────
drop type if exists hris.leave_type;

-- ── 7. Index ──────────────────────────────────────────────────────────────────
create index if not exists idx_leave_types_org
  on hris.leave_types (organization_id);
