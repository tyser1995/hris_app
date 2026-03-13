import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dashboard_metrics_model.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/department_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/leave_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/permission_provider.dart';
import '../providers/settings_provider.dart';
import 'mock_data_store.dart';
import 'mock_services.dart';

/// All Riverpod provider overrides used when [AppConfig.isMockMode] is true.
///
/// Apply via:
/// ```dart
/// ProviderScope(overrides: MockOverrides.all, child: const HrisApp())
/// ```
class MockOverrides {
  MockOverrides._();

  static List<Override> get all => [
        // ── Auth ────────────────────────────────────────────────────────────
        authStateProvider.overrideWith((ref) =>
            Stream.value(AuthState(AuthChangeEvent.signedIn, _fakeSession()))),
        currentUserRoleProvider.overrideWith((ref) async => 'admin'),
        currentEmployeeIdProvider
            .overrideWith((ref) async => MockDataStore.adminEmployeeId),

        // ── Service providers ───────────────────────────────────────────────
        employeeServiceProvider
            .overrideWithValue(MockEmployeeService()),
        leaveServiceProvider
            .overrideWithValue(MockLeaveService()),
        attendanceServiceProvider
            .overrideWithValue(MockAttendanceService()),
        notificationServiceProvider
            .overrideWithValue(MockNotificationService()),
        departmentServiceProvider
            .overrideWithValue(MockDepartmentService()),
        settingsServiceProvider
            .overrideWithValue(MockSettingsService()),
        permissionServiceProvider
            .overrideWithValue(MockPermissionService()),

        // ── Dashboard ────────────────────────────────────────────────────────
        dashboardMetricsProvider.overrideWith((ref) async => const DashboardMetrics(
              totalEmployees: MockDataStore.totalEmployees,
              presentToday: MockDataStore.presentToday,
              lateToday: MockDataStore.lateToday,
              absentToday: MockDataStore.absentToday,
              onLeave: MockDataStore.onLeave,
            )),

        // ── Derived stream providers that depend on auth userId ──────────────
        todayAttendanceStreamProvider.overrideWith(
            (ref) => Stream.value(MockDataStore.todayAttendance)),
        notificationListProvider
            .overrideWith((ref) async => MockDataStore.notifications),
        unreadNotificationCountProvider.overrideWith(
            (ref) async => MockDataStore.unreadNotifications.length),
        unreadNotificationsStreamProvider.overrideWith(
            (ref) => Stream.value(MockDataStore.unreadNotifications)),
      ];

  // ─── Fake Supabase session (never makes network calls) ─────────────────────

  static Session _fakeSession() {
    return Session.fromJson({
      'access_token': 'demo_mock_access_token',
      'token_type': 'bearer',
      'expires_in': 86400,
      'expires_at':
          DateTime(2099, 1, 1).millisecondsSinceEpoch ~/ 1000,
      'refresh_token': 'demo_mock_refresh_token',
      'user': {
        'id': MockDataStore.adminUserId,
        'email': 'admin@demo.local',
        'aud': 'authenticated',
        'role': 'authenticated',
        'app_metadata': {'provider': 'email', 'providers': ['email']},
        'user_metadata': {'full_name': 'Demo Admin'},
        'identities': [],
        'email_confirmed_at': '2024-01-01T00:00:00.000Z',
        'last_sign_in_at': '2024-01-01T00:00:00.000Z',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
        'phone': '',
        'confirmed_at': '2024-01-01T00:00:00.000Z',
      },
    })!;
  }
}
