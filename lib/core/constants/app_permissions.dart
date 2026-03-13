import 'package:flutter/material.dart';

// ─── Permission definition models ────────────────────────────────────────────

class AppPermission {
  final String key;
  final String label;
  final String description;

  const AppPermission({
    required this.key,
    required this.label,
    required this.description,
  });
}

class PermissionGroup {
  final String label;
  final IconData icon;
  final Color color;
  final List<AppPermission> permissions;

  const PermissionGroup({
    required this.label,
    required this.icon,
    required this.color,
    required this.permissions,
  });
}

// ─── Role metadata ────────────────────────────────────────────────────────────

class RoleInfo {
  final String key;
  final String label;
  final String description;
  final Color color;

  const RoleInfo({
    required this.key,
    required this.label,
    required this.description,
    required this.color,
  });
}

// ─── Permissions registry ─────────────────────────────────────────────────────

class AppPermissions {
  AppPermissions._();

  // ── Role definitions (display order) ─────────────────────────────────────

  static const List<RoleInfo> roles = [
    RoleInfo(
      key: 'admin',
      label: 'Admin',
      description: 'Full system access — cannot be restricted',
      color: Color(0xFF7C3AED),
    ),
    RoleInfo(
      key: 'hr_staff',
      label: 'HR Staff',
      description: 'Manages employees, attendance and leave',
      color: Color(0xFF2563EB),
    ),
    RoleInfo(
      key: 'department_head',
      label: 'Dept Head',
      description: 'Oversees their department',
      color: Color(0xFF059669),
    ),
    RoleInfo(
      key: 'supervisor',
      label: 'Supervisor',
      description: 'Team-level oversight',
      color: Color(0xFFF59E0B),
    ),
    RoleInfo(
      key: 'employee',
      label: 'Employee',
      description: 'Basic self-service access',
      color: Color(0xFF64748B),
    ),
  ];

  // ── Permission groups (display order) ─────────────────────────────────────

  static const List<PermissionGroup> groups = [
    PermissionGroup(
      label: 'Employees',
      icon: Icons.people_outline_rounded,
      color: Color(0xFF2563EB),
      permissions: [
        AppPermission(
          key: 'employees.view',
          label: 'View Employees',
          description: 'See the employee list and individual profiles',
        ),
        AppPermission(
          key: 'employees.create',
          label: 'Add Employees',
          description: 'Create new employee records',
        ),
        AppPermission(
          key: 'employees.edit',
          label: 'Edit Employees',
          description: 'Update employee information',
        ),
        AppPermission(
          key: 'employees.delete',
          label: 'Delete Employees',
          description: 'Permanently remove employee records',
        ),
      ],
    ),
    PermissionGroup(
      label: 'Attendance',
      icon: Icons.access_time_outlined,
      color: Color(0xFF059669),
      permissions: [
        AppPermission(
          key: 'attendance.view',
          label: 'View Attendance',
          description: 'See attendance records and logs',
        ),
        AppPermission(
          key: 'attendance.manage',
          label: 'Manage Attendance',
          description: 'Edit, correct, and process attendance entries',
        ),
      ],
    ),
    PermissionGroup(
      label: 'Leave',
      icon: Icons.event_available_outlined,
      color: Color(0xFF06B6D4),
      permissions: [
        AppPermission(
          key: 'leave.view',
          label: 'View Leave',
          description: 'See leave requests and balance summaries',
        ),
        AppPermission(
          key: 'leave.request',
          label: 'Request Leave',
          description: 'Submit leave applications',
        ),
        AppPermission(
          key: 'leave.approve',
          label: 'Approve Leave',
          description: 'Approve or reject leave requests',
        ),
      ],
    ),
    PermissionGroup(
      label: 'Scheduling',
      icon: Icons.calendar_month_outlined,
      color: Color(0xFF8B5CF6),
      permissions: [
        AppPermission(
          key: 'scheduling.view',
          label: 'View Schedules',
          description: 'Browse shift schedules',
        ),
        AppPermission(
          key: 'scheduling.manage',
          label: 'Manage Schedules',
          description: 'Create, edit, and delete shift schedules',
        ),
      ],
    ),
    PermissionGroup(
      label: 'Reports',
      icon: Icons.bar_chart_rounded,
      color: Color(0xFFF59E0B),
      permissions: [
        AppPermission(
          key: 'reports.view',
          label: 'View Reports',
          description: 'Access the reports and analytics section',
        ),
        AppPermission(
          key: 'reports.export',
          label: 'Export Reports',
          description: 'Download and export report data',
        ),
      ],
    ),
    PermissionGroup(
      label: 'Notifications',
      icon: Icons.notifications_outlined,
      color: Color(0xFFEF4444),
      permissions: [
        AppPermission(
          key: 'notifications.view',
          label: 'View Notifications',
          description: 'Receive and read system notifications',
        ),
      ],
    ),
    PermissionGroup(
      label: 'Settings',
      icon: Icons.settings_outlined,
      color: Color(0xFF64748B),
      permissions: [
        AppPermission(
          key: 'settings.view',
          label: 'Access Settings',
          description: 'Open the Settings configuration screen',
        ),
      ],
    ),
  ];

  // ── Default permission matrix ──────────────────────────────────────────────

  static const Map<String, Map<String, bool>> defaults = {
    'admin': {
      'employees.view': true,
      'employees.create': true,
      'employees.edit': true,
      'employees.delete': true,
      'attendance.view': true,
      'attendance.manage': true,
      'leave.view': true,
      'leave.request': true,
      'leave.approve': true,
      'scheduling.view': true,
      'scheduling.manage': true,
      'reports.view': true,
      'reports.export': true,
      'notifications.view': true,
      'settings.view': true,
    },
    'hr_staff': {
      'employees.view': true,
      'employees.create': true,
      'employees.edit': true,
      'employees.delete': false,
      'attendance.view': true,
      'attendance.manage': true,
      'leave.view': true,
      'leave.request': true,
      'leave.approve': true,
      'scheduling.view': true,
      'scheduling.manage': false,
      'reports.view': true,
      'reports.export': true,
      'notifications.view': true,
      'settings.view': true,
    },
    'department_head': {
      'employees.view': true,
      'employees.create': false,
      'employees.edit': false,
      'employees.delete': false,
      'attendance.view': true,
      'attendance.manage': false,
      'leave.view': true,
      'leave.request': true,
      'leave.approve': true,
      'scheduling.view': true,
      'scheduling.manage': false,
      'reports.view': true,
      'reports.export': false,
      'notifications.view': true,
      'settings.view': false,
    },
    'supervisor': {
      'employees.view': true,
      'employees.create': false,
      'employees.edit': false,
      'employees.delete': false,
      'attendance.view': true,
      'attendance.manage': false,
      'leave.view': true,
      'leave.request': true,
      'leave.approve': true,
      'scheduling.view': true,
      'scheduling.manage': false,
      'reports.view': false,
      'reports.export': false,
      'notifications.view': true,
      'settings.view': false,
    },
    'employee': {
      'employees.view': false,
      'employees.create': false,
      'employees.edit': false,
      'employees.delete': false,
      'attendance.view': true,
      'attendance.manage': false,
      'leave.view': true,
      'leave.request': true,
      'leave.approve': false,
      'scheduling.view': false,
      'scheduling.manage': false,
      'reports.view': false,
      'reports.export': false,
      'notifications.view': true,
      'settings.view': false,
    },
  };

  /// All permission keys as a flat list.
  static List<String> get allKeys =>
      groups.expand((g) => g.permissions.map((p) => p.key)).toList();
}
