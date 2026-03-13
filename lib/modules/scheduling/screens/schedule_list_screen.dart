import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/schedule_service.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_widget.dart';
import '../widgets/shift_tile.dart';

final _scheduleListProvider = FutureProvider((ref) {
  return ScheduleService().getSchedules();
});

class ScheduleListScreen extends ConsumerWidget {
  const ScheduleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(_scheduleListProvider);
    final isAdminOrHr = ref.watch(isAdminOrHrProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scheduling),
        actions: [
          if (isAdminOrHr)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.go('/scheduling/new'),
            ),
        ],
      ),
      body: schedulesAsync.when(
        loading: () => const HrisLoadingWidget(),
        error: (e, _) => HrisErrorWidget(message: e.toString()),
        data: (schedules) {
          if (schedules.isEmpty) {
            return const HrisEmptyWidget(
              message: 'No schedules configured',
              icon: Icons.calendar_month_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
            itemBuilder: (_, i) => ShiftTile(schedule: schedules[i]),
          );
        },
      ),
    );
  }
}
