import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_mapper.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final _client = SupabaseConfig.client;

  Future<AttendanceModel?> getTodayAttendance(String employeeId) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final raw = await _client
          .from(AppConstants.tableAttendance)
          .select()
          .eq('employee_id', employeeId)
          .eq('date', today)
          .maybeSingle();
      if (raw == null) return null;
      return AttendanceModel.fromJson(_decodeMap(raw));
    } catch (e, st) {
      debugPrint('[AttendanceService] ERROR fetching today attendance: $e\n$st');
      throw ErrorMapper.map(e, "Failed to load today's attendance.");
    }
  }

  Future<AttendanceModel> checkIn({
    required String employeeId,
    required String scheduleId,
    String source = 'mobile',
  }) async {
    try {
      final now = DateTime.now();
      final today = now.toIso8601String().substring(0, 10);
      final raw = await _client
          .from(AppConstants.tableAttendance)
          .upsert({
            'employee_id': employeeId,
            'date': today,
            'time_in': now.toIso8601String(),
            'schedule_id': scheduleId,
            'status': 'present',
            'source': source,
          })
          .select()
          .single();
      return AttendanceModel.fromJson(_decodeMap(raw));
    } catch (e, st) {
      debugPrint('[AttendanceService] ERROR checking in: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to check in.');
    }
  }

  Future<AttendanceModel> checkOut(String attendanceId) async {
    try {
      final now = DateTime.now();
      final raw = await _client
          .from(AppConstants.tableAttendance)
          .update({'time_out': now.toIso8601String()})
          .eq('id', attendanceId)
          .select()
          .single();
      await _client.functions.invoke(
        AppConstants.fnComputeAttendance,
        body: {'attendance_id': attendanceId},
      );
      return AttendanceModel.fromJson(_decodeMap(raw));
    } catch (e, st) {
      debugPrint('[AttendanceService] ERROR checking out: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to check out.');
    }
  }

  Future<List<AttendanceModel>> getAttendanceByDate(DateTime date) async {
    final dateStr = date.toIso8601String().substring(0, 10);
    try {
      final raw = await _client
          .from(AppConstants.tableAttendance)
          .select(
            '*, employees!employee_id(employee_code, first_name, last_name)',
          )
          .eq('date', dateStr)
          .order('time_in');
      return _decodeList(raw).map(_mapAttendance).toList();
    } catch (e, st) {
      debugPrint('[AttendanceService] ERROR fetching attendance by date: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load attendance for $dateStr.');
    }
  }

  Future<List<AttendanceModel>> getEmployeeAttendance(
    String employeeId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = startDate.toIso8601String().substring(0, 10);
    final end = endDate.toIso8601String().substring(0, 10);
    try {
      final raw = await _client
          .from(AppConstants.tableAttendance)
          .select()
          .eq('employee_id', employeeId)
          .gte('date', start)
          .lte('date', end)
          .order('date', ascending: false);
      return _decodeList(raw).map((e) => AttendanceModel.fromJson(e)).toList();
    } catch (e, st) {
      debugPrint('[AttendanceService] ERROR fetching employee attendance: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load attendance history.');
    }
  }

  Stream<List<AttendanceModel>> streamTodayAttendance() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return _client
        .from(AppConstants.tableAttendance)
        .stream(primaryKey: ['id'])
        .eq('date', today)
        .order('time_in', ascending: false)
        .map((data) => _decodeList(data).map(_mapAttendance).toList());
  }

  List<Map<String, dynamic>> _decodeList(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> _decodeMap(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>();

  AttendanceModel _mapAttendance(Map<String, dynamic> json) {
    final rawEmp = json['employees'];
    Map<String, dynamic>? emp;
    if (rawEmp is Map) {
      emp = rawEmp.cast<String, dynamic>();
    } else if (rawEmp is List && rawEmp.isNotEmpty) {
      final first = rawEmp.first;
      if (first is Map) emp = first.cast<String, dynamic>();
    }
    final fullName = emp != null
        ? '${emp['first_name']} ${emp['last_name']}'
        : null;
    return AttendanceModel.fromJson({
      ...json,
      'employee_full_name': fullName,
      'employee_code': emp?['employee_code'],
    });
  }
}
