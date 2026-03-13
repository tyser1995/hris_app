import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/leave_provider.dart';
import '../../../models/leave_request_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class LeaveApprovalScreen extends ConsumerStatefulWidget {
  final String leaveId;

  const LeaveApprovalScreen({super.key, required this.leaveId});

  @override
  ConsumerState<LeaveApprovalScreen> createState() =>
      _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends ConsumerState<LeaveApprovalScreen> {
  final _remarksCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _act(String action) async {
    final employeeId =
        await ref.read(currentEmployeeIdProvider.future);
    final role = await ref.read(currentUserRoleProvider.future);
    if (employeeId == null || role == null) return;

    final level = (role == 'supervisor' || role == 'department_head')
        ? 'supervisor'
        : 'hr';

    setState(() => _isLoading = true);

    try {
      await ref.read(leaveServiceProvider).approveLeave(
            leaveId: widget.leaveId,
            action: action,
            approverId: employeeId,
            level: level,
            remarks: _remarksCtrl.text.trim().isEmpty
                ? null
                : _remarksCtrl.text.trim(),
          );

      if (mounted) {
        ref.invalidate(leaveListProvider);
        context.go('/leave');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                action == 'approve' ? 'Leave approved!' : 'Leave rejected.'),
            backgroundColor:
                action == 'approve' ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leavesAsync = ref.watch(leaveListProvider((
      employeeId: null,
      status: 'pending_supervisor',
      page: 0,
    )));

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Leave Approval')),
        body: leavesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (leaves) {
            final leave = leaves
                .where((l) => l.id == widget.leaveId)
                .firstOrNull;

            if (leave == null) {
              return const Center(child: Text('Leave request not found'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leave.employeeFullName ?? 'Unknown',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _Row('Leave Type', leave.leaveTypeLabel),
                          _Row(
                              'Start Date',
                              HrisDateUtils.toDisplay(leave.startDate)),
                          _Row('End Date',
                              HrisDateUtils.toDisplay(leave.endDate)),
                          _Row(
                              'Days',
                              '${leave.daysRequested} day(s)'),
                          if (leave.reason != null)
                            _Row('Reason', leave.reason!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _remarksCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Remarks (optional)',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text(AppStrings.approve),
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success),
                          onPressed: () => _act('approve'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text(AppStrings.reject),
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.error),
                          onPressed: () => _act('reject'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
