-- 014_add_branding.sql
-- Adds branding configuration to company_settings:
--   system_title  – displayed in the sidebar and browser tab
--   primary_color – hex color string (e.g. '#2563EB')
--   logo_url      – public URL to the organization logo image

alter table hris.company_settings
  add column if not exists system_title  text,
  add column if not exists primary_color text,
  add column if not exists logo_url      text;
