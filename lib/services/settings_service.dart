// Schema: supabase/migrations/011_create_company_settings.sql
// Edge fn: supabase/functions/generate-employee-code/index.ts

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:postgrest/postgrest.dart';
import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../core/errors/error_mapper.dart';
import '../core/utils/employee_code_generator.dart';
import '../models/company_settings_model.dart';

class SettingsService {
  final _client = SupabaseConfig.client;

  static const _id = 'singleton';

  // ─── Read ────────────────────────────────────────────────────────────────

  Future<CompanySettingsModel> getSettings() async {
    debugPrint('[SettingsService] Fetching company settings');
    try {
      final raw = await _client
          .from(AppConstants.tableCompanySettings)
          .select()
          .eq('id', _id)
          .maybeSingle();
      if (raw == null) return CompanySettingsModel.defaults;
      return CompanySettingsModel.fromJson(_decode(raw));
    } catch (e, st) {
      // PGRST205 = table not in schema cache (migration not run yet) → use defaults
      if (e is PostgrestException && e.code == 'PGRST205') {
        debugPrint('[SettingsService] company_settings table not found — using defaults');
        return CompanySettingsModel.defaults;
      }
      debugPrint('[SettingsService] ERROR fetching settings: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load company settings.');
    }
  }

  // ─── Write ───────────────────────────────────────────────────────────────

  Future<CompanySettingsModel> updatePattern(String pattern) async {
    debugPrint('[SettingsService] Updating employee_code_pattern → $pattern');
    try {
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

  Future<void> resetSequence() async {
    debugPrint('[SettingsService] Resetting employee_code_sequence → 0');
    try {
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
