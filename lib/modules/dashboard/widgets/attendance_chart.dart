import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/dashboard_metrics_model.dart';

class AttendanceChart extends StatelessWidget {
  final DashboardMetrics metrics;

  const AttendanceChart({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final total = metrics.totalEmployees;
    if (total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No attendance data')),
      );
    }

    final sections = [
      PieChartSectionData(
        value: metrics.presentToday.toDouble(),
        title: 'Present\n${metrics.presentToday}',
        color: AppColors.statusPresent,
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontSize: 12),
      ),
      PieChartSectionData(
        value: metrics.lateToday.toDouble(),
        title: 'Late\n${metrics.lateToday}',
        color: AppColors.statusLate,
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontSize: 12),
      ),
      PieChartSectionData(
        value: metrics.absentToday.toDouble(),
        title: 'Absent\n${metrics.absentToday}',
        color: AppColors.statusAbsent,
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontSize: 12),
      ),
      PieChartSectionData(
        value: metrics.onLeave.toDouble(),
        title: 'Leave\n${metrics.onLeave}',
        color: AppColors.statusOnLeave,
        radius: 80,
        titleStyle:
            const TextStyle(color: Colors.white, fontSize: 12),
      ),
    ].where((s) => s.value > 0).toList();

    return SizedBox(
      height: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
      ),
    );
  }
}
