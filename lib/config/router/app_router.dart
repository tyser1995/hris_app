import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../shared/layouts/admin_shell.dart';
import '../../modules/auth/screens/login_screen.dart';
import '../../modules/auth/screens/forgot_password_screen.dart';
import '../../modules/dashboard/screens/dashboard_screen.dart';
import '../../modules/employee/screens/employee_list_screen.dart';
import '../../modules/employee/screens/employee_detail_screen.dart';
import '../../modules/employee/screens/employee_form_screen.dart';
import '../../modules/attendance/screens/attendance_page.dart';
import '../../modules/attendance/screens/check_in_screen.dart';
import '../../modules/leave/screens/leave_list_screen.dart';
import '../../modules/leave/screens/leave_request_screen.dart';
import '../../modules/leave/screens/leave_approval_screen.dart';
import '../../modules/scheduling/screens/schedule_list_screen.dart';
import '../../modules/scheduling/screens/schedule_editor_screen.dart';
import '../../modules/reports/screens/reports_screen.dart';
import '../../modules/notifications/screens/notifications_screen.dart';
import '../../modules/self_service/screens/self_service_home.dart';
import '../../modules/self_service/screens/my_profile_screen.dart';
import '../../modules/self_service/screens/my_attendance_screen.dart';
import '../../modules/self_service/screens/my_leave_screen.dart';
import '../../modules/settings/screens/settings_screen.dart';
import '../../modules/settings/screens/access_management_screen.dart';
import '../../modules/settings/screens/branding_screen.dart';
import '../../modules/settings/screens/data_management_screen.dart';
import '../../modules/settings/screens/employment_types_screen.dart';
import '../../modules/super_admin/screens/organizations_screen.dart';
import '../../modules/super_admin/screens/create_admin_screen.dart';
import '../../modules/user_management/screens/users_screen.dart';
import '../../modules/user_management/screens/invite_user_screen.dart';
import 'route_names.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  // Watch role so router re-evaluates when role resolves after login
  final roleAsync = ref.watch(currentUserRoleProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.session != null;
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/forgot-password';
      final role = roleAsync.valueOrNull;

      if (!isLoggedIn && !isLoginRoute) return '/login';

      if (isLoggedIn && isLoginRoute) {
        // Wait for role to resolve before redirecting
        if (role == null) return null;
        return '/dashboard';
      }

      // Guard super-admin routes — only super_admin may access them
      if (isLoggedIn && state.matchedLocation.startsWith('/super-admin')) {
        if (role == null) return null; // wait for role to load
        if (role != 'super_admin') return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          // ── Super admin routes (inside shell so sidebar is visible) ───────
          GoRoute(
            path: '/super-admin',
            name: RouteNames.superAdmin,
            builder: (_, __) => const OrganizationsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.createAdmin,
                builder: (_, __) => const CreateAdminScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/dashboard',
            name: RouteNames.dashboard,
            builder: (_, __) => const DashboardScreen(),
          ),
          // Employees
          GoRoute(
            path: '/employees',
            name: RouteNames.employees,
            builder: (_, __) => const EmployeeListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.employeeCreate,
                builder: (_, __) => const EmployeeFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.employeeDetail,
                builder: (_, state) => EmployeeDetailScreen(
                  employeeId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.employeeEdit,
                    builder: (_, state) => EmployeeFormScreen(
                      employeeId: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Attendance
          GoRoute(
            path: '/attendance',
            name: RouteNames.attendance,
            builder: (_, __) => const AttendancePage(),
            routes: [
              GoRoute(
                path: 'check-in',
                name: RouteNames.checkIn,
                builder: (_, __) => const CheckInScreen(),
              ),
            ],
          ),
          // Leave
          GoRoute(
            path: '/leave',
            name: RouteNames.leave,
            builder: (_, __) => const LeaveListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.leaveCreate,
                builder: (_, __) => const LeaveRequestScreen(),
              ),
              GoRoute(
                path: ':id/approve',
                name: RouteNames.leaveApproval,
                builder: (_, state) => LeaveApprovalScreen(
                  leaveId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          // Scheduling
          GoRoute(
            path: '/scheduling',
            name: RouteNames.scheduling,
            builder: (_, __) => const ScheduleListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.scheduleEditor,
                builder: (_, __) => const ScheduleEditorScreen(),
              ),
            ],
          ),
          // Reports
          GoRoute(
            path: '/reports',
            name: RouteNames.reports,
            builder: (_, __) => const ReportsScreen(),
          ),
          // Notifications
          GoRoute(
            path: '/notifications',
            name: RouteNames.notifications,
            builder: (_, __) => const NotificationsScreen(),
          ),
          // Settings
          GoRoute(
            path: '/settings',
            name: RouteNames.settings,
            builder: (_, __) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'access',
                name: RouteNames.accessManagement,
                builder: (_, __) => const AccessManagementScreen(),
              ),
              GoRoute(
                path: 'branding',
                name: RouteNames.branding,
                builder: (_, __) => const BrandingScreen(),
              ),
              GoRoute(
                path: 'data-management',
                name: RouteNames.dataManagement,
                builder: (_, __) => const DataManagementScreen(),
                routes: [
                  GoRoute(
                    path: 'employment-types',
                    name: RouteNames.employmentTypes,
                    builder: (_, __) => const EmploymentTypesScreen(),
                  ),
                ],
              ),
            ],
          ),
          // User management (admin/hr)
          GoRoute(
            path: '/users',
            name: RouteNames.users,
            builder: (_, __) => const UsersScreen(),
            routes: [
              GoRoute(
                path: 'invite',
                name: RouteNames.inviteUser,
                builder: (_, __) => const InviteUserScreen(),
              ),
            ],
          ),
          // Self-service
          GoRoute(
            path: '/me',
            name: RouteNames.selfService,
            builder: (_, __) => const SelfServiceHome(),
            routes: [
              GoRoute(
                path: 'profile',
                name: RouteNames.myProfile,
                builder: (_, __) => const MyProfileScreen(),
              ),
              GoRoute(
                path: 'attendance',
                name: RouteNames.myAttendance,
                builder: (_, __) => const MyAttendanceScreen(),
              ),
              GoRoute(
                path: 'leave',
                name: RouteNames.myLeave,
                builder: (_, __) => const MyLeaveScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 64),
            const SizedBox(height: 16),
            Text('Page not found: ${state.error}'),
            TextButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});
