import '../models/attendance_model.dart';
import '../models/company_settings_model.dart';
import '../models/department_model.dart';
import '../models/employee_model.dart';
import '../models/leave_request_model.dart';
import '../models/notification_model.dart';
import '../models/org_user_model.dart';
import '../models/organization_model.dart';
import '../models/position_model.dart';

/// Central store of all in-memory mock data used in demo mode.
///
/// IDs use a simple `mock-*` prefix — valid as URL path segments and
/// unique across all entity types.
class MockDataStore {
  MockDataStore._();

  // ─── Auth ─────────────────────────────────────────────────────────────────

  static const String adminUserId = 'mock-user-admin';
  static const String adminEmployeeId = 'emp-001';

  // ─── Departments ──────────────────────────────────────────────────────────

  static final departments = <DepartmentModel>[
    DepartmentModel(
      id: 'dept-hr',
      name: 'Human Resources',
      headId: 'emp-001',
      headFullName: 'Maria Santos',
      createdAt: DateTime(2020, 1, 1),
    ),
    DepartmentModel(
      id: 'dept-it',
      name: 'Information Technology',
      headId: 'emp-003',
      headFullName: 'Ana Reyes',
      createdAt: DateTime(2020, 1, 1),
    ),
    DepartmentModel(
      id: 'dept-fin',
      name: 'Finance',
      headId: 'emp-006',
      headFullName: 'Jun Mendoza',
      createdAt: DateTime(2020, 1, 1),
    ),
    DepartmentModel(
      id: 'dept-ops',
      name: 'Operations',
      headId: 'emp-008',
      headFullName: 'Diego Flores',
      createdAt: DateTime(2020, 1, 1),
    ),
  ];

  // ─── Positions ────────────────────────────────────────────────────────────

  static final positions = <PositionModel>[
    PositionModel(id: 'pos-hr-mgr', title: 'HR Manager', departmentId: 'dept-hr'),
    PositionModel(id: 'pos-hr-staff', title: 'HR Staff', departmentId: 'dept-hr'),
    PositionModel(id: 'pos-it-mgr', title: 'IT Manager', departmentId: 'dept-it'),
    PositionModel(id: 'pos-swe', title: 'Software Engineer', departmentId: 'dept-it'),
    PositionModel(id: 'pos-it-support', title: 'IT Support', departmentId: 'dept-it'),
    PositionModel(id: 'pos-fin-mgr', title: 'Finance Manager', departmentId: 'dept-fin'),
    PositionModel(id: 'pos-accountant', title: 'Accountant', departmentId: 'dept-fin'),
    PositionModel(id: 'pos-ops-mgr', title: 'Operations Manager', departmentId: 'dept-ops'),
    PositionModel(id: 'pos-ops-staff', title: 'Operations Staff', departmentId: 'dept-ops'),
  ];

  // ─── Employees (20 total) ─────────────────────────────────────────────────

