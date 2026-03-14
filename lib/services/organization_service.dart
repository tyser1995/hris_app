import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_mapper.dart';
import '../models/organization_model.dart';

class OrganizationService {
  SupabaseClient get _client => SupabaseConfig.client;

  /// Lists all organizations. Requires super_admin role (RLS enforced).
  Future<List<OrganizationModel>> getOrganizations() async {
    debugPrint('[OrganizationService] Fetching organizations');
    try {
      final rows = await _client
          .from(AppConstants.tableOrganizations)
          .select()
          .order('created_at', ascending: false);
      return (rows as List)
          .map((r) => OrganizationModel.fromJson(_decode(r)))
          .toList();
    } catch (e, st) {
      debugPrint('[OrganizationService] ERROR: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load organizations.');
    }
  }

  /// Calls the `create-admin-user` edge function to atomically create an
  /// organization and invite/create the admin user.
  ///
  /// [autoConfirm] = true  → creates immediately with [password] (no email).
  /// [autoConfirm] = false → sends an invitation email (admin sets password).
  Future<Map<String, dynamic>> createAdminAccount({
    required String orgName,
    required String email,
    bool autoConfirm = false,
    String? password,
  }) async {
    debugPrint('[OrganizationService] Creating admin account for org: $orgName');
    try {
      final response = await _client.functions.invoke(
        AppConstants.fnCreateAdminUser,
        body: {
          'orgName': orgName,
          'email': email,
          'autoConfirm': autoConfirm,
          if (password != null) 'password': password,
        },
      );
      _throwIfFunctionError(response.data);
      return _decode(response.data);
    } catch (e, st) {
      debugPrint('[OrganizationService] ERROR: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to create admin account.');
    }
  }

  /// Calls the `delete-organization` edge function to delete an organization
  /// and its admin user accounts.
  Future<void> deleteOrganization(String organizationId) async {
    debugPrint('[OrganizationService] Deleting organization: $organizationId');
    try {
      final response = await _client.functions.invoke(
        AppConstants.fnDeleteOrganization,
        body: {'organizationId': organizationId},
      );
      _throwIfFunctionError(response.data);
    } catch (e, st) {
      debugPrint('[OrganizationService] ERROR: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to delete organization.');
    }
  }

  /// Throws a meaningful [Exception] when the edge function (or its gateway)
  /// returns an error payload.
  ///
  /// Handles two response shapes:
  ///   • Function-level:  `{"error": "Only super_admin can …"}`
  ///   • Gateway-level:   `{"code": 401, "message": "Invalid JWT"}`
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
          'Authentication failed (${data["message"]}). '
          'Please sign out and sign back in.',
        );
      }
      throw Exception(message as String);
    }
  }

  Map<String, dynamic> _decode(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>();
}
