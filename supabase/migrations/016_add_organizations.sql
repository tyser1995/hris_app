-- 016_add_organizations.sql
-- Step 2 of 2: Organizations table, RLS, and helper functions.
-- Runs after 015 has committed the super_admin enum value.

set search_path to hris, extensions;

-- ── 1. Organizations table ────────────────────────────────────────────────────
create table hris.organizations (
  id                     uuid    primary key default gen_random_uuid(),
  name                   text    not null,
  system_title           text,
  primary_color          text,
  logo_url               text,
  employee_code_pattern  text    not null default 'YY-###',
  employee_code_sequence integer not null default 0
                           check (employee_code_sequence >= 0),
  created_at             timestamptz default now(),
  updated_at             timestamptz default now()
);

create trigger organizations_updated_at
  before update on hris.organizations
  for each row execute function hris.update_updated_at_column();

-- ── 2. Link users and employees to their organization ─────────────────────────
alter table hris.user_roles
  add column if not exists organization_id uuid references hris.organizations(id) on delete set null;

alter table hris.employees
  add column if not exists organization_id uuid references hris.organizations(id) on delete set null;

-- ── 3. Seed default organization from existing company_settings ───────────────
do $$
declare
  v_org_id uuid;
begin
  insert into hris.organizations (
    name, system_title, primary_color, logo_url,
    employee_code_pattern, employee_code_sequence
  )
  select
    coalesce(company_name, 'My Organization'),
    system_title, primary_color, logo_url,
    employee_code_pattern, employee_code_sequence
  from hris.company_settings
  where id = 'singleton'
  returning id into v_org_id;

  if v_org_id is null then
    insert into hris.organizations (name) values ('My Organization')
    returning id into v_org_id;
  end if;

  -- Link all existing users and employees to the default org
  update hris.user_roles set organization_id = v_org_id where organization_id is null;
  update hris.employees  set organization_id = v_org_id where organization_id is null;
end $$;

-- ── 4. Helper: current user's organization id ─────────────────────────────────
create or replace function hris.get_my_organization_id()
returns uuid language sql security definer stable
set search_path = hris, extensions
as $$
  select organization_id from hris.user_roles
  where user_id = (select auth.uid()) limit 1;
$$;

grant execute on function hris.get_my_organization_id() to authenticated;

-- ── 5. next_org_employee_code(org_id) ────────────────────────────────────────
create or replace function hris.next_org_employee_code(p_org_id uuid)
returns text language plpgsql security definer
set search_path = hris, extensions
as $$
declare
  v_pattern  text;
  v_sequence integer;
  v_code     text;
  i          integer;
begin
  update hris.organizations
     set employee_code_sequence = employee_code_sequence + 1,
         updated_at = now()
   where id = p_org_id
  returning employee_code_pattern, employee_code_sequence
       into v_pattern, v_sequence;

  if not found then
    raise exception 'Organization % not found', p_org_id;
  end if;

  v_code := v_pattern;
  v_code := replace(v_code, 'YYYY', to_char(now(), 'YYYY'));
  v_code := replace(v_code, 'YY',   to_char(now(), 'YY'));
  v_code := replace(v_code, 'MM',   to_char(now(), 'MM'));
  v_code := replace(v_code, 'DD',   to_char(now(), 'DD'));

  for i in reverse 8..1 loop
    v_code := replace(v_code, repeat('#', i), lpad(v_sequence::text, i, '0'));
  end loop;

  return v_code;
end;
$$;

grant execute on function hris.next_org_employee_code(uuid) to authenticated;

-- ── 6. RLS on organizations ───────────────────────────────────────────────────
alter table hris.organizations enable row level security;

-- super_admin manages all orgs
create policy "orgs_super_admin"
  on hris.organizations for all
  to authenticated
  using  (hris.get_my_role() = 'super_admin')
  with check (hris.get_my_role() = 'super_admin');

-- others read their own org
create policy "orgs_select_own"
  on hris.organizations for select
  to authenticated
  using (id = hris.get_my_organization_id());

-- admin / hr_staff update their own org
create policy "orgs_update_admin_hr"
  on hris.organizations for update
  to authenticated
  using    (id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'))
  with check (id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'));

-- ── 7. Extend existing policies: let super_admin read user_roles ──────────────
drop policy if exists "user_roles_select_own" on hris.user_roles;
create policy "user_roles_select"
  on hris.user_roles for select
  to authenticated
  using (user_id = (select auth.uid()) or hris.get_my_role() = 'super_admin');

-- super_admin can manage user_roles (assign roles to new admins)
create policy "user_roles_insert_super_admin"
  on hris.user_roles for insert
  to authenticated
  with check (hris.get_my_role() = 'super_admin');

-- ── 8. Org-scope employees: users only see employees in their org ─────────────
drop policy if exists "employees_select" on hris.employees;
create policy "employees_select"
  on hris.employees for select
  to authenticated
  using (
    hris.get_my_role() = 'super_admin'
    or (
      organization_id = hris.get_my_organization_id()
      and (
        hris.get_my_role() in ('admin', 'hr_staff', 'department_head')
        or id = hris.get_my_employee_id()
        or supervisor_id = hris.get_my_employee_id()
      )
    )
  );

drop policy if exists "employees_insert_admin_hr" on hris.employees;
create policy "employees_insert_admin_hr"
  on hris.employees for insert
  to authenticated
  with check (
    hris.get_my_role() in ('admin', 'hr_staff')
    and organization_id = hris.get_my_organization_id()
  );

drop policy if exists "employees_update_admin_hr" on hris.employees;
create policy "employees_update_admin_hr"
  on hris.employees for update
  to authenticated
  using    (hris.get_my_role() in ('admin', 'hr_staff') and organization_id = hris.get_my_organization_id())
  with check (hris.get_my_role() in ('admin', 'hr_staff') and organization_id = hris.get_my_organization_id());

drop policy if exists "employees_delete_admin" on hris.employees;
create policy "employees_delete_admin"
  on hris.employees for delete
  to authenticated
  using (hris.get_my_role() in ('admin', 'super_admin') and organization_id = hris.get_my_organization_id());
