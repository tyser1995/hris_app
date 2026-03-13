# HRIS App

A full-featured **Human Resource Information System** built with **Flutter** and **Supabase**, designed to support organizations with ~8,000 employees.

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Web, Android, iOS) |
| Backend | Supabase (Auth, PostgreSQL, Edge Functions, Realtime, Storage) |
| State Management | Riverpod |
| Routing | GoRouter |
| Data Models | Freezed + JSON Serializable |

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
| 10 | Role-Based Access Control | Admin, HR Staff, Department Head, Supervisor, Employee |
| 11 | Settings — ID Management | Dynamic employee code pattern builder with live preview and atomic sequence counter |
| 12 | Settings — Access Management | Per-role permission toggles across all features, managed from the UI |

## Project Structure

```
lib/
├── core/
│   ├── config/             # AppConfig (isMockMode flag)
│   ├── constants/          # AppColors, AppStrings, AppPermissions (permission registry)
│   ├── errors/             # AppException hierarchy, ErrorMapper (PostgrestException → typed errors)
│   └── utils/              # EmployeeCodeGenerator (pattern token substitution)
├── config/
│   ├── router/             # GoRouter setup, route names
│   └── supabase/           # Supabase client config
├── models/                 # Freezed + JSON Serializable data models
│   └── company_settings_model.dart
├── services/               # Supabase query logic (one file per domain)
│   ├── settings_service.dart
│   └── permission_service.dart
├── providers/              # Riverpod state providers
│   ├── settings_provider.dart
│   └── permission_provider.dart   # StateNotifier with optimistic toggle updates
├── mock/                   # Demo/presentation mode (no Supabase required)
│   ├── mock_data_store.dart        # 21 employees, attendance, leave, notifications
│   ├── mock_services.dart          # Service subclasses with in-memory implementations
│   └── mock_overrides.dart         # Riverpod provider override list + fake auth session
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
    └── settings/
        ├── settings_screen.dart           # ID Management (pattern + sequence)
        └── access_management_screen.dart  # Role permission toggles

supabase/
├── migrations/             # 13 ordered SQL migration files
│   ├── 001_create_roles.sql              # hris schema, search_path, user_role enum, user_roles table
│   ├── 002–008                           # Core tables: departments, employees, schedules, attendance, leave, notifications, documents
│   ├── 009_rls_policies.sql              # RLS policies + hris.get_my_role() / hris.get_my_employee_id()
│   ├── 010_indexes.sql                   # Composite indexes for high-traffic tables
│   ├── 011_create_company_settings.sql   # Singleton settings row + hris.next_employee_code()
│   ├── 012_create_permissions.sql        # role_permissions table + seeded defaults per role
│   └── 013_seed_demo_data.sql            # 20-employee demo dataset (attendance, leave, notifications)
├── seeds/
│   └── demo_data.sql       # Same dataset as 013 — run manually via SQL Editor
├── functions/              # Edge functions (TypeScript / Deno)
│   ├── compute-attendance/       # Late/OT calculation
│   ├── approve-leave/            # Approval workflow
│   ├── notify-trigger/           # Contract & late alerts
│   ├── payroll-export/           # Monthly payroll data
│   └── generate-employee-code/   # Atomic sequence increment + code generation
└── reset_to_hris.sql       # Drops all app objects from public + hris and clears migration history
```

## Database Schema

All tables and functions live in the **`hris` schema**. The `public` schema is untouched.

Core tables with Row Level Security (RLS):

- `hris.user_roles` — Auth and role assignments
- `hris.employees` — Personnel records (8,000+ employees)
- `hris.departments` / `hris.positions` — Org structure
- `hris.schedules` / `hris.schedule_details` — Shift configuration
- `hris.attendance` — Daily logs (~2.9M rows/year), indexed for performance
- `hris.leave_requests` / `hris.leave_balances` — Leave tracking
- `hris.notifications` — In-app notifications
- `hris.employee_documents` — Contract and ID storage
- `hris.company_settings` — Singleton row: employee code pattern + sequence counter
- `hris.role_permissions` — Per-role feature permission matrix (15 permissions × 5 roles)

