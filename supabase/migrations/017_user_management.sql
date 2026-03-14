-- 017_user_management.sql
-- Expose org users to admins via a security-definer function
-- that can join into auth.users (otherwise inaccessible via PostgREST).

set search_path to hris, extensions;

-- ── get_org_users(): returns all users visible to the caller ──────────────────
create or replace function hris.get_org_users()
returns table(
  user_id            uuid,
  email              text,
  role               hris.user_role,
  organization_id    uuid,
  organization_name  text,
  created_at         timestamptz,
  email_confirmed_at timestamptz,
  last_sign_in_at    timestamptz
)
language sql security definer stable
set search_path = hris, extensions
as $$
  select
    ur.user_id,
    au.email,
    ur.role,
    ur.organization_id,
    o.name  as organization_name,
    au.created_at,
    au.email_confirmed_at,
    au.last_sign_in_at
  from hris.user_roles ur
  join auth.users       au on au.id = ur.user_id
  left join hris.organizations o  on o.id  = ur.organization_id
  where
    hris.get_my_role() = 'super_admin'
    or ur.organization_id = hris.get_my_organization_id();
$$;

grant execute on function hris.get_org_users() to authenticated;
