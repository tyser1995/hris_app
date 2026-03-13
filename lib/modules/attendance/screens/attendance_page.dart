import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/attendance_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_widget.dart';
import '../widgets/time_log_tile.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final attendanceStream = ref.watch(todayAttendanceStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.attendance),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            tooltip: AppStrings.checkIn,
            onPressed: () => context.go('/attendance/check-in'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date header
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              HrisDateUtils.toDisplay(_selectedDate),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: attendanceStream.when(
              loading: () => const HrisLoadingWidget(),
              error: (e, _) => HrisErrorWidget(message: e.toString()),
              data: (records) {
                if (records.isEmpty) {
                  return const HrisEmptyWidget(
                    message: 'No attendance records for today',
                    icon: Icons.access_time_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (_, i) => TimeLogTile(record: records[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
