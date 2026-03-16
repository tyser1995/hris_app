-- 022_org_scope_departments.sql
-- Adds organization_id to departments and positions tables so each org has
-- its own isolated set. Migrates existing rows to the first (default) org,
-- then tightens RLS to be org-scoped.

set search_path to hris, extensions;

-- ── 1. Add organization_id columns ───────────────────────────────────────────
alter table hris.departments
  add column if not exists organization_id uuid references hris.organizations(id) on delete cascade;

alter table hris.positions
  add column if not exists organization_id uuid references hris.organizations(id) on delete cascade;

-- ── 2. Backfill existing rows to the oldest (default) org ────────────────────
do $$
declare
  v_org_id uuid;
begin
  select id into v_org_id from hris.organizations order by created_at limit 1;
  if v_org_id is not null then
    update hris.departments set organization_id = v_org_id where organization_id is null;
    update hris.positions   set organization_id = v_org_id where organization_id is null;
  end if;
end $$;

-- ── 3. Make column non-nullable now that it is populated ─────────────────────
-- (safe to run even if some orgs have no departments yet)
alter table hris.departments
  alter column organization_id set not null;

alter table hris.positions
  alter column organization_id set not null;

-- ── 4. Seed default departments for every org that has none ──────────────────
insert into hris.departments (organization_id, name)
select o.id, d.name
from hris.organizations o
cross join (
  values
    ('Human Resources'),
    ('Finance'),
    ('Operations'),
    ('Information Technology'),
    ('Administration')
) as d(name)
where not exists (
  select 1 from hris.departments where organization_id = o.id
)
on conflict do nothing;

-- ── 5. Update RLS policies to be org-scoped ──────────────────────────────────
drop policy if exists "departments_select_all"     on hris.departments;
drop policy if exists "departments_write_admin_hr" on hris.departments;
drop policy if exists "positions_select_all"       on hris.positions;
drop policy if exists "positions_write_admin_hr"   on hris.positions;

-- Departments: select own org
create policy "departments_select_own_org"
  on hris.departments for select
  to authenticated
  using (organization_id = hris.get_my_organization_id());

-- Departments: write (insert/update/delete) admin/hr own org
create policy "departments_insert_admin_hr"
  on hris.departments for insert
  to authenticated
  with check (
    organization_id = hris.get_my_organization_id()
    and hris.get_my_role() in ('admin', 'hr_staff')
  );

create policy "departments_update_admin_hr"
  on hris.departments for update
  to authenticated
  using    (organization_id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'))
  with check (organization_id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'));

create policy "departments_delete_admin_hr"
  on hris.departments for delete
  to authenticated
  using (organization_id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'));

-- Positions: select own org
create policy "positions_select_own_org"
  on hris.positions for select
  to authenticated
  using (organization_id = hris.get_my_organization_id());

-- Positions: write admin/hr own org
create policy "positions_insert_admin_hr"
  on hris.positions for insert
  to authenticated
  with check (
    organization_id = hris.get_my_organization_id()
    and hris.get_my_role() in ('admin', 'hr_staff')
  );

create policy "positions_update_admin_hr"
  on hris.positions for update
  to authenticated
  using    (organization_id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'))
  with check (organization_id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'));

create policy "positions_delete_admin_hr"
  on hris.positions for delete
  to authenticated
  using (organization_id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'));

-- ── 6. Indexes ────────────────────────────────────────────────────────────────
create index if not exists idx_departments_org on hris.departments (organization_id);
create index if not exists idx_positions_org   on hris.positions   (organization_id);
