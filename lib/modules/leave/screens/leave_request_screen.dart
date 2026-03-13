import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/leave_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _leaveType = 'vacation';
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonCtrl = TextEditingController();

  static const _leaveTypes = [
    ('vacation', 'Vacation Leave'),
    ('sick', 'Sick Leave'),
    ('emergency', 'Emergency Leave'),
    ('maternity', 'Maternity Leave'),
    ('paternity', 'Paternity Leave'),
    ('without_pay', 'Leave Without Pay'),
  ];

  double get _daysRequested {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select dates')),
      );
      return;
    }

    final employeeId =
        await ref.read(currentEmployeeIdProvider.future);
    if (employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee profile not found')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(leaveServiceProvider).createLeaveRequest(
            employeeId: employeeId,
            leaveType: _leaveType,
            startDate: _startDate!,
            endDate: _endDate!,
            daysRequested: _daysRequested,
            reason: _reasonCtrl.text.trim().isEmpty
                ? null
                : _reasonCtrl.text.trim(),
          );

      if (mounted) {
        ref.invalidate(leaveListProvider);
        context.go('/leave');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave request submitted!')),
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
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.requestLeave)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _leaveType,
                  decoration: const InputDecoration(
                      labelText: AppStrings.leaveType),
                  items: _leaveTypes
                      .map((t) => DropdownMenuItem(
                            value: t.$1,
                            child: Text(t.$2),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _leaveType = v!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(AppStrings.startDate),
                        subtitle: Text(_startDate != null
                            ? HrisDateUtils.toDisplay(_startDate!)
                            : 'Not selected'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final p = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
                          );
                          if (p != null) setState(() => _startDate = p);
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(AppStrings.endDate),
                        subtitle: Text(_endDate != null
                            ? HrisDateUtils.toDisplay(_endDate!)
                            : 'Not selected'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final p = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: _startDate ?? DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365)),
                          );
                          if (p != null) setState(() => _endDate = p);
                        },
                      ),
                    ),
                  ],
                ),
                if (_daysRequested > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Total: ${_daysRequested.toInt()} day(s)',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                TextFormField(
                  controller: _reasonCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: AppStrings.reason,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Submit Request'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
