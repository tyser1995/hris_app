import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hris_app/mock/mock_services.dart';

void main() {
  group('MockSettingsService', () {
    late MockSettingsService service;

    setUp(() {
      service = MockSettingsService();
    });

    test('getSettings returns initial settings', () async {
      final settings = await service.getSettings();
      expect(settings.employeeCodePattern, isNotEmpty);
      expect(settings.employeeCodeSequence, greaterThanOrEqualTo(0));
    });

    test('updatePattern changes the pattern', () async {
      await service.updatePattern('YYYY-####');
      final settings = await service.getSettings();
      expect(settings.employeeCodePattern, 'YYYY-####');
    });

    test('updateBranding changes branding fields', () async {
      await service.updateBranding(
        systemTitle: 'New Title',
        primaryColor: '#FF0000',
      );
      final settings = await service.getSettings();
      expect(settings.systemTitle, 'New Title');
      expect(settings.primaryColor, '#FF0000');
    });

    test('previewNextCode increments sequence preview', () async {
      final settings = await service.getSettings();
      final initialSeq = settings.employeeCodeSequence;
      final preview = await service.previewNextCode();
      expect(preview, isNotEmpty);
      // Sequence should NOT have changed yet
      final settingsAfter = await service.getSettings();
      expect(settingsAfter.employeeCodeSequence, initialSeq);
    });

    test('incrementAndGetCode increments sequence', () async {
      final settings = await service.getSettings();
      final initialSeq = settings.employeeCodeSequence;
      await service.incrementAndGetCode();
      final settingsAfter = await service.getSettings();
      expect(settingsAfter.employeeCodeSequence, initialSeq + 1);
    });

    test('resetSequence sets sequence to 0', () async {
      await service.incrementAndGetCode();
      await service.resetSequence();
      final settings = await service.getSettings();
      expect(settings.employeeCodeSequence, 0);
    });

    test('uploadLogo returns a non-empty placeholder URL', () async {
      final url = await service.uploadLogo(
        Uint8List.fromList([0, 1, 2]),
        'logo.png',
      );
      expect(url, isNotEmpty);
      expect(Uri.tryParse(url)?.hasAbsolutePath, isTrue);
    });

    group('pattern substitution', () {
      test('YY-E### pattern produces correct format', () async {
        await service.updatePattern('YY-E###');
        await service.resetSequence();
        final code = await service.incrementAndGetCode();
        final now = DateTime.now();
        final yy = now.year.toString().substring(2);
        expect(code, startsWith('$yy-E'));
        expect(code, endsWith('001'));
      });

      test('YYYY-#### pattern produces 4-digit year and 4-digit seq', () async {
        await service.updatePattern('YYYY-####');
        await service.resetSequence();
        final code = await service.incrementAndGetCode();
        final now = DateTime.now();
        expect(code, startsWith('${now.year}-'));
        expect(code, endsWith('0001'));
      });
    });
  });

  group('MockUserManagementService', () {
    late MockUserManagementService service;

    setUp(() {
      service = MockUserManagementService();
    });

    test('getOrgUsers returns pre-seeded demo users', () async {
      final users = await service.getOrgUsers();
      expect(users, isNotEmpty);
      expect(users.any((u) => u.email == 'admin@demo.local'), isTrue);
    });

    test('createUser adds to list and returns user', () async {
      final before = (await service.getOrgUsers()).length;
      final user = await service.createUser(
        email: 'newuser@test.com',
        role: 'hr_staff',
        autoConfirm: true,
        organizationId: 'org-demo',
      );
      final after = await service.getOrgUsers();
      expect(after.length, before + 1);
      expect(user.email, 'newuser@test.com');
      expect(user.role, 'hr_staff');
      expect(user.isActivated, isTrue); // autoConfirm = true
    });

    test('createUser with autoConfirm=false leaves emailConfirmedAt null', () async {
      final user = await service.createUser(
        email: 'invited@test.com',
        role: 'employee',
        autoConfirm: false,
        organizationId: 'org-demo',
      );
      expect(user.isActivated, isFalse);
    });

    test('inviteUser adds to list without confirmation', () async {
      final before = (await service.getOrgUsers()).length;
      final user = await service.inviteUser(
        email: 'invite@test.com',
        role: 'supervisor',
      );
      final after = await service.getOrgUsers();
      expect(after.length, before + 1);
      expect(user.email, 'invite@test.com');
      expect(user.isActivated, isFalse);
    });
  });

  group('MockOrganizationService', () {
    late MockOrganizationService service;

    setUp(() {
      service = MockOrganizationService();
    });

    test('getOrganizations returns demo org', () async {
      final orgs = await service.getOrganizations();
      expect(orgs, isNotEmpty);
      expect(orgs.first.name, 'Demo Corporation');
    });

    test('createAdminAccount adds org and returns result', () async {
      final before = (await service.getOrganizations()).length;
      final result = await service.createAdminAccount(
        orgName: 'New Org',
        email: 'admin@neworgs.com',
      );
      final after = await service.getOrganizations();
      expect(after.length, before + 1);
      expect(result['organization']['name'], 'New Org');
      expect(result['user']['email'], 'admin@neworgs.com');
      expect(result['message'], contains('admin@neworgs.com'));
    });
  });
}
