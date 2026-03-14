-- 015_add_organizations.sql
-- Step 1 of 2: Add super_admin enum value.
-- Must be committed in its own transaction before 016 can reference it.

set search_path to hris, extensions;

alter type hris.user_role add value if not exists 'super_admin';
