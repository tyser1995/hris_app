-- 021_add_data_management_permission.sql
-- Adds the settings.data_management permission to the role_permissions table.
-- Granted to admin and hr_staff; denied for all other roles.

set search_path to hris, extensions;

insert into hris.role_permissions (role, permission_key, granted) values
  ('admin',           'settings.data_management', true),
  ('hr_staff',        'settings.data_management', true),
  ('department_head', 'settings.data_management', false),
  ('supervisor',      'settings.data_management', false),
  ('employee',        'settings.data_management', false)
on conflict (role, permission_key) do update set granted = excluded.granted;
