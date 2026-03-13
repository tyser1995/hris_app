import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../attendance/widgets/attendance_status_badge.dart';

class MyAttendanceScreen extends ConsumerStatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  ConsumerState<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends ConsumerState<MyAttendanceScreen> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final employeeIdAsync = ref.watch(currentEmployeeIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: employeeIdAsync.when(
        loading: () => const HrisLoadingWidget(),
        error: (e, _) => HrisErrorWidget(message: e.toString()),
        data: (employeeId) {
          if (employeeId == null) {
            return const HrisEmptyWidget(message: 'No employee profile');
          }

          final attendanceAsync = ref.watch(employeeAttendanceProvider((
            employeeId: employeeId,
            startDate: _startDate,
            endDate: _endDate,
          )));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(HrisDateUtils.toDisplay(_startDate)),
                        onPressed: () async {
                          final p = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (p != null) setState(() => _startDate = p);
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('–'),
                    ),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(HrisDateUtils.toDisplay(_endDate)),
                        onPressed: () async {
                          final p = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: _startDate,
                            lastDate: DateTime.now(),
                          );
                          if (p != null) setState(() => _endDate = p);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: attendanceAsync.when(
                  loading: () => const HrisLoadingWidget(),
                  error: (e, _) => HrisErrorWidget(message: e.toString()),
                  data: (records) {
                    if (records.isEmpty) {
                      return const HrisEmptyWidget(
                        message: 'No attendance records in this range',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: records.length,
                      itemBuilder: (_, i) {
                        final r = records[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            title: Text(HrisDateUtils.toDisplay(r.date)),
                            subtitle: Row(
                              children: [
                                Text(
                                  r.timeIn != null
                                      ? 'In: ${HrisDateUtils.toDisplayTime(r.timeIn!)}'
                                      : 'No check-in',
                                ),
                                if (r.timeOut != null) ...[
                                  const Text('  '),
                                  Text(
                                      'Out: ${HrisDateUtils.toDisplayTime(r.timeOut!)}'),
                                ],
                              ],
                            ),
                            trailing: AttendanceStatusBadge(status: r.status),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
