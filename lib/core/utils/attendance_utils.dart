import '../constants/app_colors.dart';
import 'package:flutter/material.dart';

class AttendanceUtils {
  AttendanceUtils._();

  static Color statusColor(String status) {
    switch (status) {
      case 'present':
        return AppColors.statusPresent;
      case 'late':
        return AppColors.statusLate;
      case 'absent':
        return AppColors.statusAbsent;
      case 'half_day':
        return AppColors.statusHalfDay;
      case 'overtime':
        return AppColors.statusOvertime;
      default:
        return Colors.grey;
    }
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'present':
        return 'Present';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      case 'half_day':
        return 'Half Day';
      case 'overtime':
        return 'Overtime';
      default:
        return status;
    }
  }

  static IconData statusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'late':
        return Icons.schedule;
      case 'absent':
        return Icons.cancel;
      case 'half_day':
        return Icons.timelapse;
      case 'overtime':
        return Icons.update;
      default:
        return Icons.help_outline;
    }
  }

  static double overtimeMinutesToHours(int minutes) => minutes / 60;
}
