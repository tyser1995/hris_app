-- 020_employment_types.sql
-- Creates a dynamic employment_types table per organization.
-- Seeds defaults for every existing org, then migrates employees.employment_type
-- from the hris.employment_type ENUM to plain TEXT.

set search_path to hris, extensions;

-- ── 1. Create employment_types table ──────────────────────────────────────────
create table hris.employment_types (
  id              uuid        primary key default gen_random_uuid(),
  organization_id uuid        not null references hris.organizations(id) on delete cascade,
  name            text        not null,
  created_at      timestamptz default now(),
  unique (organization_id, name)
);

-- ── 2. Seed default types for every existing organization ─────────────────────
insert into hris.employment_types (organization_id, name)
select o.id, t.name
from hris.organizations o
cross join (
  values
    ('Regular'),
    ('Job Order'),
    ('Contractual'),
    ('Faculty'),
    ('Janitorial')
) as t(name)
on conflict (organization_id, name) do nothing;

-- ── 3. RLS ────────────────────────────────────────────────────────────────────
alter table hris.employment_types enable row level security;

-- All authenticated users in the same org can view
create policy "employment_types_select_own_org"
  on hris.employment_types for select
  to authenticated
  using (organization_id = hris.get_my_organization_id());

-- Admin / HR Staff can insert
create policy "employment_types_insert_admin_hr"
  on hris.employment_types for insert
  to authenticated
  with check (
    organization_id = hris.get_my_organization_id()
    and hris.get_my_role() in ('admin', 'hr_staff')
  );

-- Admin / HR Staff can update
create policy "employment_types_update_admin_hr"
  on hris.employment_types for update
  to authenticated
  using    (organization_id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'))
  with check (organization_id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'));

-- Admin / HR Staff can delete
create policy "employment_types_delete_admin_hr"
  on hris.employment_types for delete
  to authenticated
  using (organization_id = hris.get_my_organization_id() and hris.get_my_role() in ('admin', 'hr_staff'));

-- ── 4. Migrate employees.employment_type from ENUM to TEXT ────────────────────
-- Add a temporary column to hold the new text value
alter table hris.employees add column if not exists employment_type_text text;

-- Copy and convert enum values to display names
update hris.employees set employment_type_text = case employment_type::text
  when 'regular'     then 'Regular'
  when 'job_order'   then 'Job Order'
  when 'contractual' then 'Contractual'
  when 'faculty'     then 'Faculty'
  when 'janitorial'  then 'Janitorial'
  else initcap(replace(employment_type::text, '_', ' '))
end;

-- Drop the old enum column and rename the text column
alter table hris.employees drop column employment_type;
alter table hris.employees rename column employment_type_text to employment_type;

-- Default for new rows
alter table hris.employees alter column employment_type set default 'Regular';

-- ── 5. Drop the old enum type (no longer referenced) ─────────────────────────
drop type if exists hris.employment_type;

-- ── 6. Index ──────────────────────────────────────────────────────────────────
create index if not exists idx_employment_types_org
  on hris.employment_types (organization_id);
