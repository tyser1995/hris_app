-- 018_super_admin_setup.sql
-- Provides a helper function to promote any existing auth.users account to
-- super_admin. Run this after creating the user via Supabase Dashboard or CLI.
--
-- Usage:
--   1. Create the user in Supabase Dashboard → Authentication → Users → Add user
--      OR via CLI: supabase auth add-user --email sa@example.com
--   2. Call this function from the SQL editor:
--        SELECT hris.promote_to_super_admin('sa@example.com');
--
-- To demote back to a regular admin (swap for any user_role value):
--   UPDATE hris.user_roles SET role = 'admin' WHERE user_id = '<uuid>';

set search_path to hris, extensions;

-- ── promote_to_super_admin ────────────────────────────────────────────────────
create or replace function hris.promote_to_super_admin(p_email text)
returns text language plpgsql security definer
set search_path = hris, public, extensions
as $$
declare
  v_user_id uuid;
begin
  -- Resolve email → UUID from auth.users (requires service role or security definer)
  select id into v_user_id
  from auth.users
  where lower(email) = lower(p_email)
  limit 1;

  if v_user_id is null then
    raise exception 'No auth user found with email: %', p_email;
  end if;

  -- Upsert the role (safe to run multiple times)
  insert into hris.user_roles (user_id, role)
  values (v_user_id, 'super_admin')
  on conflict (user_id)
  do update set role = 'super_admin';

  return format('OK — user %s (%s) is now super_admin', p_email, v_user_id);
end;
$$;

-- Only service-role / postgres can call this directly
revoke execute on function hris.promote_to_super_admin(text) from public, authenticated;
grant  execute on function hris.promote_to_super_admin(text) to service_role;

-- ── list_super_admins ─────────────────────────────────────────────────────────
-- Convenience view to see who currently has super_admin role.
create or replace view hris.super_admins as
select
  ur.user_id,
  au.email,
  ur.created_at as role_assigned_at
from hris.user_roles ur
join auth.users au on au.id = ur.user_id
where ur.role = 'super_admin';

-- Restrict to service_role so application code cannot read it through the API
revoke all on hris.super_admins from public, authenticated;
grant  select on hris.super_admins to service_role;
