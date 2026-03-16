import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:postgrest/postgrest.dart';
import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_mapper.dart';
import '../models/department_model.dart';
import '../models/position_model.dart';

class DepartmentService {
  final _client = SupabaseConfig.client;

  Future<List<DepartmentModel>> getDepartments() async {
    try {
      final raw = await _client
          .from(AppConstants.tableDepartments)
          .select('*, employees!head_id(first_name, last_name)')
          .order('name');
      return _decodeList(raw).map((json) {
        final rawHead = json['employees'];
        Map<String, dynamic>? head;
        if (rawHead is Map) {
          head = rawHead.cast<String, dynamic>();
        } else if (rawHead is List && rawHead.isNotEmpty) {
          final first = rawHead.first;
          if (first is Map) head = first.cast<String, dynamic>();
        }
        return DepartmentModel.fromJson({
          ...json,
          'head_full_name': head != null
              ? '${head['first_name']} ${head['last_name']}'
              : null,
        });
      }).toList();
    } catch (e, st) {
      debugPrint('[DepartmentService] ERROR fetching departments: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load departments.');
    }
  }

  Future<DepartmentModel> createDepartment(
      String name, {String? headId}) async {
    try {
      final raw = await _client
          .from(AppConstants.tableDepartments)
          .insert({'name': name, if (headId != null) 'head_id': headId})
          .select()
          .single();
      return DepartmentModel.fromJson(_decodeMap(raw));
    } catch (e, st) {
      debugPrint('[DepartmentService] ERROR creating department: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to create department.');
    }
  }

  Future<List<PositionModel>> getPositions({String? departmentId}) async {
    try {
      PostgrestFilterBuilder query = _client
          .from(AppConstants.tablePositions)
          .select();

      if (departmentId != null) {
        query = query.eq('department_id', departmentId);
      }

      final raw = await query.order('title');
      return _decodeList(raw).map((e) => PositionModel.fromJson(e)).toList();
    } catch (e, st) {
      debugPrint('[DepartmentService] ERROR fetching positions: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load positions.');
    }
  }

  Future<DepartmentModel> updateDepartment(
      String id, String name) async {
    try {
      final raw = await _client
          .from(AppConstants.tableDepartments)
          .update({'name': name.trim()})
          .eq('id', id)
          .select()
          .single();
      return DepartmentModel.fromJson(_decodeMap(raw));
    } catch (e, st) {
      debugPrint('[DepartmentService] ERROR updating department: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to update department.');
    }
  }

  Future<void> deleteDepartment(String id) async {
    try {
      await _client
          .from(AppConstants.tableDepartments)
          .delete()
          .eq('id', id);
    } catch (e, st) {
      debugPrint('[DepartmentService] ERROR deleting department: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to delete department.');
    }
  }

  Future<PositionModel> createPosition(
      String title, {String? departmentId}) async {
    try {
      final raw = await _client
          .from(AppConstants.tablePositions)
          .insert({
            'title': title,
            if (departmentId != null) 'department_id': departmentId,
          })
          .select()
          .single();
      return PositionModel.fromJson(_decodeMap(raw));
    } catch (e, st) {
      debugPrint('[DepartmentService] ERROR creating position: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to create position.');
    }
  }

  List<Map<String, dynamic>> _decodeList(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> _decodeMap(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>();
}
