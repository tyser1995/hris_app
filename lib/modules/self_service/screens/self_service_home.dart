import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/employee_provider.dart';
import '../../../models/employee_model.dart';
import '../../../shared/widgets/loading_overlay.dart';

class SelfServiceHome extends ConsumerWidget {
  const SelfServiceHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeIdAsync = ref.watch(currentEmployeeIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: employeeIdAsync.when(
        loading: () => const HrisLoadingWidget(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (employeeId) {
          if (employeeId == null) {
            return const Center(
                child: Text('No employee profile found for your account.'));
          }

          final employeeAsync =
              ref.watch(employeeDetailProvider(employeeId));

          return employeeAsync.when(
            loading: () => const HrisLoadingWidget(),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (employee) {
              if (employee == null) {
                return const Center(child: Text('Employee not found'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor:
                                  AppColors.primaryLight.withOpacity(0.2),
                              backgroundImage: employee.avatarUrl != null
                                  ? NetworkImage(employee.avatarUrl!)
                                  : null,
                              child: employee.avatarUrl == null
                                  ? Text(
                                      '${employee.firstName[0]}${employee.lastName[0]}',
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold),
                                  ),
                                  Text(employee.positionTitle ??
                                      'No position'),
                                  Text(
                                    employee.departmentName ??
                                        'No department',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick action tiles
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        _ActionCard(
                          icon: Icons.person_outline,
                          label: 'My Profile',
                          onTap: () => context.go('/me/profile'),
                        ),
                        _ActionCard(
                          icon: Icons.access_time,
                          label: 'My Attendance',
                          onTap: () => context.go('/me/attendance'),
                        ),
                        _ActionCard(
                          icon: Icons.event_note_outlined,
                          label: 'My Leave',
                          onTap: () => context.go('/me/leave'),
                        ),
                        _ActionCard(
                          icon: Icons.login,
                          label: 'Check In/Out',
                          onTap: () => context.go('/attendance/check-in'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
