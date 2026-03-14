import 'package:flutter_test/flutter_test.dart';
import 'package:hris_app/models/company_settings_model.dart';

void main() {
  group('CompanySettingsModel.fromJson', () {
    test('parses all fields from legacy table format', () {
      final json = {
        'employee_code_pattern': 'YY-E###',
        'employee_code_sequence': 42,
        'company_name': 'Acme Corp',
        'system_title': 'Acme HRIS',
        'primary_color': '#2563EB',
        'logo_url': 'https://example.com/logo.png',
      };
      final model = CompanySettingsModel.fromJson(json);
      expect(model.employeeCodePattern, 'YY-E###');
      expect(model.employeeCodeSequence, 42);
      expect(model.companyName, 'Acme Corp');
      expect(model.systemTitle, 'Acme HRIS');
      expect(model.primaryColor, '#2563EB');
      expect(model.logoUrl, 'https://example.com/logo.png');
      expect(model.organizationId, isNull);
    });

    test('uses defaults when optional fields are null', () {
      final model = CompanySettingsModel.fromJson({});
      expect(model.employeeCodePattern, 'YY-###');
      expect(model.employeeCodeSequence, 0);
      expect(model.companyName, isNull);
    });
  });

  group('CompanySettingsModel.fromOrgJson', () {
    test('parses from organizations table format', () {
      final json = {
        'id': 'org-abc',
        'name': 'Beta Inc',
        'system_title': 'Beta HRIS',
        'primary_color': '#059669',
        'logo_url': null,
        'employee_code_pattern': 'YYYY-###',
        'employee_code_sequence': 10,
      };
      final model = CompanySettingsModel.fromOrgJson(json);
      expect(model.organizationId, 'org-abc');
      expect(model.companyName, 'Beta Inc');
      expect(model.employeeCodePattern, 'YYYY-###');
      expect(model.employeeCodeSequence, 10);
      expect(model.primaryColor, '#059669');
      expect(model.logoUrl, isNull);
    });
  });

  group('CompanySettingsModel.copyWith', () {
    test('overrides only the specified fields', () {
      const original = CompanySettingsModel(
        employeeCodePattern: 'YY-###',
        employeeCodeSequence: 5,
        companyName: 'Old Name',
        primaryColor: '#000000',
      );
      final copy = original.copyWith(companyName: 'New Name', primaryColor: '#FFFFFF');
      expect(copy.companyName, 'New Name');
      expect(copy.primaryColor, '#FFFFFF');
      expect(copy.employeeCodePattern, 'YY-###');
      expect(copy.employeeCodeSequence, 5);
    });
  });

  group('CompanySettingsModel.defaults', () {
    test('has sensible defaults', () {
      expect(CompanySettingsModel.defaults.employeeCodePattern, 'YY-###');
      expect(CompanySettingsModel.defaults.employeeCodeSequence, 0);
    });
  });
}
