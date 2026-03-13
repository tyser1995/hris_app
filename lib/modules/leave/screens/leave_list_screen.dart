import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/leave_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_widget.dart';
import '../widgets/leave_type_chip.dart';

class LeaveListScreen extends ConsumerWidget {
  const LeaveListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leavesAsync = ref.watch(leaveListProvider((
      employeeId: null,
      status: null,
      page: 0,
    )));
    final isSupervisorAbove = ref.watch(isSupervisorOrAboveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.leave),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: AppStrings.requestLeave,
            onPressed: () => context.go('/leave/new'),
          ),
        ],
      ),
      body: leavesAsync.when(
        loading: () => const HrisLoadingWidget(),
        error: (e, _) => HrisErrorWidget(message: e.toString()),
        data: (leaves) {
          if (leaves.isEmpty) {
            return const HrisEmptyWidget(
              message: 'No leave requests found',
              icon: Icons.event_note_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaves.length,
            itemBuilder: (_, i) {
              final leave = leaves[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: isSupervisorAbove &&
                          leave.status == 'pending_supervisor'
                      ? () => context
                          .go('/leave/${leave.id}/approve')
                      : null,
                  title: Text(
                    leave.employeeFullName ?? 'Unknown Employee',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          LeaveTypeChip(type: leave.leaveType),
                          const SizedBox(width: 8),
                          Text('${leave.daysRequested} day(s)'),
                        ],
                      ),
                      Text(
                        '${HrisDateUtils.toDisplay(leave.startDate)} – '
                        '${HrisDateUtils.toDisplay(leave.endDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: _StatusBadge(status: leave.status),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