Database functions (all in `hris` schema):

| Function | Description |
|---|---|
| `hris.get_my_role()` | Returns the current user's role from `user_roles` |
| `hris.get_my_employee_id()` | Returns the current user's employee UUID |
| `hris.next_employee_code()` | Atomically increments sequence and returns generated code |
| `hris.update_updated_at_column()` | Trigger function: sets `updated_at = now()` |
| `hris.set_updated_at()` | Trigger function: sets `updated_at = now()` on `role_permissions` |

## User Roles & Permissions

| Role | Default Access |
|---|---|
| Admin | Full system access — permissions cannot be restricted |
| HR Staff | Employees (no delete), attendance, leave approval, reports, settings |
| Department Head | View employees, attendance, leave approval, own-department reports |
| Supervisor | View employees, attendance, leave approval, scheduling |
| Employee | Self-service portal: own attendance, own leave requests |

Permissions are managed in **Settings → Access Management** and stored in the `hris.role_permissions` table. Toggles apply optimistically in the UI and persist to Supabase in real time.

## Employee Code Generation

Employee IDs are generated from a configurable pattern defined in **Settings → ID Management**:

| Token | Description | Example |
|---|---|---|
| `YY` | 2-digit year | `26` |
| `YYYY` | 4-digit year | `2026` |
| `MM` | 2-digit month | `03` |
| `DD` | 2-digit day | `13` |
| `###` | 3-digit zero-padded sequence | `001` |
| `####` | 4-digit zero-padded sequence | `0001` |

**Example:** pattern `YY-E###-MM` → `26-E001-03`, `26-E002-03`, ...

Sequence increments are handled atomically by the `generate-employee-code` edge function, which calls `hris.next_employee_code()` — a Postgres function that runs `UPDATE ... RETURNING` under a row-level lock — preventing duplicate codes under concurrent employee creation.

## Error Handling

All service methods map raw Supabase/network errors to typed `AppException` subtypes via `ErrorMapper`:

| Postgres Code | Exception Type | Meaning |
|---|---|---|
| `42501` | `PermissionException` | RLS policy violation |
| `PGRST116` | `NotFoundException` | No row found |
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
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   MOCK_DATA=false
   ```

3. **Link your Supabase project**
   ```bash
   supabase link --project-ref your-project-ref
   ```

4. **Run database migrations**

   If this is a fresh project, push all migrations:
   ```bash
   supabase db push --password "your-db-password"
   ```

   If you need to reset an existing database (e.g., tables ended up in the wrong schema), run `supabase/reset_to_hris.sql` in the Supabase SQL Editor first, then push:
   ```bash
   supabase db push --password "your-db-password" --debug
   ```

5. **Deploy edge functions**
   ```bash
   supabase functions deploy compute-attendance --project-ref your-project-ref
   supabase functions deploy approve-leave --project-ref your-project-ref
   supabase functions deploy notify-trigger --project-ref your-project-ref
   supabase functions deploy payroll-export --project-ref your-project-ref
   supabase functions deploy generate-employee-code --project-ref your-project-ref
   ```

6. **(Optional) Seed demo data**

   Run `supabase/seeds/demo_data.sql` in the Supabase SQL Editor to populate the database with 20 employees, 2 weeks of attendance history, leave requests, and notifications.

   > The seed script requires `devresty2024@gmail.com` to exist in Supabase Auth. Create the user in the Supabase Dashboard → Authentication → Users → Add user, then the seed will automatically insert the admin role and employee record.

7. **Run the app**
   ```bash
   # Web (HR Dashboard)
   flutter run -d chrome

   # Android
   flutter run -d android

   # iOS
   flutter run -d ios
   ```

### Code Generation

After modifying any model files, regenerate the Freezed/JSON code:
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
