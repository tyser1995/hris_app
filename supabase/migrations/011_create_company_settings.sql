-- 011_create_company_settings.sql
-- Company-level configuration: employee code pattern + auto-increment sequence.

-- ── Table ─────────────────────────────────────────────────────────────────────

create table company_settings (
  id                      text primary key default 'singleton',
  employee_code_pattern   text not null default 'YY-###',
  employee_code_sequence  integer not null default 0
                            check (employee_code_sequence >= 0),
  company_name            text,
  updated_at              timestamptz default now()
);

-- Seed the one-and-only row
insert into company_settings (id)
values ('singleton')
on conflict (id) do nothing;

-- Auto-update updated_at on every write
create trigger company_settings_updated_at
  before update on company_settings
  for each row execute function hris.update_updated_at_column();

-- ── RLS ───────────────────────────────────────────────────────────────────────

alter table company_settings enable row level security;

-- Any authenticated user can read settings (pattern preview, etc.)
create policy "company_settings_select" on company_settings
  for select to authenticated using (true);

-- Only admin / hr_staff may change settings
create policy "company_settings_write_admin_hr" on company_settings
  for all to authenticated
  using    (get_my_role() in ('admin', 'hr_staff'))
  with check (get_my_role() in ('admin', 'hr_staff'));

-- ── DB function: next_employee_code() ─────────────────────────────────────────
--
-- Atomically increments employee_code_sequence and returns the generated code.
-- Runs inside the caller's transaction, so concurrent calls are serialised by
-- the row-level update lock — no duplicate codes.
--
-- Token substitution rules (identical to the Dart EmployeeCodeGenerator):
--   YYYY  →  4-digit year        (e.g. 2026)
--   YY    →  2-digit year        (e.g. 26)
--   MM    →  2-digit month       (e.g. 03)
--   DD    →  2-digit day         (e.g. 15)
--   ###   →  zero-padded seq, width = number of '#' chars  (e.g. 001)

create or replace function hris.next_employee_code()
returns text
language plpgsql
security definer   -- runs as owner so RLS is bypassed for the update
set search_path = hris, extensions
as $$
declare
  v_pattern  text;
  v_sequence integer;
  v_code     text;
  i          integer;
begin
  -- Increment sequence and grab the new value + pattern in one shot.
  -- The UPDATE acquires a row lock, serialising concurrent calls.
  update company_settings
     set employee_code_sequence = employee_code_sequence + 1,
         updated_at = now()
   where id = 'singleton'
  returning employee_code_pattern, employee_code_sequence
       into v_pattern, v_sequence;

  if not found then
    raise exception 'company_settings singleton row missing — run migration 011';
  end if;

  v_code := v_pattern;

  -- Date tokens: replace YYYY before YY to prevent double-substitution
  v_code := replace(v_code, 'YYYY', to_char(now(), 'YYYY'));
  v_code := replace(v_code, 'YY',   to_char(now(), 'YY'));
  v_code := replace(v_code, 'MM',   to_char(now(), 'MM'));
  v_code := replace(v_code, 'DD',   to_char(now(), 'DD'));

  -- Sequence token: iterate longest-first so '######' isn't partially matched
  -- by shorter patterns (handles up to 8 consecutive '#' chars).
  for i in reverse 8..1 loop
    v_code := replace(v_code, repeat('#', i), lpad(v_sequence::text, i, '0'));
  end loop;

  return v_code;
end;
$$;

-- Grant execute to authenticated users so the edge function (service role)
-- and direct RPC calls both work.
grant execute on function hris.next_employee_code() to authenticated;
