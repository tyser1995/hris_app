import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:postgrest/postgrest.dart';
import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_mapper.dart';
import '../models/employee_model.dart';

class EmployeeService {
  final _client = SupabaseConfig.client;

  Future<List<EmployeeModel>> getEmployees({
    int page = 0,
    String? search,
    String? departmentId,
    String? employmentType,
    String? status,
  }) async {
    final offset = page * AppConstants.pageSize;
    try {
      PostgrestFilterBuilder query = _client
          .from(AppConstants.tableEmployees)
          .select(
            'id, user_id, employee_code, first_name, last_name, middle_name, '
            'employment_type, department_id, position_id, supervisor_id, '
            'schedule_id, hire_date, employment_status, contract_start, '
            'contract_end, address, phone, email, birthdate, civil_status, '
            'avatar_url, created_at, updated_at, '
            'departments!employees_department_id_fkey(name), positions(title)',
          )
          .eq('employment_status', status ?? 'active');

      if (search != null && search.isNotEmpty) {
        query = query.or(
          'first_name.ilike.%$search%,'
          'last_name.ilike.%$search%,'
          'employee_code.ilike.%$search%,'
          'email.ilike.%$search%',
        );
      }
      if (departmentId != null) {
        query = query.eq('department_id', departmentId);
      }
      if (employmentType != null) {
        query = query.eq('employment_type', employmentType);
      }

      final raw = await query
          .range(offset, offset + AppConstants.pageSize - 1)
          .order('last_name');

      final data = _decodeList(raw);
      return data.map(_mapEmployee).toList();
    } catch (e, st) {
      debugPrint('[EmployeeService] ERROR fetching employees: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load employees.');
    }
  }

  Future<EmployeeModel?> getEmployee(String id) async {
    try {
      final raw = await _client
          .from(AppConstants.tableEmployees)
          .select('*, departments!employees_department_id_fkey(name), positions(title)')
          .eq('id', id)
          .maybeSingle();
      if (raw == null) return null;
      return _mapEmployee(_decodeMap(raw));
    } catch (e, st) {
      debugPrint('[EmployeeService] ERROR fetching employee $id: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load employee details.');
    }
  }

  Future<EmployeeModel> createEmployee(Map<String, dynamic> payload) async {
    try {
      final raw = await _client
          .from(AppConstants.tableEmployees)
          .insert(payload)
          .select('*, departments!employees_department_id_fkey(name), positions(title)')
          .single();
      return _mapEmployee(_decodeMap(raw));
    } catch (e, st) {
      debugPrint('[EmployeeService] ERROR creating employee: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to create employee.');
    }
  }

  Future<EmployeeModel> updateEmployee(
      String id, Map<String, dynamic> payload) async {
    try {
      final raw = await _client
          .from(AppConstants.tableEmployees)
          .update(payload)
          .eq('id', id)
          .select('*, departments!employees_department_id_fkey(name), positions(title)')
          .single();
      return _mapEmployee(_decodeMap(raw));
    } catch (e, st) {
      debugPrint('[EmployeeService] ERROR updating employee $id: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to update employee.');
    }
  }

  Future<int> getTotalCount({String status = 'active'}) async {
    try {
      final response = await _client
          .from(AppConstants.tableEmployees)
          .select('id')
          .eq('employment_status', status)
          .count();
      return response.count;
    } catch (e, st) {
      debugPrint('[EmployeeService] ERROR fetching total count: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to fetch employee count.');
    }
  }

  Future<List<EmployeeModel>> getExpiringContracts({int daysAhead = 30}) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final future = DateTime.now()
          .add(Duration(days: daysAhead))
          .toIso8601String()
          .substring(0, 10);
      final raw = await _client
          .from(AppConstants.tableEmployees)
          .select('*, departments!employees_department_id_fkey(name), positions(title)')
          .lte('contract_end', future)
          .gte('contract_end', today)
          .eq('employment_status', 'active')
          .order('contract_end');
      final data = _decodeList(raw);
      return data.map(_mapEmployee).toList();
    } catch (e, st) {
      debugPrint('[EmployeeService] ERROR fetching expiring contracts: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load expiring contracts.');
    }
  }

  /// JSON round-trip converts JSArray/JSObject (Flutter Web) into proper Dart types.
  List<Map<String, dynamic>> _decodeList(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> _decodeMap(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>();

  EmployeeModel _mapEmployee(Map<String, dynamic> json) {
    final rawDept = json['departments'];
    Map<String, dynamic>? dept;
    if (rawDept is Map) {
      dept = rawDept.cast<String, dynamic>();
    } else if (rawDept is List && rawDept.isNotEmpty) {
      final first = rawDept.first;
      if (first is Map) dept = first.cast<String, dynamic>();
    }

    final rawPos = json['positions'];
    Map<String, dynamic>? pos;
    if (rawPos is Map) {
      pos = rawPos.cast<String, dynamic>();
    } else if (rawPos is List && rawPos.isNotEmpty) {
      final first = rawPos.first;
      if (first is Map) pos = first.cast<String, dynamic>();
    }

    return EmployeeModel.fromJson({
      ...json,
      'department_name': dept?['name'],
      'position_title': pos?['title'],
    });
  }
}
