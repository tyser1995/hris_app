import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../config/supabase/supabase_config.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/error_mapper.dart';

class AuthService {
  final _auth = SupabaseConfig.auth;
  final _client = SupabaseConfig.client;

  Session? get currentSession => _auth.currentSession;
  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) async {
    debugPrint('[AuthService] Attempting sign in for: $email');
    try {
      await _auth.signInWithPassword(email: email, password: password);
      debugPrint('[AuthService] Sign in successful for: $email');
    } catch (e, st) {
      debugPrint('[AuthService] ERROR signing in: $e\n$st');
      throw ErrorMapper.mapAuth(e);
    }
  }

  Future<void> signOut() async {
    debugPrint('[AuthService] Signing out user: ${currentUser?.email}');
    try {
      await _auth.signOut();
      debugPrint('[AuthService] Sign out successful');
    } catch (e, st) {
      debugPrint('[AuthService] ERROR signing out: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to sign out.');
    }
  }

  Future<void> resetPassword(String email) async {
    debugPrint('[AuthService] Sending password reset for: $email');
    try {
      await _auth.resetPasswordForEmail(email);
      debugPrint('[AuthService] Password reset email sent to: $email');
    } catch (e, st) {
      debugPrint('[AuthService] ERROR sending password reset: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to send password reset email.');
    }
  }

  Future<String?> getCurrentUserRole() async {
    final userId = currentUser?.id;
    if (userId == null) {
      debugPrint('[AuthService] getCurrentUserRole: no current user');
      return null;
    }
    debugPrint('[AuthService] Fetching role for user: $userId');
    try {
      final result = await _client
          .from('user_roles')
          .select('role')
          .eq('user_id', userId)
          .maybeSingle();
      final role = result?['role'] as String?;
      debugPrint('[AuthService] User role: $role');
      return role;
    } catch (e, st) {
      debugPrint('[AuthService] ERROR fetching user role: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to fetch user role.');
    }
  }

  Future<String?> getCurrentEmployeeId() async {
    final userId = currentUser?.id;
    if (userId == null) {
      debugPrint('[AuthService] getCurrentEmployeeId: no current user');
      return null;
    }
    debugPrint('[AuthService] Fetching employee ID for user: $userId');
    try {
      final result = await _client
          .from('employees')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      final empId = result?['id'] as String?;
      debugPrint('[AuthService] Employee ID: $empId');
      return empId;
    } catch (e, st) {
      debugPrint('[AuthService] ERROR fetching employee ID: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to fetch employee record.');
    }
  }

  bool get isAuthenticated => currentSession != null;
}