  static final employees = <EmployeeModel>[
    // ── Human Resources (5) ──
    EmployeeModel(
      id: 'emp-001',
      userId: adminUserId,
      employeeCode: '24-E001',
      firstName: 'Maria',
      lastName: 'Santos',
      employmentType: 'regular',
      departmentId: 'dept-hr',
      departmentName: 'Human Resources',
      positionId: 'pos-hr-mgr',
      positionTitle: 'HR Manager',
      hireDate: DateTime(2020, 1, 15),
      employmentStatus: 'active',
      email: 'maria.santos@hris.demo',
      phone: '09171234001',
    ),
    EmployeeModel(
      id: 'emp-002',
      employeeCode: '24-E002',
      firstName: 'Jose',
      lastName: 'Cruz',
      employmentType: 'regular',
      departmentId: 'dept-hr',
      departmentName: 'Human Resources',
      positionId: 'pos-hr-staff',
      positionTitle: 'HR Staff',
      supervisorId: 'emp-001',
      hireDate: DateTime(2021, 3, 10),
      employmentStatus: 'active',
      email: 'jose.cruz@hris.demo',
      phone: '09171234002',
    ),
    EmployeeModel(
      id: 'emp-011',
      employeeCode: '24-E011',
      firstName: 'Noel',
      lastName: 'dela Cruz',
      employmentType: 'regular',
      departmentId: 'dept-hr',
      departmentName: 'Human Resources',
      positionId: 'pos-hr-staff',
      positionTitle: 'HR Staff',
      supervisorId: 'emp-001',
      hireDate: DateTime(2022, 6, 1),
      employmentStatus: 'active',
      email: 'noel.delacruz@hris.demo',
      phone: '09171234011',
    ),
    EmployeeModel(
      id: 'emp-016',
      employeeCode: '24-E016',
      firstName: 'Ben',
      lastName: 'Corpuz',
      employmentType: 'probationary',
      departmentId: 'dept-hr',
      departmentName: 'Human Resources',
      positionId: 'pos-hr-staff',
      positionTitle: 'HR Staff',
      supervisorId: 'emp-001',
      hireDate: DateTime(2025, 9, 1),
      employmentStatus: 'active',
      email: 'ben.corpuz@hris.demo',
      phone: '09171234016',
    ),
    EmployeeModel(
      id: 'emp-020',
      employeeCode: '24-E020',
      firstName: 'Mia',
      lastName: 'Reyes',
      employmentType: 'regular',
      departmentId: 'dept-hr',
      departmentName: 'Human Resources',
      positionId: 'pos-hr-staff',
      positionTitle: 'HR Staff',
      supervisorId: 'emp-001',
      hireDate: DateTime(2023, 2, 15),
      employmentStatus: 'active',
      email: 'mia.reyes@hris.demo',
      phone: '09171234020',
    ),

    // ── Information Technology (5) ──
    EmployeeModel(
      id: 'emp-003',
      employeeCode: '24-E003',
      firstName: 'Ana',
      lastName: 'Reyes',
      employmentType: 'regular',
      departmentId: 'dept-it',
      departmentName: 'Information Technology',
      positionId: 'pos-it-mgr',
      positionTitle: 'IT Manager',
      supervisorId: 'emp-001',
      hireDate: DateTime(2020, 2, 1),
      employmentStatus: 'active',
      email: 'ana.reyes@hris.demo',
      phone: '09171234003',
    ),
    EmployeeModel(
      id: 'emp-004',
      employeeCode: '24-E004',
      firstName: 'Ben',
      lastName: 'Garcia',
      employmentType: 'regular',
      departmentId: 'dept-it',
      departmentName: 'Information Technology',
      positionId: 'pos-swe',
      positionTitle: 'Software Engineer',
      supervisorId: 'emp-003',
      hireDate: DateTime(2021, 5, 17),
      employmentStatus: 'active',
      email: 'ben.garcia@hris.demo',
      phone: '09171234004',
    ),
    EmployeeModel(
      id: 'emp-005',
      employeeCode: '24-E005',
      firstName: 'Carlo',
      lastName: 'Lim',
      employmentType: 'regular',
      departmentId: 'dept-it',
      departmentName: 'Information Technology',
      positionId: 'pos-it-support',
      positionTitle: 'IT Support',
      supervisorId: 'emp-003',
      hireDate: DateTime(2022, 1, 10),
      employmentStatus: 'active',
      email: 'carlo.lim@hris.demo',
      phone: '09171234005',
    ),
    EmployeeModel(
      id: 'emp-012',
      employeeCode: '24-E012',
      firstName: 'Nina',
      lastName: 'Castillo',
      employmentType: 'regular',
      departmentId: 'dept-it',
      departmentName: 'Information Technology',
      positionId: 'pos-it-support',
      positionTitle: 'IT Support',
      supervisorId: 'emp-003',
      hireDate: DateTime(2023, 8, 1),
      employmentStatus: 'active',
      email: 'nina.castillo@hris.demo',
      phone: '09171234012',
    ),
    EmployeeModel(
      id: 'emp-014',
      employeeCode: '24-E014',
      firstName: 'Mark',
      lastName: 'Tan',
      employmentType: 'regular',
      departmentId: 'dept-it',
      departmentName: 'Information Technology',
      positionId: 'pos-swe',
      positionTitle: 'Software Engineer',
      supervisorId: 'emp-003',
      hireDate: DateTime(2022, 4, 20),
      employmentStatus: 'active',
      email: 'mark.tan@hris.demo',
      phone: '09171234014',
    ),

    // ── Finance (4) ──
    EmployeeModel(
      id: 'emp-006',
      employeeCode: '24-E006',
      firstName: 'Jun',
      lastName: 'Mendoza',
      employmentType: 'regular',
      departmentId: 'dept-fin',
      departmentName: 'Finance',
      positionId: 'pos-fin-mgr',
      positionTitle: 'Finance Manager',
      supervisorId: 'emp-001',
      hireDate: DateTime(2020, 3, 1),
      employmentStatus: 'active',
      email: 'jun.mendoza@hris.demo',
      phone: '09171234006',
    ),
    EmployeeModel(
      id: 'emp-007',
      employeeCode: '24-E007',
      firstName: 'Luz',
      lastName: 'Torres',
      employmentType: 'regular',
      departmentId: 'dept-fin',
      departmentName: 'Finance',
      positionId: 'pos-accountant',
      positionTitle: 'Accountant',
      supervisorId: 'emp-006',
      hireDate: DateTime(2021, 7, 5),
      employmentStatus: 'active',
      email: 'luz.torres@hris.demo',
      phone: '09171234007',
    ),
    EmployeeModel(
      id: 'emp-013',
      employeeCode: '24-E013',
      firstName: 'Dave',
      lastName: 'Morales',
      employmentType: 'regular',
      departmentId: 'dept-fin',
      departmentName: 'Finance',
      positionId: 'pos-accountant',
      positionTitle: 'Accountant',
      supervisorId: 'emp-006',
      hireDate: DateTime(2023, 1, 16),
      employmentStatus: 'active',
      email: 'dave.morales@hris.demo',
      phone: '09171234013',
    ),
    EmployeeModel(
      id: 'emp-017',
      employeeCode: '24-E017',
      firstName: 'Lena',
      lastName: 'Magtoto',
      employmentType: 'regular',
      departmentId: 'dept-fin',
      departmentName: 'Finance',
      positionId: 'pos-accountant',
      positionTitle: 'Accountant',
      supervisorId: 'emp-006',
      hireDate: DateTime(2022, 10, 3),
      employmentStatus: 'active',
      email: 'lena.magtoto@hris.demo',
      phone: '09171234017',
    ),

    // ── Operations (6) ──
    EmployeeModel(
      id: 'emp-008',
      employeeCode: '24-E008',
      firstName: 'Diego',
      lastName: 'Flores',
      employmentType: 'regular',
      departmentId: 'dept-ops',
      departmentName: 'Operations',
      positionId: 'pos-ops-mgr',
      positionTitle: 'Operations Manager',
      supervisorId: 'emp-001',
      hireDate: DateTime(2020, 4, 1),
      employmentStatus: 'active',
      email: 'diego.flores@hris.demo',
      phone: '09171234008',
    ),
    EmployeeModel(
      id: 'emp-009',
      employeeCode: '24-E009',
      firstName: 'Rosa',
      lastName: 'Villanueva',
      employmentType: 'regular',
      departmentId: 'dept-ops',
      departmentName: 'Operations',
      positionId: 'pos-ops-staff',
      positionTitle: 'Operations Staff',
      supervisorId: 'emp-008',
      hireDate: DateTime(2021, 9, 1),
      employmentStatus: 'active',
      email: 'rosa.villanueva@hris.demo',
      phone: '09171234009',
    ),
    EmployeeModel(
      id: 'emp-010',
      employeeCode: '24-E010',
      firstName: 'Mario',
      lastName: 'Aquino',
      employmentType: 'regular',
      departmentId: 'dept-ops',
      departmentName: 'Operations',
      positionId: 'pos-ops-staff',
      positionTitle: 'Operations Staff',
      supervisorId: 'emp-008',
      hireDate: DateTime(2022, 2, 14),
      employmentStatus: 'active',
      email: 'mario.aquino@hris.demo',
      phone: '09171234010',
    ),
    EmployeeModel(
      id: 'emp-015',
      employeeCode: '24-E015',
      firstName: 'Alan',
      lastName: 'Pascual',
      employmentType: 'regular',
      departmentId: 'dept-ops',
      departmentName: 'Operations',
      positionId: 'pos-ops-staff',
      positionTitle: 'Operations Staff',
      supervisorId: 'emp-008',
      hireDate: DateTime(2023, 3, 7),
      employmentStatus: 'active',
      email: 'alan.pascual@hris.demo',
      phone: '09171234015',
    ),
    EmployeeModel(
      id: 'emp-018',
      employeeCode: '24-E018',
      firstName: 'Ramon',
      lastName: 'Santos',
      employmentType: 'regular',
      departmentId: 'dept-ops',
      departmentName: 'Operations',
      positionId: 'pos-ops-staff',
      positionTitle: 'Operations Staff',
      supervisorId: 'emp-008',
      hireDate: DateTime(2022, 8, 22),
      employmentStatus: 'active',
      email: 'ramon.santos@hris.demo',
      phone: '09171234018',
    ),
    // Contract expiring soon (within 30 days)
    EmployeeModel(
      id: 'emp-019',
      employeeCode: '24-E019',
      firstName: 'Carlos',
      lastName: 'Soriano',
      employmentType: 'contractual',
      departmentId: 'dept-ops',
      departmentName: 'Operations',
      positionId: 'pos-ops-staff',
      positionTitle: 'Operations Staff',
      supervisorId: 'emp-008',
      hireDate: DateTime(2024, 9, 1),
      employmentStatus: 'active',
      email: 'carlos.soriano@hris.demo',
      phone: '09171234019',
      contractStart: DateTime(2024, 9, 1),
      contractEnd: DateTime.now().add(const Duration(days: 18)),
    ),
    // Contract expiring in 33 days (outside default 30-day window)
    EmployeeModel(
      id: 'emp-021',
      employeeCode: '24-E021',
      firstName: 'Juan',
      lastName: 'Flores',
      employmentType: 'contractual',
      departmentId: 'dept-ops',
      departmentName: 'Operations',
      positionId: 'pos-ops-staff',
      positionTitle: 'Operations Staff',
      supervisorId: 'emp-008',
      hireDate: DateTime(2024, 9, 15),
      employmentStatus: 'active',
      email: 'juan.flores@hris.demo',
      phone: '09171234021',
      contractStart: DateTime(2024, 9, 15),
      contractEnd: DateTime.now().add(const Duration(days: 33)),
    ),
  ];

