-- 024_hris_security_fixes.sql
-- Fixes three EXTERNAL/ERROR security advisories for the hris schema:
--
--   1. auth_users_exposed      — super_admins view accessible to anon role
--   2. security_definer_view   — super_admins view runs as owner (postgres)
--                                because it queries auth.users
--   3. rls_disabled_in_public  — hris.roles table has no RLS

set search_path to hris, extensions;

-- ── Fix 1 & 2 : super_admins view ────────────────────────────────────────────
-- Drop and recreate the view with SECURITY INVOKER so it runs under the
-- caller's privileges (not the view owner's). Also explicitly revoke from
-- every non-service role, including anon which was missed previously.

drop view if exists hris.super_admins;

create view hris.super_admins
  with (security_invoker = on)   -- caller must have access to auth.users
as
select
  ur.user_id,
  au.email,
  ur.created_at as role_assigned_at
from hris.user_roles ur
join auth.users au on au.id = ur.user_id
where ur.role = 'super_admin';

-- Lock down to service_role only (anon + authenticated + public all revoked)
revoke all on hris.super_admins from public, anon, authenticated;
grant  select on hris.super_admins to service_role;

-- ── Fix 3 : enable RLS on hris.roles ─────────────────────────────────────────
-- The roles table is a static reference list (admin, hr_staff, etc.).
-- All authenticated users should be able to read it; writes are prohibited
-- through the API (no insert/update/delete policy).

alter table hris.roles enable row level security;

create policy "roles_select_authenticated"
  on hris.roles for select
  to authenticated
  using (true);
