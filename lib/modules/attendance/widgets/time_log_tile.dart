import 'package:flutter/material.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/attendance_utils.dart';
import '../../../models/attendance_model.dart';
import 'attendance_status_badge.dart';

class TimeLogTile extends StatelessWidget {
  final AttendanceModel record;

  const TimeLogTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.employeeFullName ?? record.employeeId,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                AttendanceStatusBadge(status: record.status),
              ],
            ),
            if (record.employeeCode != null)
              Text(
                record.employeeCode!,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                _TimeChip(
                  icon: Icons.login,
                  label: 'In',
                  value: record.timeIn != null
                      ? HrisDateUtils.toDisplayTime(record.timeIn!)
                      : '--:--',
                ),
                const SizedBox(width: 12),
                _TimeChip(
                  icon: Icons.logout,
                  label: 'Out',
                  value: record.timeOut != null
                      ? HrisDateUtils.toDisplayTime(record.timeOut!)
                      : '--:--',
                ),
                const Spacer(),
                if (record.lateMinutes > 0)
                  _StatChip(
                    label: 'Late',
                    value: AttendanceUtils.statusLabel('late'),
                    color: Colors.orange,
                    detail: '${record.lateMinutes}m',
                  ),
                if (record.overtimeMinutes > 0)
                  _StatChip(
                    label: 'OT',
                    value: '${(record.overtimeMinutes / 60).toStringAsFixed(1)}h',
                    color: Colors.blue,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TimeChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? detail;

  const _StatChip(
      {required this.label,
      required this.value,
      required this.color,
      this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        detail ?? value,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
