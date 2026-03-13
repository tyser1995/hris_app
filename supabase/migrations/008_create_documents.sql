-- 008_create_documents.sql

create type document_type as enum ('contract', 'id', 'certificate', 'other');

create table employee_documents (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references employees(id) on delete cascade not null,
  document_type document_type not null,
  file_name text not null,
  file_path text not null,   -- Supabase Storage path
  uploaded_by uuid references auth.users(id),
  created_at timestamptz default now()
);
