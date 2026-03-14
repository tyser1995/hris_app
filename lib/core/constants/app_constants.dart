class AppConstants {
  AppConstants._();

  // Supabase table names
  static const String tableEmployees = 'employees';
  static const String tableAttendance = 'attendance';
  static const String tableLeaveRequests = 'leave_requests';
  static const String tableLeaveBalances = 'leave_balances';
  static const String tableDepartments = 'departments';
  static const String tablePositions = 'positions';
  static const String tableSchedules = 'schedules';
  static const String tableScheduleDetails = 'schedule_details';
  static const String tableNotifications = 'notifications';
  static const String tableUserRoles = 'user_roles';
  static const String tableDocuments = 'employee_documents';
  static const String tableCompanySettings = 'company_settings';
  static const String tableOrganizations = 'organizations';
  static const String tableEmploymentTypes = 'employment_types';

  // Pagination
  static const int pageSize = 50;

  // Supabase storage buckets
  static const String bucketDocuments = 'employee-documents';
  static const String bucketAvatars = 'avatars';
  static const String bucketLogos = 'logos';

  // Supabase edge functions
  static const String fnComputeAttendance = 'compute-attendance';
  static const String fnApproveLeave = 'approve-leave';
  static const String fnNotifyTrigger = 'notify-trigger';
  static const String fnPayrollExport = 'payroll-export';
  static const String fnGenerateEmployeeCode = 'generate-employee-code';
  static const String fnCreateAdminUser = 'create-admin-user';
  static const String fnDeleteOrganization = 'delete-organization';
  static const String fnInviteUser = 'invite-user';
  static const String fnCreateUser = 'create-user';

  // Grace period for late computation (minutes)
  static const int gracePeriodMinutes = 15;

  // Overtime threshold (minutes after shift end)
  static const int overtimeThresholdMinutes = 30;
}
