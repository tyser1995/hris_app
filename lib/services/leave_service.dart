import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:postgrest/postgrest.dart';
import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_mapper.dart';
import '../models/leave_request_model.dart';

class LeaveService {
  final _client = SupabaseConfig.client;

  Future<List<LeaveRequestModel>> getLeaveRequests({
    String? employeeId,
    String? status,
    int page = 0,
  }) async {
    final offset = page * AppConstants.pageSize;
    try {
      PostgrestFilterBuilder query = _client
          .from(AppConstants.tableLeaveRequests)
          .select('*, employees!employee_id(first_name, last_name)');

      if (employeeId != null) {
        query = query.eq('employee_id', employeeId);
      }
      if (status != null) {
        query = query.eq('status', status);
      }

      final raw = await query
          .range(offset, offset + AppConstants.pageSize - 1)
          .order('created_at', ascending: false);

      return _decodeList(raw).map(_mapLeave).toList();
    } catch (e, st) {
      debugPrint('[LeaveService] ERROR fetching leave requests: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load leave requests.');
    }
  }

  Future<LeaveRequestModel> createLeaveRequest({
    required String employeeId,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required double daysRequested,
    String? reason,
  }) async {
    try {
      final raw = await _client
          .from(AppConstants.tableLeaveRequests)
          .insert({
            'employee_id': employeeId,
            'leave_type': leaveType,
            'start_date': startDate.toIso8601String().substring(0, 10),
            'end_date': endDate.toIso8601String().substring(0, 10),
            'days_requested': daysRequested,
            'reason': reason,
          })
          .select()
          .single();
      return LeaveRequestModel.fromJson(_decodeMap(raw));
    } catch (e, st) {
      debugPrint('[LeaveService] ERROR creating leave request: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to submit leave request.');
    }
  }

  Future<void> approveLeave({
    required String leaveId,
    required String action,
    required String approverId,
    required String level,
    String? remarks,
  }) async {
    try {
      await _client.functions.invoke(
        AppConstants.fnApproveLeave,
        body: {
          'leave_id': leaveId,
          'action': action,
          'approver_id': approverId,
          'level': level,
          'remarks': remarks,
        },
      );
    } catch (e, st) {
      debugPrint('[LeaveService] ERROR approving leave: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to process leave approval.');
    }
  }

  Future<Map<String, double>> getLeaveBalances(
      String employeeId, int year) async {
    try {
      final raw = await _client
          .from(AppConstants.tableLeaveBalances)
          .select()
          .eq('employee_id', employeeId)
          .eq('year', year);
      final data = _decodeList(raw);
      return {
        for (final row in data)
          row['leave_type'] as String:
              ((row['total_days'] as num) - (row['used_days'] as num))
                  .toDouble(),
      };
    } catch (e, st) {
      debugPrint('[LeaveService] ERROR fetching leave balances: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load leave balances.');
    }
  }

  List<Map<String, dynamic>> _decodeList(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> _decodeMap(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>();

  LeaveRequestModel _mapLeave(Map<String, dynamic> json) {
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
    return LeaveRequestModel.fromJson({
      ...json,
      'employee_full_name': fullName,
    });
  }
}
