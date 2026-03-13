import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_mapper.dart';
import '../models/dashboard_metrics_model.dart';

final dashboardMetricsProvider =
    FutureProvider<DashboardMetrics>((ref) async {
  final client = SupabaseConfig.client;
  final today = DateTime.now().toIso8601String().substring(0, 10);
  debugPrint('[DashboardProvider] Fetching dashboard metrics for: $today');

  try {
    final results = await Future.wait([
      client
          .from(AppConstants.tableEmployees)
          .select('id')
          .eq('employment_status', 'active')
          .count(),
      client
          .from(AppConstants.tableAttendance)
          .select('id')
          .eq('date', today)
          .eq('status', 'present')
          .count(),
      client
          .from(AppConstants.tableAttendance)
          .select('id')
          .eq('date', today)
          .eq('status', 'late')
          .count(),
      client
          .from(AppConstants.tableAttendance)
          .select('id')
          .eq('date', today)
          .eq('status', 'absent')
          .count(),
      client
          .from(AppConstants.tableLeaveRequests)
          .select('id')
          .lte('start_date', today)
          .gte('end_date', today)
          .eq('status', 'approved')
          .count(),
    ]);

    final metrics = DashboardMetrics(
      totalEmployees: results[0].count,
      presentToday: results[1].count,
      lateToday: results[2].count,
      absentToday: results[3].count,
      onLeave: results[4].count,
    );

    debugPrint(
      '[DashboardProvider] Metrics loaded: total=${metrics.totalEmployees}, '
      'present=${metrics.presentToday}, late=${metrics.lateToday}, '
      'absent=${metrics.absentToday}, onLeave=${metrics.onLeave}',
    );

    return metrics;
  } catch (e, st) {
    debugPrint('[DashboardProvider] ERROR fetching dashboard metrics: $e\n$st');
    throw ErrorMapper.map(e, 'Failed to load dashboard metrics.');
  }
});
