import 'package:flutter/foundation.dart';

import '../config/supabase/supabase_config.dart';
import '../core/constants/app_permissions.dart';
import '../core/errors/error_mapper.dart';

class PermissionService {
  final _client = SupabaseConfig.client;

  static const _table = 'role_permissions';

  // ─── Read ────────────────────────────────────────────────────────────────

  /// Returns all stored permissions grouped by role.
  /// Falls back to [AppPermissions.defaults] for any missing role/key combo.
  Future<Map<String, Map<String, bool>>> getAllRolePermissions() async {
    debugPrint('[PermissionService] Fetching all role permissions');
    try {
      final rows = await _client
          .from(_table)
          .select('role, permission_key, granted')
          .order('role');

      // Start from defaults so missing DB rows still show correct values
      final result = <String, Map<String, bool>>{};
      for (final entry in AppPermissions.defaults.entries) {
        result[entry.key] = Map<String, bool>.from(entry.value);
      }

      for (final row in rows as List) {
        final role = row['role'] as String;
        final key = row['permission_key'] as String;
        final granted = row['granted'] as bool;
        result.putIfAbsent(role, () => {})[key] = granted;
      }

      debugPrint('[PermissionService] Loaded permissions for ${result.length} roles');
      return result;
    } catch (e, st) {
      debugPrint('[PermissionService] ERROR fetching permissions: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load permissions.');
    }
  }

  // ─── Write ───────────────────────────────────────────────────────────────

  Future<void> updatePermission(
      String role, String permissionKey, bool granted) async {
    debugPrint('[PermissionService] Updating $role.$permissionKey → $granted');
    try {
      await _client.from(_table).upsert(
        {
          'role': role,
          'permission_key': permissionKey,
          'granted': granted,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'role,permission_key',
      );
    } catch (e, st) {
      debugPrint('[PermissionService] ERROR updating permission: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to update permission.');
    }
  }

  /// Resets all permissions for [role] to the hard-coded defaults.
  Future<void> resetRoleToDefaults(String role) async {
    debugPrint('[PermissionService] Resetting defaults for role: $role');
    final defaults = AppPermissions.defaults[role];
    if (defaults == null) return;
    try {
      final rows = defaults.entries
          .map((e) => {
                'role': role,
                'permission_key': e.key,
                'granted': e.value,
                'updated_at': DateTime.now().toIso8601String(),
              })
          .toList();
      await _client.from(_table).upsert(rows, onConflict: 'role,permission_key');
    } catch (e, st) {
      debugPrint('[PermissionService] ERROR resetting defaults: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to reset permissions.');
    }
  }
}
