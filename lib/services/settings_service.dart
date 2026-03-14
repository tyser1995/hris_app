// Schema: supabase/migrations/011_create_company_settings.sql
// Edge fn: supabase/functions/generate-employee-code/index.ts

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/error_mapper.dart';
import '../core/utils/employee_code_generator.dart';
import '../models/company_settings_model.dart';

class SettingsService {
  SupabaseClient get _client => SupabaseConfig.client;

  static const _id = 'singleton';

  // ─── Read ────────────────────────────────────────────────────────────────

  Future<CompanySettingsModel> getSettings() async {
    debugPrint('[SettingsService] Fetching settings (org-aware)');
    try {
      // Try organizations table first — RLS returns user's own org row.
      final orgRaw = await _client
          .from(AppConstants.tableOrganizations)
          .select()
          .maybeSingle();
      if (orgRaw != null) {
        debugPrint('[SettingsService] Using organization settings');
        return CompanySettingsModel.fromOrgJson(_decode(orgRaw));
      }
    } catch (e) {
      // PGRST205/PGRST301 = table missing or no rows — fall through to singleton
      debugPrint('[SettingsService] organizations fallback: $e');
    }

    // Fallback: legacy company_settings singleton
    debugPrint('[SettingsService] Falling back to company_settings singleton');
    try {
      final raw = await _client
          .from(AppConstants.tableCompanySettings)
          .select()
          .eq('id', _id)
          .maybeSingle();
      if (raw == null) return CompanySettingsModel.defaults;
      return CompanySettingsModel.fromJson(_decode(raw));
    } catch (e, st) {
      if (e is PostgrestException && e.code == 'PGRST205') {
        return CompanySettingsModel.defaults;
      }
      debugPrint('[SettingsService] ERROR fetching settings: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load company settings.');
    }
  }

  // ─── Write ───────────────────────────────────────────────────────────────

  Future<CompanySettingsModel> updatePattern(String pattern,
      {String? organizationId}) async {
    debugPrint('[SettingsService] Updating employee_code_pattern → $pattern');
    try {
      if (organizationId != null) {
        final raw = await _client
            .from(AppConstants.tableOrganizations)
            .update({
              'employee_code_pattern': pattern,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', organizationId)
            .select()
            .maybeSingle();
        if (raw == null) {
          throw AppException(
              'Organization not found or you do not have permission to update it.');
        }
        return CompanySettingsModel.fromOrgJson(_decode(raw));
      }
      final raw = await _client
          .from(AppConstants.tableCompanySettings)
          .upsert({
            'id': _id,
            'employee_code_pattern': pattern,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      return CompanySettingsModel.fromJson(_decode(raw));
    } catch (e, st) {
      debugPrint('[SettingsService] ERROR updating pattern: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to save employee code pattern.');
    }
  }

  Future<void> resetSequence({String? organizationId}) async {
    debugPrint('[SettingsService] Resetting employee_code_sequence → 0');
    try {
      if (organizationId != null) {
        await _client
            .from(AppConstants.tableOrganizations)
            .update({
              'employee_code_sequence': 0,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', organizationId);
        return;
      }
      await _client
          .from(AppConstants.tableCompanySettings)
          .upsert({
            'id': _id,
            'employee_code_sequence': 0,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e, st) {
      debugPrint('[SettingsService] ERROR resetting sequence: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to reset employee code sequence.');
    }
  }

  Future<CompanySettingsModel> updateBranding({
    String? organizationId,
    String? systemTitle,
    String? primaryColor,
    String? logoUrl,
  }) async {
    debugPrint('[SettingsService] Updating branding settings');
    try {
      if (organizationId != null) {
        final raw = await _client
            .from(AppConstants.tableOrganizations)
            .update({
              if (systemTitle != null) 'system_title': systemTitle,
              if (primaryColor != null) 'primary_color': primaryColor,
              if (logoUrl != null) 'logo_url': logoUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', organizationId)
            .select()
            .maybeSingle();
        if (raw == null) {
          throw AppException(
              'Organization not found or you do not have permission to update it.');
        }
        return CompanySettingsModel.fromOrgJson(_decode(raw));
      }
      final raw = await _client
          .from(AppConstants.tableCompanySettings)
          .upsert({
            'id': _id,
            if (systemTitle != null) 'system_title': systemTitle,
            if (primaryColor != null) 'primary_color': primaryColor,
            if (logoUrl != null) 'logo_url': logoUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      return CompanySettingsModel.fromJson(_decode(raw));
    } catch (e, st) {
      debugPrint('[SettingsService] ERROR updating branding: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to save branding settings.');
    }
  }

  // ─── Logo upload ─────────────────────────────────────────────────────────

  /// Uploads [bytes] to the `logos` storage bucket and returns the public URL.
  /// Always overwrites `logo.<ext>` so there is only ever one logo file.
  Future<String> uploadLogo(Uint8List bytes, String fileName) async {
    debugPrint('[SettingsService] Uploading logo: $fileName');
    try {
      final ext = fileName.contains('.')
          ? fileName.split('.').last.toLowerCase()
          : 'png';
      final path = 'logo.$ext';
      final mime = _mimeType(ext);

      await _client.storage
          .from(AppConstants.bucketLogos)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: mime),
          );

      final url = _client.storage
          .from(AppConstants.bucketLogos)
          .getPublicUrl(path);

      debugPrint('[SettingsService] Logo uploaded → $url');
      return url;
    } catch (e, st) {
      debugPrint('[SettingsService] ERROR uploading logo: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to upload logo.');
    }
  }

  static String _mimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'svg':
        return 'image/svg+xml';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/png';
    }
  }

  // ─── Code generation ─────────────────────────────────────────────────────

  /// Returns what the next employee code WOULD be, without changing anything.
  Future<String> previewNextCode() async {
    final s = await getSettings();
    return EmployeeCodeGenerator.generate(
      s.employeeCodePattern,
      s.employeeCodeSequence + 1,
      DateTime.now(),
    );
  }

  /// Atomically increments the stored sequence and returns the new code.
  ///
  /// Delegates to the `generate-employee-code` edge function which calls the
  /// `next_employee_code()` Postgres function under a row-level lock.
  /// This prevents duplicate codes when multiple employees are created
  /// concurrently.
  ///
  /// Call this after a successful employee creation.
  Future<String> incrementAndGetCode() async {
    debugPrint('[SettingsService] Invoking generate-employee-code function');
    try {
      final response = await _client.functions.invoke(
        AppConstants.fnGenerateEmployeeCode,
      );
      final data = _decode(response.data);
      if (data['error'] != null) {
        throw AppException(data['error'] as String);
      }
      final code = data['code'] as String;
      debugPrint('[SettingsService] Generated code: $code');
      return code;
    } catch (e, st) {
      debugPrint('[SettingsService] ERROR generating code: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to generate employee code.');
    }
  }

  Map<String, dynamic> _decode(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>();
}
