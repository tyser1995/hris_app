# HRIS App

A full-featured **Human Resource Information System** built with **Flutter** and **Supabase**, designed to support organizations with ~8,000 employees. Supports multi-tenant deployments where a single super admin manages multiple independent organizations, each with its own branding and data.

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Web, Android, iOS) |
| Backend | Supabase (Auth, PostgreSQL, Edge Functions, Realtime, Storage) |
| State Management | Riverpod |
| Routing | GoRouter |
| Data Models | JSON Serializable |

## Modules

| # | Module | Description |
|---|---|---|
| 1 | Employee Management | Full employee records with employment types, contracts, and documents |
| 2 | Attendance Monitoring | Daily time logs with biometric/RFID/mobile/web check-in sources |
| 3 | Shift Scheduling | Regular, broken (split), and flexible schedule support |
| 4 | Leave Management | Multi-level approval flow: Employee → Supervisor → HR |
| 5 | Organization Structure | Departments, positions, and org hierarchy |
| 6 | Payroll Integration | Monthly payroll summary export via edge function |
| 7 | Reports & Analytics | Attendance, leave, contract expiry, and turnover reports |
| 8 | Employee Self-Service | Mobile portal for profile, attendance, and leave |
| 9 | Notification System | Leave approvals, late alerts, contract expiry reminders |
| 10 | Role-Based Access Control | Super Admin, Admin, HR Staff, Department Head, Supervisor, Employee |
| 11 | Settings — ID Management | Dynamic employee code pattern builder with live preview and atomic sequence counter |
| 12 | Settings — Access Management | Per-role permission toggles across all features, managed from the UI |
| 13 | Settings — Branding | Per-organization system title, logo, and primary color with live preview |
| 14 | Settings — Data Management | CRUD for employment types, departments, and leave types — all org-scoped |
| 15 | Super Admin Panel | Manage multiple organizations and their admin accounts from one place |
| 16 | User Management | Invite or create users within an organization |

## Project Structure

