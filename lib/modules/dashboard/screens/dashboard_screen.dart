import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_widget.dart';
import '../widgets/metric_card.dart';
import '../widgets/attendance_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final roleAsync = ref.watch(currentUserRoleProvider);
    final role = roleAsync.valueOrNull ?? '';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(dashboardMetricsProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: metricsAsync.when(
        loading: () => const HrisLoadingWidget(message: 'Loading metrics...'),
        error: (e, _) => HrisErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(dashboardMetricsProvider),
        ),
        data: (metrics) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(dashboardMetricsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header / Greeting ──────────────────────────────
                _GreetingCard(role: role),
                const SizedBox(height: 24),

                // ── Today's Overview label ─────────────────────────
                _SectionLabel(label: 'Today\'s Overview'),
                const SizedBox(height: 12),

                // ── Metric grid ────────────────────────────────────
                _MetricGrid(metrics: metrics),
                const SizedBox(height: 24),

                // ── Attendance chart ───────────────────────────────
                _SectionLabel(label: 'Attendance Breakdown'),
                const SizedBox(height: 12),
                _ChartCard(metrics: metrics),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _GreetingCard extends StatelessWidget {
  final String role;

  const _GreetingCard({required this.role});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  HrisDateUtils.toDisplay(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          if (role.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                role
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map((w) => w.isEmpty
                        ? w
                        : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
                    .join(' '),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final dynamic metrics;

  const _MetricGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.of(context).size.width > 600 ? 3 : 2;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        MetricCard(
          label: 'Total Employees',
          value: metrics.totalEmployees,
          icon: Icons.people_rounded,
          color: AppColors.primary,
        ),
        MetricCard(
          label: 'Present Today',
          value: metrics.presentToday,
          icon: Icons.check_circle_rounded,
          color: AppColors.statusPresent,
        ),
        MetricCard(
          label: 'Late Today',
          value: metrics.lateToday,
          icon: Icons.schedule_rounded,
          color: AppColors.statusLate,
        ),
        MetricCard(
          label: 'Absent Today',
          value: metrics.absentToday,
          icon: Icons.cancel_rounded,
          color: AppColors.statusAbsent,
        ),
        MetricCard(
          label: 'On Leave',
          value: metrics.onLeave,
          icon: Icons.event_busy_rounded,
          color: AppColors.statusOnLeave,
        ),
        MetricCard(
          label: 'Attendance Rate',
          value: null,
          displayText: '${metrics.attendanceRate.toStringAsFixed(1)}%',
          icon: Icons.bar_chart_rounded,
          color: AppColors.secondary,
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final dynamic metrics;

  const _ChartCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: AttendanceChart(metrics: metrics),
    );
  }
}
