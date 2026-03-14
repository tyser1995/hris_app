-- 019_enable_realtime_organizations.sql
-- Enables Supabase Realtime for hris.organizations so that branding/settings
-- changes made by one user (admin) are immediately broadcast to all other
-- connected clients in the same organization.
--
-- Clients subscribe to UPDATE events on hris.organizations and call
-- ref.invalidate(companySettingsProvider) on receipt — which triggers a
-- fresh RLS-filtered fetch, so each user sees only their own org's data.

set search_path to hris, extensions;

-- Add the table to the Realtime publication.
-- supabase_realtime is the default publication used by Supabase Realtime.
alter publication supabase_realtime add table hris.organizations;

-- REPLICA IDENTITY FULL lets Realtime include old + new row data in the
-- change event (useful for debugging; not strictly required for invalidation).
alter table hris.organizations replica identity full;
