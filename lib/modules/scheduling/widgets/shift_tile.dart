import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/schedule_model.dart';

class ShiftTile extends StatelessWidget {
  final ScheduleModel schedule;

  const ShiftTile({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(
            _typeIcon(schedule.type),
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(schedule.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          schedule.type.toUpperCase(),
          style: const TextStyle(fontSize: 12),
        ),
        children: schedule.details.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No shift details configured'),
                )
              ]
            : schedule.details
                .map((d) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.access_time, size: 16),
                      title: Text(d.periodLabel ?? 'Period'),
                      trailing: Text(
                        '${d.startTime} – ${d.endTime}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ))
                .toList(),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'regular':
        return Icons.schedule;
      case 'broken':
        return Icons.call_split;
      case 'flexible':
        return Icons.tune;
      default:
        return Icons.calendar_month;
    }
  }
}