```
lib/
├── core/
│   ├── constants/          # AppColors, AppStrings, AppPermissions
│   ├── errors/             # AppException hierarchy, ErrorMapper
│   ├── theme/              # AppTheme (dynamic primary color from org branding)
│   └── utils/              # EmployeeCodeGenerator
├── config/
│   ├── router/             # GoRouter setup, route names
│   └── supabase/           # Supabase client config
├── models/                 # Data models (Freezed + JSON Serializable)
│   ├── company_settings_model.dart   # Org-aware settings (multi-tenant + legacy)
│   ├── organization_model.dart
│   ├── org_user_model.dart
│   ├── employment_type_model.dart    # Dynamic employment type per org
│   └── leave_type_model.dart         # Dynamic leave type per org
├── services/               # Supabase query logic (one file per domain)
│   ├── settings_service.dart
│   ├── organization_service.dart
│   ├── user_management_service.dart
│   ├── permission_service.dart
│   ├── department_service.dart       # Departments + positions (CRUD)
│   ├── employment_type_service.dart  # Employment types CRUD
│   └── leave_type_service.dart       # Leave types CRUD
├── providers/              # Riverpod state providers
│   ├── settings_provider.dart        # companySettingsProvider (auth-aware)
│   ├── organization_provider.dart
│   ├── user_management_provider.dart
│   ├── permission_provider.dart
│   ├── department_provider.dart
│   ├── employment_type_provider.dart
│   └── leave_type_provider.dart
├── mock/                   # Demo/presentation mode (no Supabase required)
│   ├── mock_data_store.dart          # 21 employees, attendance, leave, notifications
│   ├── mock_services.dart            # Service subclasses with in-memory implementations
│   └── mock_overrides.dart           # Riverpod provider override list + fake auth session
├── shared/
│   ├── layouts/            # AdminShell: responsive sidebar + mobile bottom nav
│   └── widgets/            # HrisLoadingWidget, HrisErrorWidget, LoadingOverlay
└── modules/
    ├── auth/               # Login, forgot password
    ├── dashboard/          # Metrics overview, attendance chart
    ├── employee/           # Employee list, detail, form (with auto-code generation)
    ├── attendance/         # Attendance log, check-in/out
    ├── leave/              # Leave requests, approval flow
    ├── scheduling/         # Schedule list and editor
    ├── reports/            # Report generation, payroll export
    ├── notifications/      # Notification center
    ├── self_service/       # Employee-facing portal
    ├── super_admin/        # Organization list, create-admin flow (super_admin only)
    ├── user_management/    # User list, invite/create users
    └── settings/
        ├── settings_screen.dart           # ID Management (pattern + sequence)
        ├── access_management_screen.dart  # Role permission toggles
        ├── branding_screen.dart           # Logo, system title, primary color
        ├── data_management_screen.dart    # Hub: Employment Types, Departments, Leave Types
        ├── employment_types_screen.dart   # CRUD for org-scoped employment types
        ├── departments_data_screen.dart   # CRUD for org-scoped departments
        └── leave_types_screen.dart        # CRUD for org-scoped leave types

supabase/
├── migrations/             # 24 ordered SQL migration files
│   ├── 001_create_roles.sql              # hris schema, user_role enum, user_roles
│   ├── 002–008                           # Core tables: departments, employees, schedules,
│   │                                     # attendance, leave, notifications, documents
│   ├── 009_rls_policies.sql              # RLS policies + helper functions
│   ├── 010_indexes.sql                   # Composite indexes for high-traffic tables
│   ├── 011_create_company_settings.sql   # Singleton settings + hris.next_employee_code()
│   ├── 012_create_permissions.sql        # role_permissions table + seeded defaults
│   ├── 013_seed_demo_data.sql            # 20-employee demo dataset
│   ├── 014_add_branding.sql              # Branding columns on company_settings
│   ├── 015_add_organizations.sql         # super_admin enum value
│   ├── 016_add_organizations.sql         # organizations table, RLS, org-scoped employees
│   ├── 017_user_management.sql           # get_org_users() security-definer function
│   ├── 018_super_admin_setup.sql         # promote_to_super_admin() helper
│   ├── 019_enable_realtime_organizations.sql
│   ├── 020_employment_types.sql          # Dynamic employment_types table; migrates enum → text
│   ├── 021_add_data_management_permission.sql  # Adds data_management permission to role matrix
│   ├── 022_org_scope_departments.sql     # Adds organization_id to departments and positions
│   ├── 023_leave_types.sql               # Dynamic leave_types table; migrates enum → text
│   └── 024_hris_security_fixes.sql       # Fixes auth_users_exposed, security_definer_view,
│                                         # and rls_disabled on hris.roles
├── seeds/
│   └── demo_data.sql       # Demo dataset — gitignored, run manually via SQL Editor
├── functions/              # Edge functions (TypeScript / Deno)
│   ├── compute-attendance/       # Late/OT calculation
│   ├── approve-leave/            # Approval workflow
│   ├── notify-trigger/           # Contract & late alerts
│   ├── payroll-export/           # Monthly payroll data
│   ├── generate-employee-code/   # Atomic sequence increment + code generation
│   ├── create-admin-user/        # Creates org + admin account atomically (super_admin only)
│   ├── create-user/              # Creates a user within an org (admin only)
│   ├── invite-user/              # Sends invitation email to a new user
│   └── delete-organization/      # Deletes org and all associated admin accounts
└── reset_to_hris.sql       # Drops all app objects and clears migration history — gitignored, local use only
```

## Database Schema

All tables and functions live in the **`hris` schema**. The `public` schema is untouched.

### Core tables (all with Row Level Security)

| Table | Description |
|---|---|
| `hris.organizations` | One row per tenant — name, branding, employee code config |
| `hris.user_roles` | Auth UIDs mapped to roles and their organization |
| `hris.employees` | Personnel records (8,000+ employees per org) |
| `hris.departments` / `hris.positions` | Org structure |
| `hris.schedules` / `hris.schedule_details` | Shift configuration |
| `hris.attendance` | Daily logs (~2.9M rows/year), indexed for performance |
| `hris.leave_requests` / `hris.leave_balances` | Leave tracking (leave_type stored as text after migration 023) |
| `hris.notifications` | In-app notifications |
| `hris.employee_documents` | Contract and ID storage |
| `hris.company_settings` | Legacy singleton settings (pre-multi-tenant) |
| `hris.role_permissions` | Per-role feature permission matrix (15 permissions × 5 roles) |
| `hris.employment_types` | Org-scoped employment type list (replaces the old employment_type enum) |
| `hris.leave_types` | Org-scoped leave type list (replaces the old leave_type enum) |

