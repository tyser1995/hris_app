import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/leave_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../leave/widgets/leave_type_chip.dart';

class MyLeaveScreen extends ConsumerWidget {
  const MyLeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeIdAsync = ref.watch(currentEmployeeIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Leave'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/leave/new'),
          ),
        ],
      ),
      body: employeeIdAsync.when(
        loading: () => const HrisLoadingWidget(),
        error: (e, _) => HrisErrorWidget(message: e.toString()),
        data: (employeeId) {
          if (employeeId == null) {
            return const HrisEmptyWidget(message: 'No employee profile');
          }

          final leavesAsync = ref.watch(leaveListProvider((
            employeeId: employeeId,
            status: null,
            page: 0,
          )));

          final balancesAsync = ref.watch(leaveBalancesProvider((
            employeeId: employeeId,
            year: DateTime.now().year,
          )));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leave balances
                Text(
                  'Leave Balances (${DateTime.now().year})',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                balancesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                  data: (balances) {
                    if (balances.isEmpty) {
                      return const Text('No leave balances configured');
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: balances.entries
                          .map((e) => _BalanceChip(
                                type: e.key,
                                balance: e.value,
                              ))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Leave history
                Text(
                  'Leave History',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                leavesAsync.when(
                  loading: () => const HrisLoadingWidget(),
                  error: (e, _) => HrisErrorWidget(message: e.toString()),
                  data: (leaves) {
                    if (leaves.isEmpty) {
                      return const HrisEmptyWidget(
                        message: 'No leave requests yet',
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: leaves.length,
                      itemBuilder: (_, i) {
                        final leave = leaves[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Row(
                              children: [
                                LeaveTypeChip(type: leave.leaveType),
                                const SizedBox(width: 8),
                                Text('${leave.daysRequested} day(s)'),
                              ],
                            ),
                            subtitle: Text(
                              '${HrisDateUtils.toDisplay(leave.startDate)} – '
                              '${HrisDateUtils.toDisplay(leave.endDate)}',
                            ),
                            trailing: _StatusChip(status: leave.status),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  final String type;
  final double balance;

  const _BalanceChip({required this.type, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${balance.toStringAsFixed(1)}',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primary),
          ),
          Text(type.replaceAll('_', ' '), style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'approved' => ('Approved', AppColors.success),
      'rejected' => ('Rejected', AppColors.error),
      'pending_supervisor' => ('Pending', AppColors.warning),
      'pending_hr' => ('Pending HR', AppColors.info),
      'cancelled' => ('Cancelled', Colors.grey),
      _ => (status, Colors.grey),
    };

    return Chip(
      label: Text(label,
          style: TextStyle(fontSize: 11, color: color)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}
