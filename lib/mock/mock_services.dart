import 'dart:typed_data';
import '../core/constants/app_permissions.dart';
import '../models/attendance_model.dart';
import '../models/company_settings_model.dart';
import '../models/department_model.dart';
import '../models/employee_model.dart';
import '../models/leave_request_model.dart';
import '../models/notification_model.dart';
import '../models/org_user_model.dart';
import '../models/organization_model.dart';
import '../models/position_model.dart';
import '../services/attendance_service.dart';
import '../services/department_service.dart';
import '../services/employee_service.dart';
import '../services/leave_service.dart';
import '../services/notification_service.dart';
import '../services/organization_service.dart';
import '../services/permission_service.dart';
import '../services/settings_service.dart';
import '../services/user_management_service.dart';
import 'mock_data_store.dart';

// ─── Employee ─────────────────────────────────────────────────────────────────

class MockEmployeeService extends EmployeeService {
  @override
  Future<List<EmployeeModel>> getEmployees({
    int page = 0,
    String? search,
    String? departmentId,
    String? employmentType,
    String? status,
  }) async {
    var list = MockDataStore.employees
        .where((e) => e.employmentStatus == (status ?? 'active'))
        .toList();

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list
          .where((e) =>
              e.firstName.toLowerCase().contains(q) ||
              e.lastName.toLowerCase().contains(q) ||
              e.employeeCode.toLowerCase().contains(q) ||
              e.email.toLowerCase().contains(q))
          .toList();
    }
    if (departmentId != null) {
      list = list.where((e) => e.departmentId == departmentId).toList();
    }
    if (employmentType != null) {
      list = list.where((e) => e.employmentType == employmentType).toList();
    }

    list.sort((a, b) => a.lastName.compareTo(b.lastName));

    const pageSize = 50;
    final offset = page * pageSize;
    final end = (offset + pageSize).clamp(0, list.length);
    return offset >= list.length ? [] : list.sublist(offset, end);
  }

  @override
  Future<EmployeeModel?> getEmployee(String id) async =>
      MockDataStore.getEmployee(id);

  @override
  Future<EmployeeModel> createEmployee(Map<String, dynamic> payload) async {
    final code = payload['employee_code'] as String? ?? 'DEMO-NEW';
    return EmployeeModel(
      id: 'emp-new-${DateTime.now().millisecondsSinceEpoch}',
      employeeCode: code,
      firstName: payload['first_name'] as String? ?? 'New',
      lastName: payload['last_name'] as String? ?? 'Employee',
      employmentType: payload['employment_type'] as String? ?? 'regular',
      hireDate: DateTime.now(),
      employmentStatus: 'active',
      email: payload['email'] as String? ?? 'new@hris.demo',
    );
  }

  @override
  Future<EmployeeModel> updateEmployee(
      String id, Map<String, dynamic> payload) async {
    final existing = MockDataStore.getEmployee(id);
    if (existing == null) return createEmployee(payload);
    return existing.copyWith(
      firstName: payload['first_name'] as String? ?? existing.firstName,
      lastName: payload['last_name'] as String? ?? existing.lastName,
    );
  }

  @override
  Future<int> getTotalCount({String status = 'active'}) async =>
      MockDataStore.employees
          .where((e) => e.employmentStatus == status)
          .length;

  @override
  Future<List<EmployeeModel>> getExpiringContracts({int daysAhead = 30}) async {
    final cutoff = DateTime.now().add(Duration(days: daysAhead));
    final today = DateTime.now();
    return MockDataStore.employees.where((e) {
      if (e.contractEnd == null) return false;
      return e.contractEnd!.isAfter(today) &&
          e.contractEnd!.isBefore(cutoff) &&
          e.employmentStatus == 'active';
    }).toList()
      ..sort((a, b) => a.contractEnd!.compareTo(b.contractEnd!));
  }
}

// ─── Leave ────────────────────────────────────────────────────────────────────

