import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/org_user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_management_provider.dart';
import '../widgets/create_user_dialog.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(orgUsersProvider);
    final role = ref.watch(currentUserRoleProvider).valueOrNull ?? '';
    final isSuperAdmin = role == 'super_admin';

    void onCreateUser() async {
      final created = await showCreateUserDialog(context);
      if (created) ref.invalidate(orgUsersProvider);
    }

    void onInviteUser() => context.go('/users/invite');

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Accounts'),
        actions: [
          FilledButton.icon(
            onPressed: isSuperAdmin ? onCreateUser : onInviteUser,
            icon: Icon(
              isSuperAdmin
                  ? Icons.person_add_rounded
                  : Icons.send_rounded,
              size: 18,
            ),
            label: Text(isSuperAdmin ? 'Create User' : 'Invite User'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('$e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(orgUsersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (users) => users.isEmpty
            ? _EmptyState(
                isSuperAdmin: isSuperAdmin,
                onAction: isSuperAdmin ? onCreateUser : onInviteUser,
              )
            : _UserList(users: users, isSuperAdmin: isSuperAdmin),
      ),
    );
  }
}

// ── User list ─────────────────────────────────────────────────────────────────

class _UserList extends StatelessWidget {
  final List<OrgUserModel> users;
  final bool isSuperAdmin;

  const _UserList({required this.users, required this.isSuperAdmin});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) =>
          _UserCard(user: users[i], showOrg: isSuperAdmin),
    );
  }
}

class _UserCard extends StatelessWidget {
  final OrgUserModel user;
  final bool showOrg;

  const _UserCard({required this.user, this.showOrg = false});

  @override
  Widget build(BuildContext context) {
    final initial =
        user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';
    final roleColor = _roleColor(user.role);
    final roleLabel = _roleLabel(user.role);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: roleColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _RoleBadge(label: roleLabel, color: roleColor),
                    _StatusBadge(activated: user.isActivated),
                    if (showOrg && user.organizationName != null)
                      _OrgBadge(name: user.organizationName!),
                  ],
                ),
                if (user.lastSignInAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Last login: ${DateFormat('MMM d, yyyy').format(user.lastSignInAt!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant),
                  ),
                ] else if (user.isActivated) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Never logged in',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),

          // Joined date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (user.createdAt != null)
                Text(
                  DateFormat('MMM d, yyyy').format(user.createdAt!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant),
                ),
              const SizedBox(height: 2),
              Text(
                'Joined',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFF7C3AED);
      case 'hr_staff':
        return const Color(0xFF0891B2);
      case 'department_head':
        return const Color(0xFF059669);
      case 'supervisor':
        return const Color(0xFFD97706);
      case 'super_admin':
        return const Color(0xFFDC2626);
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _roleLabel(String role) => role
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) =>
          w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _RoleBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool activated;

  const _StatusBadge({required this.activated});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: activated
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            activated
                ? Icons.check_circle_outline_rounded
                : Icons.schedule_rounded,
            size: 11,
            color: activated ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            activated ? 'Active' : 'Pending',
            style: TextStyle(
              color: activated ? AppColors.success : AppColors.warning,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrgBadge extends StatelessWidget {
  final String name;

  const _OrgBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.business_outlined,
              size: 11, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isSuperAdmin;
  final VoidCallback onAction;

  const _EmptyState({required this.isSuperAdmin, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.group_outlined,
                size: 36, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            'No users yet',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            isSuperAdmin
                ? 'Create user accounts and assign them to an organization.'
                : 'Invite team members to give them access.',
            style: const TextStyle(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAction,
            icon: Icon(isSuperAdmin
                ? Icons.person_add_rounded
                : Icons.send_rounded),
            label:
                Text(isSuperAdmin ? 'Create User' : 'Invite User'),
          ),
        ],
      ),
    );
  }
}
