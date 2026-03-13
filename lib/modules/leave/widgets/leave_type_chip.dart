import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LeaveTypeChip extends StatelessWidget {
  final String type;

  const LeaveTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      'vacation' => ('Vacation', AppColors.leaveVacation),
      'sick' => ('Sick', AppColors.leaveSick),
      'emergency' => ('Emergency', AppColors.leaveEmergency),
      'maternity' => ('Maternity', AppColors.leaveMaternity),
      'paternity' => ('Paternity', AppColors.leavePaternity),
      'without_pay' => ('Without Pay', AppColors.leaveWithoutPay),
      _ => (type, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