class MockLeaveService extends LeaveService {
  @override
  Future<List<LeaveRequestModel>> getLeaveRequests({
    String? employeeId,
    String? status,
    int page = 0,
  }) async {
    var list = MockDataStore.leaveRequests;
    if (employeeId != null) {
      list = list.where((l) => l.employeeId == employeeId).toList();
    }
    if (status != null) {
      list = list.where((l) => l.status == status).toList();
    }
    list.sort((a, b) => (b.createdAt ?? DateTime(0))
        .compareTo(a.createdAt ?? DateTime(0)));
    const pageSize = 50;
    final offset = page * pageSize;
    final end = (offset + pageSize).clamp(0, list.length);
    return offset >= list.length ? [] : list.sublist(offset, end);
  }

  @override
  Future<LeaveRequestModel> createLeaveRequest({
    required String employeeId,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required double daysRequested,
    String? reason,
  }) async {
    final emp = MockDataStore.getEmployee(employeeId);
    return LeaveRequestModel(
      id: 'leave-new-${DateTime.now().millisecondsSinceEpoch}',
      employeeId: employeeId,
      employeeFullName: emp?.fullName,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      daysRequested: daysRequested,
      reason: reason,
      status: 'pending_supervisor',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> approveLeave({
    required String leaveId,
    required String action,
    required String approverId,
    required String level,
    String? remarks,
  }) async {
    // No-op in demo mode
  }

  @override
  Future<Map<String, double>> getLeaveBalances(
          String employeeId, int year) async =>
      MockDataStore.leaveBalancesFor(employeeId);
}

// ─── Attendance ───────────────────────────────────────────────────────────────

class MockAttendanceService extends AttendanceService {
  @override
  Future<AttendanceModel?> getTodayAttendance(String employeeId) async =>
      MockDataStore.getTodayAttendanceFor(employeeId);

  @override
  Future<AttendanceModel> checkIn({
    required String employeeId,
    required String scheduleId,
    String source = 'mobile',
  }) async {
    final emp = MockDataStore.getEmployee(employeeId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return AttendanceModel(
      id: 'att-demo-${DateTime.now().millisecondsSinceEpoch}',
      employeeId: employeeId,
      employeeCode: emp?.employeeCode,
      employeeFullName: emp?.fullName,
      date: today,
      timeIn: now,
      status: 'present',
      source: source,
    );
  }

  @override
  Future<AttendanceModel> checkOut(String attendanceId) async {
    final existing = MockDataStore.todayAttendance
        .cast<AttendanceModel?>()
        .firstWhere((a) => a?.id == attendanceId, orElse: () => null);
    if (existing != null) {
      return existing.copyWith(timeOut: DateTime.now());
    }
    return AttendanceModel(
      id: attendanceId,
      employeeId: '',
      date: DateTime.now(),
      timeOut: DateTime.now(),
      status: 'present',
    );
  }

  @override
  Future<List<AttendanceModel>> getAttendanceByDate(DateTime date) async {
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    if (d == t) return MockDataStore.todayAttendance;
    // Return a slightly randomized historical list for other dates
    return MockDataStore.todayAttendance.map((a) => a.copyWith(date: d)).toList();
  }

  @override
  Future<List<AttendanceModel>> getEmployeeAttendance(
    String employeeId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Generate 14 days of history for this employee
    final List<AttendanceModel> result = [];
    final emp = MockDataStore.getEmployee(employeeId);
    var current = startDate;
    int i = 0;
    while (!current.isAfter(endDate)) {
      // Skip weekends
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        final today = DateTime.now();
        final t = DateTime(today.year, today.month, today.day);
        final d = DateTime(current.year, current.month, current.day);
        if (d == t) {
          final todayRecord = MockDataStore.getTodayAttendanceFor(employeeId);
          if (todayRecord != null) result.add(todayRecord);
        } else {
          // Occasionally absent (every ~10th working day)
          if (i % 10 != 7) {
            result.add(AttendanceModel(
              id: 'hist-$employeeId-$i',
              employeeId: employeeId,
              employeeCode: emp?.employeeCode,
              employeeFullName: emp?.fullName,
              date: d,
              timeIn: d.add(Duration(hours: 8, minutes: (i * 7) % 30)),
              timeOut: d.add(const Duration(hours: 17)),
              status: 'present',
              source: 'web',
            ));
          }
        }
        i++;
      }
      current = current.add(const Duration(days: 1));
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  @override
  Stream<List<AttendanceModel>> streamTodayAttendance() =>
      Stream.value(MockDataStore.todayAttendance);
}

// ─── Notification ─────────────────────────────────────────────────────────────

class MockNotificationService extends NotificationService {
  // Mutable in-session state for read status
  final _readIds = <String>{};

  @override
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    bool unreadOnly = false,
    int page = 0,
  }) async {
    var list = MockDataStore.notifications
        .map((n) => _readIds.contains(n.id) ? n.copyWith(isRead: true) : n)
        .toList();
    if (unreadOnly) list = list.where((n) => !n.isRead).toList();
    return list;
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return MockDataStore.notifications
        .where((n) => !n.isRead && !_readIds.contains(n.id))
        .length;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    _readIds.add(notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    _readIds.addAll(MockDataStore.notifications.map((n) => n.id));
  }

  @override
  Stream<List<NotificationModel>> streamUnread(String userId) =>
      Stream.value(MockDataStore.unreadNotifications);
}

// ─── Department ───────────────────────────────────────────────────────────────

class MockDepartmentService extends DepartmentService {
  @override
  Future<List<DepartmentModel>> getDepartments() async =>
      MockDataStore.departments;

  @override
  Future<DepartmentModel> createDepartment(String name,
      {String? headId}) async {
    return DepartmentModel(
      id: 'dept-new-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      headId: headId,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<PositionModel>> getPositions({String? departmentId}) async {
    if (departmentId == null) return MockDataStore.positions;
    return MockDataStore.positions
        .where((p) => p.departmentId == departmentId)
        .toList();
  }

  @override
  Future<PositionModel> createPosition(String title,
      {String? departmentId}) async {
    return PositionModel(
      id: 'pos-new-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      departmentId: departmentId,
      createdAt: DateTime.now(),
    );
  }
}

// ─── Settings ─────────────────────────────────────────────────────────────────

class MockSettingsService extends SettingsService {
  CompanySettingsModel _settings = MockDataStore.settings;
  int _seq = MockDataStore.settings.employeeCodeSequence;

  @override
  Future<CompanySettingsModel> getSettings() async => _settings;

  @override
  Future<CompanySettingsModel> updatePattern(String pattern,
      {String? organizationId}) async {
    _settings = _settings.copyWith(employeeCodePattern: pattern);
    return _settings;
  }

  @override
  Future<CompanySettingsModel> updateBranding({
    String? organizationId,
    String? systemTitle,
    String? primaryColor,
    String? logoUrl,
  }) async {
    _settings = _settings.copyWith(
      systemTitle: systemTitle,
      primaryColor: primaryColor,
      logoUrl: logoUrl,
    );
    return _settings;
  }

  @override
  Future<String> uploadLogo(Uint8List bytes, String fileName) async {
    // In mock mode, return a placeholder — no actual upload.
    return 'https://placehold.co/64x64/2563EB/FFFFFF?text=Logo';
  }

  @override
  Future<void> resetSequence({String? organizationId}) async {
    _seq = 0;
    _settings = _settings.copyWith(employeeCodeSequence: 0);
  }

  @override
  Future<String> previewNextCode() async {
    final pattern = _settings.employeeCodePattern;
    final seq = _seq + 1;
    final now = DateTime.now();
    // Simple substitution preview
    return _applyPattern(pattern, seq, now);
  }

  @override
  Future<String> incrementAndGetCode() async {
    _seq++;
    _settings = _settings.copyWith(employeeCodeSequence: _seq);
    final now = DateTime.now();
    return _applyPattern(_settings.employeeCodePattern, _seq, now);
  }

  String _applyPattern(String pattern, int seq, DateTime now) {
    return pattern
        .replaceAll('YYYY', now.year.toString())
        .replaceAll('YY', now.year.toString().substring(2))
        .replaceAll('MM', now.month.toString().padLeft(2, '0'))
        .replaceAll('DD', now.day.toString().padLeft(2, '0'))
        .replaceAll('####', seq.toString().padLeft(4, '0'))
        .replaceAll('###', seq.toString().padLeft(3, '0'));
  }
}

// ─── User Management ──────────────────────────────────────────────────────────

class MockUserManagementService extends UserManagementService {
  final _extraUsers = <OrgUserModel>[];

  @override
  Future<List<OrgUserModel>> getOrgUsers() async =>
      [...MockDataStore.orgUsers, ..._extraUsers];

  @override
  Future<OrgUserModel> createUser({
    required String email,
    String? password,
    required bool autoConfirm,
    required String role,
    required String organizationId,
  }) async {
    final user = OrgUserModel(
      userId: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      role: role,
      organizationId: organizationId,
      createdAt: DateTime.now(),
      emailConfirmedAt: autoConfirm ? DateTime.now() : null,
    );
    _extraUsers.add(user);
    return user;
  }

  @override
  Future<OrgUserModel> inviteUser({
    required String email,
    required String role,
  }) async {
    final user = OrgUserModel(
      userId: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      role: role,
      organizationId: 'org-demo',
      createdAt: DateTime.now(),
      // emailConfirmedAt null — invite pending
    );
    _extraUsers.add(user);
    return user;
  }
}

// ─── Organization ─────────────────────────────────────────────────────────────

class MockOrganizationService extends OrganizationService {
  final _extraOrgs = <OrganizationModel>[];

  @override
  Future<List<OrganizationModel>> getOrganizations() async =>
      [...MockDataStore.organizations, ..._extraOrgs];

  @override
  Future<Map<String, dynamic>> createAdminAccount({
    required String orgName,
    required String email,
    bool autoConfirm = false,
    String? password,
  }) async {
    final now = DateTime.now();
    final org = OrganizationModel(
      id: 'org-${now.millisecondsSinceEpoch}',
      name: orgName,
      systemTitle: '$orgName HRIS',
      employeeCodePattern: 'YY-###',
      employeeCodeSequence: 0,
      createdAt: now,
    );
    _extraOrgs.add(org);
    return {
      'organization': {
        'id': org.id,
        'name': org.name,
        'systemTitle': org.systemTitle,
      },
      'user': {
        'id': 'mock-admin-${now.millisecondsSinceEpoch}',
        'email': email,
      },
      'message': autoConfirm
          ? 'Admin account for $email created. They can log in immediately.'
          : 'Invitation email sent to $email.',
    };
  }
}

// ─── Permission ───────────────────────────────────────────────────────────────

class MockPermissionService extends PermissionService {
  // In-memory mutable permission state (final ref, mutable contents)
  final _permissions = <String, Map<String, bool>>{
    for (final entry in AppPermissions.defaults.entries)
      entry.key: Map<String, bool>.from(entry.value),
  };

  @override
  Future<Map<String, Map<String, bool>>> getAllRolePermissions() async =>
      _permissions;

  @override
  Future<void> updatePermission(
      String role, String permissionKey, bool granted) async {
    _permissions[role] = {
      ...(_permissions[role] ?? {}),
      permissionKey: granted,
    };
  }

  @override
  Future<void> resetRoleToDefaults(String role) async {
    final defaults = AppPermissions.defaults[role];
    if (defaults != null) {
      _permissions[role] = Map<String, bool>.from(defaults);
    }
  }
}
