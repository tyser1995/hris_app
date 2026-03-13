import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  bool _isLoading = false;

  Future<void> _checkIn() async {
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
      await ref.read(attendanceServiceProvider).checkIn(
            employeeId: employeeId,
            scheduleId: 'default', // TODO: fetch from employee profile
            source: 'mobile',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checked in successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/attendance');
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

  Future<void> _checkOut(String attendanceId) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(attendanceServiceProvider).checkOut(attendanceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checked out successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/attendance');
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
    final employeeIdAsync = ref.watch(currentEmployeeIdProvider);

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Check In / Out')),
        body: employeeIdAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (employeeId) {
            if (employeeId == null) {
              return const Center(
                  child: Text('No employee profile linked to your account'));
            }

            final todayAsync = ref.watch(myTodayAttendanceProvider(employeeId));

            return todayAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (attendance) {
                final isCheckedIn =
                    attendance != null && attendance.timeIn != null;
                final isCheckedOut = attendance?.timeOut != null;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          HrisDateUtils.toDisplay(DateTime.now()),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<DateTime>(
                          stream: Stream.periodic(
                              const Duration(seconds: 1), (_) => DateTime.now()),
                          builder: (_, snap) => Text(
                            snap.hasData
                                ? HrisDateUtils.toDisplayTime(snap.data!)
                                : '',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        if (!isCheckedIn)
                          FilledButton.icon(
                            icon: const Icon(Icons.login),
                            label: const Text('Check In'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.statusPresent,
                              minimumSize: const Size(200, 56),
                            ),
                            onPressed: _checkIn,
                          )
                        else if (!isCheckedOut)
                          Column(
                            children: [
                              Text(
                                'Checked in at ${HrisDateUtils.toDisplayTime(attendance.timeIn!)}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                icon: const Icon(Icons.logout),
                                label: const Text('Check Out'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.statusAbsent,
                                  minimumSize: const Size(200, 56),
                                ),
                                onPressed: () => _checkOut(attendance.id),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: AppColors.success, size: 64),
                              const SizedBox(height: 16),
                              Text(
                                'Attendance recorded for today',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'In: ${HrisDateUtils.toDisplayTime(attendance.timeIn!)}  '
                                'Out: ${HrisDateUtils.toDisplayTime(attendance.timeOut!)}',
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