  // ─── Today's Attendance ───────────────────────────────────────────────────

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static List<AttendanceModel> get todayAttendance {
    final t = _today;
    return [
      // Present (15)
      _att('att-001', 'emp-001', '24-E001', 'Maria Santos', t, 8, 2, 17, 5, 'present', 0),
      _att('att-002', 'emp-002', '24-E002', 'Jose Cruz', t, 8, 15, 17, 0, 'present', 0),
      _att('att-003', 'emp-003', '24-E003', 'Ana Reyes', t, 7, 58, 17, 2, 'present', 0),
      _att('att-004', 'emp-004', '24-E004', 'Ben Garcia', t, 8, 5, 17, 10, 'present', 0),
      _att('att-005', 'emp-005', '24-E005', 'Carlo Lim', t, 8, 20, 17, 0, 'present', 0),
      _att('att-006', 'emp-006', '24-E006', 'Jun Mendoza', t, 8, 0, 17, 5, 'present', 0),
      _att('att-007', 'emp-007', '24-E007', 'Luz Torres', t, 8, 10, 17, 0, 'present', 0),
      _att('att-008', 'emp-008', '24-E008', 'Diego Flores', t, 7, 55, 17, 8, 'present', 0),
      _att('att-009', 'emp-009', '24-E009', 'Rosa Villanueva', t, 8, 25, 17, 0, 'present', 0),
      _att('att-010', 'emp-010', '24-E010', 'Mario Aquino', t, 8, 18, 17, 5, 'present', 0),
      _att('att-011', 'emp-011', '24-E011', 'Noel dela Cruz', t, 8, 12, 17, 0, 'present', 0),
      _att('att-017', 'emp-017', '24-E017', 'Lena Magtoto', t, 8, 8, 17, 0, 'present', 0),
      _att('att-018', 'emp-018', '24-E018', 'Ramon Santos', t, 8, 16, 17, 2, 'present', 0),
      _att('att-019', 'emp-019', '24-E019', 'Carlos Soriano', t, 8, 30, 17, 0, 'present', 0),
      _att('att-021', 'emp-021', '24-E021', 'Juan Flores', t, 8, 22, 17, 0, 'present', 0),
      // Late (2)
      _att('att-014', 'emp-014', '24-E014', 'Mark Tan', t, 9, 3, 17, 30, 'late', 63),
      _att('att-015', 'emp-015', '24-E015', 'Alan Pascual', t, 9, 28, 17, 30, 'late', 88),
    ];
  }

