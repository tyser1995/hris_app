import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_mapper.dart';

class ReportService {
  final _client = SupabaseConfig.client;

  Future<Map<String, dynamic>> getDailyAttendanceSummary(
      DateTime date) async {
    final dateStr = date.toIso8601String().substring(0, 10);
    try {
      final results = await Future.wait([
        _client
            .from(AppConstants.tableAttendance)
            .select('id')
            .eq('date', dateStr)
            .eq('status', 'present')
            .count(),
        _client
            .from(AppConstants.tableAttendance)
            .select('id')
            .eq('date', dateStr)
            .eq('status', 'late')
            .count(),
        _client
            .from(AppConstants.tableAttendance)
            .select('id')
            .eq('date', dateStr)
            .eq('status', 'absent')
            .count(),
      ]);
      return {
        'date': dateStr,
        'present': results[0].count,
        'late': results[1].count,
        'absent': results[2].count,
      };
    } catch (e, st) {
      debugPrint('[ReportService] ERROR fetching daily attendance summary: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load daily attendance summary.');
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyAttendance({
    required int year,
    required int month,
    String? departmentId,
  }) async {
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDate = DateTime(year, month + 1, 0)
        .toIso8601String()
        .substring(0, 10);
    try {
      final raw = await _client
          .from(AppConstants.tableAttendance)
          .select(
            'employee_id, status, late_minutes, overtime_minutes, '
            'employees!employee_id(employee_code, first_name, last_name, department_id)',
          )
          .gte('date', startDate)
          .lte('date', endDate);
      return _decodeList(raw);
    } catch (e, st) {
      debugPrint('[ReportService] ERROR fetching monthly attendance: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load monthly attendance report.');
    }
  }

  Future<Map<String, dynamic>> exportPayroll({
    required int year,
    required int month,
    String? departmentId,
  }) async {
    try {
      final response = await _client.functions.invoke(
        AppConstants.fnPayrollExport,
        body: {
          'year': year,
          'month': month,
          if (departmentId != null) 'department_id': departmentId,
        },
      );
      return _decodeMap(response.data);
    } catch (e, st) {
      debugPrint('[ReportService] ERROR exporting payroll: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to export payroll.');
    }
  }

  Future<List<Map<String, dynamic>>> getContractExpirations(
      {int daysAhead = 30}) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final future = DateTime.now()
          .add(Duration(days: daysAhead))
          .toIso8601String()
          .substring(0, 10);
      final raw = await _client
          .from(AppConstants.tableEmployees)
          .select(
              'employee_code, first_name, last_name, contract_end, departments!employees_department_id_fkey(name)')
          .lte('contract_end', future)
          .gte('contract_end', today)
          .eq('employment_status', 'active')
          .order('contract_end');
      return _decodeList(raw);
    } catch (e, st) {
      debugPrint('[ReportService] ERROR fetching contract expirations: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load contract expiration report.');
    }
  }

  List<Map<String, dynamic>> _decodeList(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> _decodeMap(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>();
}
