import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_mapper.dart';
import '../models/org_user_model.dart';

class UserManagementService {
  SupabaseClient get _client => SupabaseConfig.client;

  /// Returns all users in the caller's organization.
  /// Uses the `hris.get_org_users()` security-definer function which
  /// can read `auth.users` emails.
  Future<List<OrgUserModel>> getOrgUsers() async {
    debugPrint('[UserManagementService] Fetching org users');
    try {
      final rows = await _client.rpc('get_org_users');
      return (rows as List)
          .map((r) => OrgUserModel.fromJson(_decode(r)))
          .toList();
    } catch (e, st) {
      debugPrint('[UserManagementService] ERROR: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load users.');
    }
  }

  /// Creates a user account (super_admin only).
  /// [autoConfirm] = true  → creates immediately with password (no email sent).
  /// [autoConfirm] = false → sends an invitation email (password set by user).
  Future<OrgUserModel> createUser({
    required String email,
    String? password,
    required bool autoConfirm,
    required String role,
    required String organizationId,
  }) async {
    debugPrint('[UserManagementService] Creating user $email (autoConfirm: $autoConfirm)');
    try {
      final response = await _client.functions.invoke(
        AppConstants.fnCreateUser,
        body: {
          'email': email,
          if (password != null) 'password': password,
          'autoConfirm': autoConfirm,
          'role': role,
          'organizationId': organizationId,
        },
      );
      _throwIfFunctionError(response.data);
      final data = _decode(response.data);
      final u = data['user'] as Map<String, dynamic>;
      return OrgUserModel(
        userId: u['id'] as String,
        email: u['email'] as String,
        role: u['role'] as String,
        organizationId: organizationId,
        emailConfirmedAt: autoConfirm ? DateTime.now() : null,
      );
    } catch (e, st) {
      debugPrint('[UserManagementService] ERROR: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to create user.');
    }
  }

  /// Invites a user to the caller's organization.
  /// Calls the `invite-user` edge function which sends an activation email.
  Future<OrgUserModel> inviteUser({
    required String email,
    required String role,
  }) async {
    debugPrint('[UserManagementService] Inviting $email as $role');
    try {
      final response = await _client.functions.invoke(
        AppConstants.fnInviteUser,
        body: {'email': email, 'role': role},
      );
      _throwIfFunctionError(response.data);
      final data = _decode(response.data);
      final u = data['user'] as Map<String, dynamic>;
      return OrgUserModel(
        userId: u['id'] as String,
        email: u['email'] as String,
        role: u['role'] as String,
      );
    } catch (e, st) {
      debugPrint('[UserManagementService] ERROR: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to invite user.');
    }
  }

  /// Throws a meaningful [Exception] for both function-level and gateway errors.
  ///
  /// Function-level: `{"error": "Only super_admin can …"}`
  /// Gateway-level:  `{"code": 401, "message": "Invalid JWT"}`
  void _throwIfFunctionError(dynamic raw) {
    if (raw == null) {
      throw Exception(
        'No response from server. Your session may have expired — '
        'please sign out and sign back in.',
      );
    }
    final data = _decode(raw);
    if (data['error'] != null) {
      throw Exception(data['error'] as String);
    }
    final code = data['code'];
    final message = data['message'];
    if (message != null && code != null && (code as int) >= 400) {
      if (code == 401) {
        throw Exception(
          'Authentication failed. Please sign out and sign back in.',
        );
      }
      if (code == 403) {
        throw Exception(
          'Permission denied. Only super_admin can perform this action.',
        );
      }
      throw Exception(message as String);
    }
  }

  Map<String, dynamic> _decode(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>();
}