  static AttendanceModel _att(
    String id,
    String empId,
    String empCode,
    String empName,
    DateTime date,
    int inHour,
    int inMin,
    int outHour,
    int outMin,
    String status,
    int lateMinutes,
  ) {
    return AttendanceModel(
      id: id,
      employeeId: empId,
      employeeCode: empCode,
      employeeFullName: empName,
      date: date,
      timeIn: date.add(Duration(hours: inHour, minutes: inMin)),
      timeOut: date.add(Duration(hours: outHour, minutes: outMin)),
      status: status,
      lateMinutes: lateMinutes,
      source: 'web',
    );
  }

  // ─── Leave Requests (6) ───────────────────────────────────────────────────

  static List<LeaveRequestModel> get leaveRequests {
    final today = DateTime.now();
    return [
      // Nina Castillo — approved, on leave today
      LeaveRequestModel(
        id: 'leave-001',
        employeeId: 'emp-012',
        employeeFullName: 'Nina Castillo',
        leaveType: 'vacation',
        startDate: today.subtract(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 1)),
        daysRequested: 3,
        reason: 'Family vacation',
        status: 'approved',
        createdAt: today.subtract(const Duration(days: 7)),
      ),
      // Approved — past
      LeaveRequestModel(
        id: 'leave-002',
        employeeId: 'emp-009',
        employeeFullName: 'Rosa Villanueva',
        leaveType: 'sick',
        startDate: today.subtract(const Duration(days: 14)),
        endDate: today.subtract(const Duration(days: 13)),
        daysRequested: 2,
        reason: 'Flu and fever',
        status: 'approved',
        createdAt: today.subtract(const Duration(days: 15)),
      ),
      // Approved — past
      LeaveRequestModel(
        id: 'leave-003',
        employeeId: 'emp-005',
        employeeFullName: 'Carlo Lim',
        leaveType: 'emergency',
        startDate: today.subtract(const Duration(days: 5)),
        endDate: today.subtract(const Duration(days: 4)),
        daysRequested: 2,
        reason: 'Family emergency',
        status: 'approved',
        createdAt: today.subtract(const Duration(days: 6)),
      ),
      // Pending HR approval
      LeaveRequestModel(
        id: 'leave-004',
        employeeId: 'emp-007',
        employeeFullName: 'Luz Torres',
        leaveType: 'vacation',
        startDate: today.add(const Duration(days: 5)),
        endDate: today.add(const Duration(days: 9)),
        daysRequested: 5,
        reason: 'Annual leave',
        status: 'pending_hr',
        createdAt: today.subtract(const Duration(days: 2)),
      ),
      // Pending supervisor
      LeaveRequestModel(
        id: 'leave-005',
        employeeId: 'emp-010',
        employeeFullName: 'Mario Aquino',
        leaveType: 'sick',
        startDate: today.add(const Duration(days: 2)),
        endDate: today.add(const Duration(days: 2)),
        daysRequested: 1,
        reason: 'Medical appointment',
        status: 'pending_supervisor',
        createdAt: today.subtract(const Duration(days: 1)),
      ),
      // Rejected
      LeaveRequestModel(
        id: 'leave-006',
        employeeId: 'emp-015',
        employeeFullName: 'Alan Pascual',
        leaveType: 'vacation',
        startDate: today.add(const Duration(days: 3)),
        endDate: today.add(const Duration(days: 5)),
        daysRequested: 3,
        reason: 'Out of town trip',
        status: 'rejected',
        hrRemarks: 'Peak operational period — please reschedule.',
        createdAt: today.subtract(const Duration(days: 3)),
      ),
    ];
  }

  // ─── Leave Balances ───────────────────────────────────────────────────────

  static Map<String, double> leaveBalancesFor(String employeeId) => {
        'vacation': 12,
        'sick': 8,
        'emergency': 3,
      };

  // ─── Notifications (8) ────────────────────────────────────────────────────

  static List<NotificationModel> get notifications {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'notif-001',
        userId: adminUserId,
        type: 'contract_expiry',
        title: 'Contract Expiring Soon',
        body: 'Carlos Soriano\'s contract expires in 18 days.',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'notif-002',
        userId: adminUserId,
        type: 'contract_expiry',
        title: 'Contract Expiring Soon',
        body: 'Juan Flores\'s contract expires in 33 days.',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'notif-003',
        userId: adminUserId,
        type: 'leave_pending',
        title: 'Leave Request Awaiting Approval',
        body: 'Luz Torres submitted a vacation leave request (5 days).',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 'notif-004',
        userId: adminUserId,
        type: 'leave_pending',
        title: 'Leave Request Awaiting Approval',
        body: 'Mario Aquino submitted a sick leave request (1 day).',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      NotificationModel(
        id: 'notif-005',
        userId: adminUserId,
        type: 'late_alert',
        title: 'Late Arrival Alert',
        body: 'Mark Tan checked in at 09:03 (63 minutes late).',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      NotificationModel(
        id: 'notif-006',
        userId: adminUserId,
        type: 'late_alert',
        title: 'Late Arrival Alert',
        body: 'Alan Pascual checked in at 09:28 (88 minutes late).',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      NotificationModel(
        id: 'notif-007',
        userId: adminUserId,
        type: 'leave_approved',
        title: 'Leave Request Approved',
        body: 'Nina Castillo\'s vacation leave (3 days) has been approved.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      NotificationModel(
        id: 'notif-008',
        userId: adminUserId,
        type: 'leave_rejected',
        title: 'Leave Request Rejected',
        body: 'Alan Pascual\'s vacation leave was rejected: Peak operational period.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  static List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  // ─── Organizations ────────────────────────────────────────────────────────

  static final organizations = <OrganizationModel>[
    OrganizationModel(
      id: 'org-demo',
      name: 'Demo Corporation',
      systemTitle: 'Demo Corporation HRIS',
      primaryColor: '#2563EB',
      employeeCodePattern: 'YY-E###',
      employeeCodeSequence: 21,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  // ─── Org Users ────────────────────────────────────────────────────────────

  static final orgUsers = <OrgUserModel>[
    OrgUserModel(
      userId: adminUserId,
      email: 'admin@demo.local',
      role: 'admin',
      organizationId: 'org-demo',
      organizationName: 'Demo Corporation',
      createdAt: DateTime(2024, 1, 1),
      emailConfirmedAt: DateTime(2024, 1, 1),
      lastSignInAt: DateTime(2026, 3, 14),
    ),
    OrgUserModel(
      userId: 'mock-user-hr',
      email: 'hr@demo.local',
      role: 'hr_staff',
      organizationId: 'org-demo',
      organizationName: 'Demo Corporation',
      createdAt: DateTime(2024, 2, 1),
      emailConfirmedAt: DateTime(2024, 2, 1),
      lastSignInAt: DateTime(2026, 3, 13),
    ),
    OrgUserModel(
      userId: 'mock-user-supervisor',
      email: 'supervisor@demo.local',
      role: 'supervisor',
      organizationId: 'org-demo',
      organizationName: 'Demo Corporation',
      createdAt: DateTime(2024, 3, 1),
      emailConfirmedAt: DateTime(2024, 3, 1),
      lastSignInAt: DateTime(2026, 3, 10),
    ),
    OrgUserModel(
      userId: 'mock-user-pending',
      email: 'pending@demo.local',
      role: 'employee',
      organizationId: 'org-demo',
      organizationName: 'Demo Corporation',
      createdAt: DateTime(2026, 3, 12),
      // emailConfirmedAt is null — invitation not yet accepted
    ),
  ];

  // ─── Company Settings ─────────────────────────────────────────────────────

  static const settings = CompanySettingsModel(
    employeeCodePattern: 'YY-E###',
    employeeCodeSequence: 21,
    companyName: 'Demo Corporation',
  );

  // ─── Dashboard Metrics ────────────────────────────────────────────────────
  // 21 total: 15 present + 2 late + 3 absent (Morales, Corpuz, Reyes) + 1 leave

  static const totalEmployees = 21;
  static const presentToday = 15;
  static const lateToday = 2;
  static const absentToday = 3;
  static const onLeave = 1;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static AttendanceModel? getTodayAttendanceFor(String employeeId) {
    try {
      return todayAttendance.firstWhere((a) => a.employeeId == employeeId);
    } catch (_) {
      return null;
    }
  }

  static EmployeeModel? getEmployee(String id) {
    try {
      return employees.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
