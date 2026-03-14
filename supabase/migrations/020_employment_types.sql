-- 020_employment_types.sql
-- Replace the hardcoded employment_type ENUM with a managed table so
-- each organization can define its own employee types (Regular, Faculty, etc.)

set search_path to hris, extensions;

-- ── 1. Managed employment_types table ────────────────────────────────────────
create table hris.employment_types (
  id              uuid        primary key default gen_random_uuid(),
  organization_id uuid        references hris.organizations(id) on delete cascade,
  name            text        not null,
  created_at      timestamptz default now(),
  updated_at      timestamptz default now(),
  unique (organization_id, name)
);

create trigger employment_types_updated_at
  before update on hris.employment_types
  for each row execute function hris.update_updated_at_column();

-- ── 2. Seed one default set per existing organization ─────────────────────────
insert into hris.employment_types (organization_id, name)
select o.id, t.name
from hris.organizations o
cross join (
  values ('Regular'), ('Job Order'), ('Contractual'), ('Faculty'), ('Janitorial')
) as t(name);

-- ── 3. RLS ────────────────────────────────────────────────────────────────────
alter table hris.employment_types enable row level security;

-- Any user can read their org's types
create policy "employment_types_select"
  on hris.employment_types for select
  to authenticated
  using (
    organization_id = hris.get_my_organization_id()
    or hris.get_my_role() = 'super_admin'
  );

-- Admin / hr_staff manage their org's types; super_admin manages all
create policy "employment_types_insert"
  on hris.employment_types for insert
  to authenticated
  with check (
    (organization_id = hris.get_my_organization_id()
      and hris.get_my_role() in ('admin', 'hr_staff'))
    or hris.get_my_role() = 'super_admin'
  );

create policy "employment_types_update"
  on hris.employment_types for update
  to authenticated
  using (
    (organization_id = hris.get_my_organization_id()
      and hris.get_my_role() in ('admin', 'hr_staff'))
    or hris.get_my_role() = 'super_admin'
  )
  with check (
    (organization_id = hris.get_my_organization_id()
      and hris.get_my_role() in ('admin', 'hr_staff'))
    or hris.get_my_role() = 'super_admin'
  );

create policy "employment_types_delete"
  on hris.employment_types for delete
  to authenticated
  using (
    (organization_id = hris.get_my_organization_id()
      and hris.get_my_role() in ('admin', 'hr_staff'))
    or hris.get_my_role() = 'super_admin'
  );

-- ── 4. Migrate employees.employment_type: ENUM → TEXT ─────────────────────────
-- Add a temporary text column, copy + convert values, then swap.
alter table hris.employees add column employment_type_new text;

update hris.employees
  set employment_type_new = case employment_type::text
    when 'regular'     then 'Regular'
    when 'job_order'   then 'Job Order'
    when 'contractual' then 'Contractual'
    when 'faculty'     then 'Faculty'
    when 'janitorial'  then 'Janitorial'
    else initcap(replace(employment_type::text, '_', ' '))
  end;

alter table hris.employees drop column employment_type;
alter table hris.employees rename column employment_type_new to employment_type;
alter table hris.employees alter column employment_type set not null;
alter table hris.employees alter column employment_type set default 'Regular';

-- ── 5. Drop the old enum type ──────────────────────────────────────────────────
drop type if exists hris.employment_type;

-- ── 6. Rebuild index on the new text column ───────────────────────────────────
drop index if exists idx_employees_employment_type;
create index idx_employees_employment_type on hris.employees(employment_type);
