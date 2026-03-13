import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserRoleProvider = FutureProvider<String?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final session = authState.valueOrNull?.session;
  if (session == null) return null;
  return ref.read(authServiceProvider).getCurrentUserRole();
});

final currentEmployeeIdProvider = FutureProvider<String?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final session = authState.valueOrNull?.session;
  if (session == null) return null;
  return ref.read(authServiceProvider).getCurrentEmployeeId();
});

final isAdminOrHrProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider).valueOrNull;
  return role == 'admin' || role == 'hr_staff';
});

final isSupervisorOrAboveProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider).valueOrNull;
  return ['admin', 'hr_staff', 'department_head', 'supervisor'].contains(role);
});