### Database functions

| Function | Description |
|---|---|
| `hris.get_my_role()` | Returns the current user's role |
| `hris.get_my_employee_id()` | Returns the current user's employee UUID |
| `hris.get_my_organization_id()` | Returns the current user's organization UUID |
| `hris.next_employee_code()` | Atomic sequence increment (legacy singleton) |
| `hris.next_org_employee_code(org_id)` | Atomic sequence increment scoped to an org |
| `hris.get_org_users()` | Returns all users in the caller's org (security definer — can read `auth.users`) |
| `hris.promote_to_super_admin(email)` | Promotes a user to super_admin (service role only) |
| `hris.update_updated_at_column()` | Trigger: sets `updated_at = now()` |

## User Roles & Permissions

| Role | Default Access |
|---|---|
| Super Admin | Manages all organizations and their admins — no org-specific data access |
| Admin | Full access within their organization |
| HR Staff | Employees (no delete), attendance, leave approval, reports, settings |
| Department Head | View employees, attendance, leave approval, own-department reports |
| Supervisor | View employees, attendance, leave approval, scheduling |
| Employee | Self-service portal: own attendance, own leave requests |

Permissions are managed in **Settings → Access Management** and stored in `hris.role_permissions`. Toggles apply optimistically in the UI and persist to Supabase in real time.

## Multi-Tenant Architecture

Each organization is isolated by RLS — users can only see and modify data that belongs to their own organization. The `super_admin` role sits above all organizations and can manage them via the Super Admin panel, but cannot access any organization's operational data (employees, attendance, etc.).

Key RLS helpers:
- `hris.get_my_organization_id()` — used in all org-scoped policies
- `hris.get_my_role()` — used for role-based access checks

Branding (logo, primary color, system title) is per-organization and loaded at login. Changes made by an admin propagate to all connected users of the same org in real time via Supabase Realtime.

## Employee Code Generation

Employee IDs are generated from a configurable pattern in **Settings → ID Management**:

| Token | Description | Example |
|---|---|---|
| `YY` | 2-digit year | `26` |
| `YYYY` | 4-digit year | `2026` |
| `MM` | 2-digit month | `03` |
| `DD` | 2-digit day | `13` |
| `###` | 3-digit zero-padded sequence | `001` |
| `####` | 4-digit zero-padded sequence | `0001` |

**Example:** pattern `YY-E###-MM` → `26-E001-03`, `26-E002-03`, ...

Sequence increments are handled atomically by the `generate-employee-code` edge function, which calls `hris.next_org_employee_code()` under a row-level lock to prevent duplicate codes under concurrent employee creation.

## Data Management

Admins and HR Staff can manage reference data per organization under **Settings → Data Management**:

| List | Route | Seeded Defaults |
|---|---|---|
| Employment Types | `/settings/data-management/employment-types` | Regular, Job Order, Contractual, Faculty, Janitorial |
| Departments | `/settings/data-management/departments` | Human Resources, Finance, Operations, IT, Administration |
| Leave Types | `/settings/data-management/leave-types` | Vacation, Sick, Emergency, Maternity, Paternity, Leave Without Pay |

All three lists are org-scoped (isolated by RLS), support full CRUD from the UI, and feed the dropdowns in employee forms and leave requests. The underlying `employment_type` and `leave_type` columns are plain `text` — the old Postgres enums were removed in migrations 020 and 023 respectively.

## Security

The `hris` schema is hardened against the Supabase security linter advisories:

| Advisory | Object | Fix applied (migration 024) |
|---|---|---|
| `auth_users_exposed` | `hris.super_admins` view | Revoked access from `anon`, `authenticated`, and `public`; only `service_role` retains SELECT |
| `security_definer_view` | `hris.super_admins` view | Recreated with `WITH (security_invoker = on)` — runs under caller's privileges, not the view owner's |
| `rls_disabled_in_public` | `hris.roles` | RLS enabled; authenticated users may SELECT, no write policies |

