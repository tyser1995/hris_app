import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors - modern indigo-blue
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary - emerald
  static const Color secondary = Color(0xFF059669);
  static const Color accent = Color(0xFFF59E0B);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Surface & background
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color divider = Color(0xFFE2E8F0);

  // Sidebar
  static const Color sidebarBg = Color(0xFF1E293B);
  static const Color sidebarSelected = Color(0xFF2563EB);
  static const Color sidebarText = Color(0xFFCBD5E1);
  static const Color sidebarTextSelected = Color(0xFFFFFFFF);

  // Status colors
  static const Color statusPresent = Color(0xFF10B981);
  static const Color statusLate = Color(0xFFF59E0B);
  static const Color statusAbsent = Color(0xFFEF4444);
  static const Color statusHalfDay = Color(0xFF8B5CF6);
  static const Color statusOvertime = Color(0xFF3B82F6);
  static const Color statusOnLeave = Color(0xFF06B6D4);

  // Leave type colors
  static const Color leaveVacation = Color(0xFF3B82F6);
  static const Color leaveSick = Color(0xFFEF4444);
  static const Color leaveEmergency = Color(0xFFF97316);
  static const Color leaveMaternity = Color(0xFFEC4899);
  static const Color leavePaternity = Color(0xFF6366F1);
  static const Color leaveWithoutPay = Color(0xFF6B7280);

  // Gradient helpers
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
