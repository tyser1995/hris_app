import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_permissions.dart';
import '../../../providers/permission_provider.dart';

class AccessManagementScreen extends ConsumerStatefulWidget {
  const AccessManagementScreen({super.key});

  @override
  ConsumerState<AccessManagementScreen> createState() =>
      _AccessManagementScreenState();
}

class _AccessManagementScreenState
    extends ConsumerState<AccessManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AppPermissions.roles.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmReset(String role, String roleLabel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to Defaults?'),
        content: Text(
          'This will restore all "$roleLabel" permissions to their original '
          'defaults. Any custom changes will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      await ref.read(permissionProvider.notifier).resetRole(role);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$roleLabel permissions reset to defaults.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permAsync = ref.watch(permissionProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Access Management'),
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(height: 1, color: AppColors.divider),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                tabs: AppPermissions.roles.map((r) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: r.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(r.label),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: permAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(e.toString()),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.read(permissionProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (permissions) => TabBarView(
          controller: _tabController,
          children: AppPermissions.roles.map((role) {
            final rolePerms = permissions[role.key] ?? {};
            final isAdmin = role.key == 'admin';
            return _RolePermissionsTab(
              role: role,
              permissions: rolePerms,
              isLocked: isAdmin,
              onToggle: isAdmin
                  ? null
                  : (key, value) async {
                      try {
                        await ref
                            .read(permissionProvider.notifier)
                            .toggle(role.key, key, value);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    },
              onReset: isAdmin
                  ? null
                  : () => _confirmReset(role.key, role.label),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Role tab content ─────────────────────────────────────────────────────────

class _RolePermissionsTab extends StatelessWidget {
  final RoleInfo role;
  final Map<String, bool> permissions;
  final bool isLocked;
  final void Function(String key, bool value)? onToggle;
  final VoidCallback? onReset;

  const _RolePermissionsTab({
    required this.role,
    required this.permissions,
    required this.isLocked,
    required this.onToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final grantedCount =
        permissions.values.where((v) => v).length;
    final totalCount = AppPermissions.allKeys.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Role header card ───────────────────────────────────────────────
        _RoleHeaderCard(
          role: role,
          grantedCount: grantedCount,
          totalCount: totalCount,
          isLocked: isLocked,
          onReset: onReset,
        ),

        const SizedBox(height: 20),

        // ── Permission group cards ─────────────────────────────────────────
        ...AppPermissions.groups.map((group) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PermissionGroupCard(
              group: group,
              permissions: permissions,
              isLocked: isLocked,
              onToggle: onToggle,
            ),
          );
        }),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Role header card ─────────────────────────────────────────────────────────

class _RoleHeaderCard extends StatelessWidget {
  final RoleInfo role;
  final int grantedCount;
  final int totalCount;
  final bool isLocked;
  final VoidCallback? onReset;

  const _RoleHeaderCard({
    required this.role,
    required this.grantedCount,
    required this.totalCount,
    required this.isLocked,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : grantedCount / totalCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: role.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isLocked ? Icons.shield_rounded : Icons.manage_accounts_outlined,
                  color: role.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          role.label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (isLocked) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: role.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Full access',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: role.color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(role.color),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$grantedCount / $totalCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: role.color,
                ),
              ),
            ],
          ),

          if (!isLocked && onReset != null) ...[
            const SizedBox(height: 14),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_rounded, size: 16),
              label: const Text('Reset to defaults'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant,
                textStyle: const TextStyle(fontSize: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Permission group card ────────────────────────────────────────────────────

class _PermissionGroupCard extends StatelessWidget {
  final PermissionGroup group;
  final Map<String, bool> permissions;
  final bool isLocked;
  final void Function(String key, bool value)? onToggle;

  const _PermissionGroupCard({
    required this.group,
    required this.permissions,
    required this.isLocked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: group.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(group.icon, size: 16, color: group.color),
                ),
                const SizedBox(width: 10),
                Text(
                  group.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: group.color,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.divider, height: 1),

          // Permission rows
          ...group.permissions.asMap().entries.map((entry) {
            final idx = entry.key;
            final perm = entry.value;
            final granted = permissions[perm.key] ?? false;
            final isLast = idx == group.permissions.length - 1;

            return Column(
              children: [
                _PermissionRow(
                  permission: perm,
                  granted: granted,
                  isLocked: isLocked,
                  onToggle: onToggle == null
                      ? null
                      : (val) => onToggle!(perm.key, val),
                ),
                if (!isLast)
                  const Divider(
                    color: AppColors.divider,
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Single permission row ────────────────────────────────────────────────────

class _PermissionRow extends StatelessWidget {
  final AppPermission permission;
  final bool granted;
  final bool isLocked;
  final ValueChanged<bool>? onToggle;

  const _PermissionRow({
    required this.permission,
    required this.granted,
    required this.isLocked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        permission.label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isLocked
              ? AppColors.onSurfaceVariant
              : AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        permission.description,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      value: isLocked ? true : granted,
      onChanged: isLocked ? null : onToggle,
      activeColor: AppColors.primary,
      dense: true,
    );
  }
}