## Error Handling

All service methods map raw Supabase/network errors to typed `AppException` subtypes via `ErrorMapper`:

| Postgres Code | Exception Type | Meaning |
|---|---|---|
| `42501` | `PermissionException` | RLS policy violation |
| `PGRST116` | `NotFoundException` | No row found (`.single()` with 0 results) |
| `23505` | `AppException` | Duplicate unique value |
| `23503` | `AppException` | Foreign key violation |
| `PGRST205` | *(graceful fallback)* | Table not in schema cache |
| Network error | `NetworkException` | No internet connection |

## Getting Started

### Prerequisites

- Flutter SDK
- Supabase project (create at [supabase.com](https://supabase.com))
- Supabase CLI (`npm install -g supabase`)

### Demo Mode (no Supabase required)

Run the app instantly with pre-loaded mock data — no Supabase project needed:

```bash
flutter run -d chrome --dart-define=ENV_FILE=.env.demo
```

The demo loads 21 employees across 4 departments with realistic attendance, leave, and notification data. All reads and writes work in-memory for the duration of the session.

**Demo data highlights:**
- 15 present, 2 late, 3 absent, 1 on leave (today)
- 2 employees with contracts expiring within 30 days
- 6 leave requests in various approval states
- 4 unread notifications (contract expiry + pending leave)
- Logged in as Admin with full access

### Setup (with real Supabase)

1. **Clone and install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure environment**

   Copy the example env file and fill in your Supabase credentials:
   ```bash
   cp .env.example .env
   ```
   ```
   SUPABASE_URL=https://your-project-ref.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
   MOCK_DATA=false
   ```

3. **Link your Supabase project**
   ```bash
   supabase link --project-ref your-project-ref
   ```

4. **Run database migrations**

   Fresh project:
   ```bash
   supabase db push --password "your-db-password"
   ```

   If you need to reset an existing database (e.g., tables ended up in the wrong schema), run `supabase/reset_to_hris.sql` in the Supabase SQL Editor first (file is gitignored — local use only), then push:
   ```bash
   supabase db push --password "your-db-password" --debug
   ```

5. **Create the first super admin**

   After migrations, promote your account to `super_admin` via the Supabase SQL Editor:
   ```sql
   SELECT hris.promote_to_super_admin('your-email@example.com');
   ```

   This requires the user to already exist in Supabase Auth (create them via Dashboard → Authentication → Users first).

6. **Deploy edge functions**
   ```bash
   supabase functions deploy compute-attendance
   supabase functions deploy approve-leave
   supabase functions deploy notify-trigger
   supabase functions deploy payroll-export
   supabase functions deploy generate-employee-code
   supabase functions deploy create-admin-user
   supabase functions deploy create-user
   supabase functions deploy invite-user
   supabase functions deploy delete-organization
   ```

7. **(Optional) Seed demo data**

   `supabase/seeds/demo_data.sql` is gitignored and not included in the repository. If you have the file locally, run it in the Supabase SQL Editor to populate the database with 20 employees, 2 weeks of attendance history, leave requests, and notifications.

8. **Run the app**
   ```bash
   # Web (HR Dashboard)
   flutter run -d chrome

   # Android
   flutter run -d android

   # iOS
   flutter run -d ios
   ```

### Code Generation

After modifying any model files, regenerate the JSON Serializable code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Scaling Notes

Designed for 8,000 employees (~2.9M attendance rows/year):

- All high-traffic tables have composite indexes (`010_indexes.sql`)
- Employee list uses cursor-based pagination (50 per page)
- Dashboard metrics run parallel count queries
- Attendance dashboard uses Supabase Realtime streaming filtered to today's records only
- Attendance computation (late/OT) runs server-side via edge function, not on the client
- Employee code sequence uses `UPDATE ... RETURNING` under a row-level lock to prevent race conditions under concurrent inserts
- All tables and functions are scoped to the `hris` schema, keeping the `public` schema clean
- Multi-tenant isolation enforced at the DB layer via RLS — no application-level filtering required
