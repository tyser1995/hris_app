import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/permission_service.dart';

// ─── Service provider ─────────────────────────────────────────────────────────

final permissionServiceProvider =
    Provider<PermissionService>((_) => PermissionService());

// ─── State notifier ───────────────────────────────────────────────────────────

/// Holds Map<role, Map<permissionKey, granted>>.
/// Exposes optimistic toggle and per-role reset.
class PermissionNotifier
    extends StateNotifier<AsyncValue<Map<String, Map<String, bool>>>> {
  PermissionNotifier(this._service) : super(const AsyncValue.loading()) {
    _load();
  }

  final PermissionService _service;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final data = await _service.getAllRolePermissions();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void refresh() => _load();

  Future<void> toggle(String role, String permissionKey, bool granted) async {
    final prev = state;
    // Optimistic update
    final current = state.valueOrNull;
    if (current != null) {
      final next = {
        for (final e in current.entries)
          e.key: e.key == role
              ? {...e.value, permissionKey: granted}
              : Map<String, bool>.from(e.value),
      };
      state = AsyncValue.data(next);
    }

    try {
      await _service.updatePermission(role, permissionKey, granted);
    } catch (e, st) {
      // Rollback on failure
      state = prev;
      rethrow;
    }
  }

  Future<void> resetRole(String role) async {
    try {
      await _service.resetRoleToDefaults(role);
      await _load();
    } catch (e) {
      rethrow;
    }
  }
}

final permissionProvider = StateNotifierProvider<PermissionNotifier,
    AsyncValue<Map<String, Map<String, bool>>>>(
  (ref) => PermissionNotifier(ref.read(permissionServiceProvider)),
);
