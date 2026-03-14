import 'package:flutter_test/flutter_test.dart';
import 'package:hris_app/mock/mock_data_store.dart';

void main() {
  group('MockDataStore - employees', () {
    test('has at least 20 employees', () {
      expect(MockDataStore.employees.length, greaterThanOrEqualTo(20));
    });

    test('all employees have required fields', () {
      for (final e in MockDataStore.employees) {
        expect(e.id, isNotEmpty, reason: 'id must be set');
        expect(e.employeeCode, isNotEmpty, reason: 'employeeCode must be set');
        expect(e.email, isNotEmpty, reason: 'email must be set');
        expect(e.employmentStatus, isNotEmpty);
      }
    });

    test('getEmployee returns correct employee', () {
      final emp = MockDataStore.getEmployee('emp-001');
      expect(emp, isNotNull);
      expect(emp!.firstName, 'Maria');
      expect(emp.lastName, 'Santos');
    });

    test('getEmployee returns null for unknown id', () {
      expect(MockDataStore.getEmployee('emp-999'), isNull);
    });

    test('admin employee matches adminEmployeeId', () {
      final emp = MockDataStore.getEmployee(MockDataStore.adminEmployeeId);
      expect(emp, isNotNull);
      expect(emp!.userId, MockDataStore.adminUserId);
    });

    test('contractual employees have contractEnd set', () {
      final contractual =
          MockDataStore.employees.where((e) => e.employmentType == 'contractual');
      for (final e in contractual) {
        expect(e.contractEnd, isNotNull,
            reason: '${e.id} is contractual but has no contractEnd');
      }
    });
  });

  group('MockDataStore - attendance', () {
    test('todayAttendance is non-empty', () {
      expect(MockDataStore.todayAttendance, isNotEmpty);
    });

    test('getTodayAttendanceFor returns record for present employee', () {
      final att = MockDataStore.getTodayAttendanceFor('emp-001');
      expect(att, isNotNull);
      expect(att!.employeeId, 'emp-001');
    });

    test('getTodayAttendanceFor returns null for absent employee', () {
      // emp-013 (Dave Morales) is absent in mock data
      final att = MockDataStore.getTodayAttendanceFor('emp-013');
      expect(att, isNull);
    });

    test('dashboard totals are self-consistent', () {
      expect(MockDataStore.presentToday + MockDataStore.lateToday +
          MockDataStore.absentToday + MockDataStore.onLeave,
          equals(MockDataStore.totalEmployees));
    });
  });

  group('MockDataStore - organizations', () {
    test('has at least one organization', () {
      expect(MockDataStore.organizations, isNotEmpty);
    });

    test('demo org has expected fields', () {
      final org = MockDataStore.organizations.first;
      expect(org.id, 'org-demo');
      expect(org.name, 'Demo Corporation');
      expect(org.employeeCodePattern, isNotEmpty);
    });
  });

  group('MockDataStore - org users', () {
    test('has seeded users', () {
      expect(MockDataStore.orgUsers.length, greaterThanOrEqualTo(3));
    });

    test('admin user is activated', () {
      final admin = MockDataStore.orgUsers
          .firstWhere((u) => u.userId == MockDataStore.adminUserId);
      expect(admin.isActivated, isTrue);
    });

    test('pending user is not activated', () {
      final pending = MockDataStore.orgUsers
          .firstWhere((u) => u.email == 'pending@demo.local');
      expect(pending.isActivated, isFalse);
    });

    test('all activated users have emailConfirmedAt set', () {
      for (final u in MockDataStore.orgUsers.where((u) => u.isActivated)) {
        expect(u.emailConfirmedAt, isNotNull);
      }
    });
  });

  group('MockDataStore - leave requests', () {
    test('has pending, approved, and rejected requests', () {
      final statuses = MockDataStore.leaveRequests.map((l) => l.status).toSet();
      expect(statuses, containsAll(['approved', 'rejected']));
      expect(statuses.any((s) => s.startsWith('pending')), isTrue);
    });
  });

  group('MockDataStore - notifications', () {
    test('unreadNotifications is a subset of all notifications', () {
      final all = MockDataStore.notifications.map((n) => n.id).toSet();
      final unread = MockDataStore.unreadNotifications.map((n) => n.id).toSet();
      expect(unread.difference(all), isEmpty);
    });

    test('unread notifications all have isRead = false', () {
      for (final n in MockDataStore.unreadNotifications) {
        expect(n.isRead, isFalse);
      }
    });
  });
}
