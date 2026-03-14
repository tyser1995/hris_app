import 'package:flutter_test/flutter_test.dart';
import 'package:hris_app/models/org_user_model.dart';
import 'package:hris_app/models/organization_model.dart';

void main() {
  group('OrganizationModel.fromJson', () {
    test('parses all fields', () {
      final json = {
        'id': 'org-1',
        'name': 'Acme Corp',
        'system_title': 'Acme HRIS',
        'primary_color': '#2563EB',
        'logo_url': 'https://example.com/logo.png',
        'employee_code_pattern': 'YY-###',
        'employee_code_sequence': 50,
        'created_at': '2024-01-01T00:00:00.000Z',
      };
      final model = OrganizationModel.fromJson(json);
      expect(model.id, 'org-1');
      expect(model.name, 'Acme Corp');
      expect(model.systemTitle, 'Acme HRIS');
      expect(model.primaryColor, '#2563EB');
      expect(model.logoUrl, 'https://example.com/logo.png');
      expect(model.employeeCodePattern, 'YY-###');
      expect(model.employeeCodeSequence, 50);
      expect(model.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
    });

    test('uses defaults when optional fields missing', () {
      final json = {
        'id': 'org-2',
        'name': 'Beta',
        'created_at': '2024-06-01T00:00:00.000Z',
      };
      final model = OrganizationModel.fromJson(json);
      expect(model.employeeCodePattern, 'YY-###');
      expect(model.employeeCodeSequence, 0);
      expect(model.systemTitle, isNull);
      expect(model.primaryColor, isNull);
    });

    test('falls back to DateTime.now() on invalid created_at', () {
      final json = {
        'id': 'org-3',
        'name': 'Gamma',
        'created_at': 'not-a-date',
      };
      final before = DateTime.now();
      final model = OrganizationModel.fromJson(json);
      final after = DateTime.now();
      expect(model.createdAt.isAfter(before) ||
          model.createdAt.isAtSameMomentAs(before), isTrue);
      expect(model.createdAt.isBefore(after) ||
          model.createdAt.isAtSameMomentAs(after), isTrue);
    });
  });

  group('OrgUserModel.fromJson', () {
    test('parses all fields', () {
      final json = {
        'user_id': 'user-abc',
        'email': 'alice@example.com',
        'role': 'hr_staff',
        'organization_id': 'org-1',
        'organization_name': 'Acme Corp',
        'created_at': '2024-01-15T08:00:00.000Z',
        'email_confirmed_at': '2024-01-16T09:00:00.000Z',
        'last_sign_in_at': '2026-03-14T10:00:00.000Z',
      };
      final model = OrgUserModel.fromJson(json);
      expect(model.userId, 'user-abc');
      expect(model.email, 'alice@example.com');
      expect(model.role, 'hr_staff');
      expect(model.organizationId, 'org-1');
      expect(model.organizationName, 'Acme Corp');
      expect(model.isActivated, isTrue);
    });

    test('isActivated is false when emailConfirmedAt is null', () {
      final json = {
        'user_id': 'user-xyz',
        'email': 'pending@example.com',
        'role': 'employee',
      };
      final model = OrgUserModel.fromJson(json);
      expect(model.isActivated, isFalse);
      expect(model.organizationId, isNull);
      expect(model.lastSignInAt, isNull);
    });

    test('handles null date fields gracefully', () {
      final json = {
        'user_id': 'user-xyz',
        'email': 'x@y.com',
        'role': 'employee',
        'created_at': null,
        'email_confirmed_at': null,
        'last_sign_in_at': null,
      };
      final model = OrgUserModel.fromJson(json);
      expect(model.createdAt, isNull);
      expect(model.emailConfirmedAt, isNull);
      expect(model.lastSignInAt, isNull);
    });
  });
}
