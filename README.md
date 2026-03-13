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

## Project Structure

```
lib/
├── core/               # Constants, utilities, error types
├── config/             # GoRouter, Supabase client config
├── models/             # Freezed data models
├── services/           # Supabase query logic
├── providers/          # Riverpod state providers
├── shared/             # Responsive layout shell, shared widgets
└── modules/
    ├── auth/           # Login, forgot password
    ├── dashboard/      # Metrics overview, attendance chart
    ├── employee/       # Employee list, detail, form
    ├── attendance/     # Attendance log, check-in/out
    ├── leave/          # Leave requests, approval flow
    ├── scheduling/     # Schedule list and editor
    ├── reports/        # Report generation, payroll export
    ├── notifications/  # Notification center
    └── self_service/   # Employee-facing portal

supabase/
├── migrations/         # 10 ordered SQL migration files
└── functions/          # Edge functions (TypeScript/Deno)
    ├── compute-attendance/   # Late/OT calculation
    ├── approve-leave/        # Approval workflow
    ├── notify-trigger/       # Contract & late alerts
    └── payroll-export/       # Monthly payroll data
```

## Database Schema

Core tables with Row Level Security (RLS):

- `users` / `user_roles` — Auth and role assignments
- `employees` — Personnel records (8,000+ employees)
- `departments` / `positions` — Org structure
- `schedules` / `schedule_details` — Shift configuration
- `attendance` — Daily logs (~2.9M rows/year), indexed for performance
- `leave_requests` / `leave_balances` — Leave tracking
- `notifications` — In-app notifications
- `employee_documents` — Contract and ID storage

## User Roles

| Role | Access |
|---|---|
| Admin | Full system access |
| HR Staff | Employee management, leave approval, reports |
| Department Head | View department data, leave approval |
| Supervisor | Team attendance monitoring, leave approval |
| Employee | Self-service portal only |

## Getting Started

### Prerequisites

- Flutter SDK
- Supabase project (create at [supabase.com](https://supabase.com))

### Setup

1. **Clone and install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure environment**

   The `.env` file at the project root already contains the Supabase credentials:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

3. **Run database migrations**

   In your Supabase project SQL editor, run the migration files in order:
   ```
   supabase/migrations/001_create_roles.sql
   supabase/migrations/002_create_departments_positions.sql
   ...through...
   supabase/migrations/010_indexes.sql
   ```

4. **Deploy edge functions**
   ```bash
   supabase functions deploy compute-attendance
   supabase functions deploy approve-leave
   supabase functions deploy notify-trigger
   supabase functions deploy payroll-export
   ```

5. **Run the app**
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
