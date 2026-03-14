import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_mapper.dart';
import '../models/employment_type_model.dart';

class EmploymentTypeService {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<EmploymentTypeModel>> getEmploymentTypes() async {
    debugPrint('[EmploymentTypeService] Fetching employment types');
    try {
      final rows = await _client
          .from(AppConstants.tableEmploymentTypes)
          .select()
          .order('name');
      return (rows as List)
          .map((r) => EmploymentTypeModel.fromJson(_decode(r)))
          .toList();
    } catch (e, st) {
      debugPrint('[EmploymentTypeService] ERROR: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load employment types.');
    }
  }

  Future<EmploymentTypeModel> createEmploymentType({
    required String name,
    required String organizationId,
  }) async {
    debugPrint('[EmploymentTypeService] Creating: $name');
    try {
      final raw = await _client
          .from(AppConstants.tableEmploymentTypes)
          .insert({'name': name.trim(), 'organization_id': organizationId})
          .select()
          .single();
      return EmploymentTypeModel.fromJson(_decode(raw));
    } catch (e, st) {
      debugPrint('[EmploymentTypeService] ERROR: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to create employment type.');
    }
  }

  Future<EmploymentTypeModel> updateEmploymentType({
    required String id,
    required String name,
  }) async {
    debugPrint('[EmploymentTypeService] Updating $id → $name');
    try {
      final raw = await _client
          .from(AppConstants.tableEmploymentTypes)
          .update({
            'name': name.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      return EmploymentTypeModel.fromJson(_decode(raw));
    } catch (e, st) {
      debugPrint('[EmploymentTypeService] ERROR: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to update employment type.');
    }
  }

  Future<void> deleteEmploymentType(String id) async {
    debugPrint('[EmploymentTypeService] Deleting $id');
    try {
      await _client
          .from(AppConstants.tableEmploymentTypes)
          .delete()
          .eq('id', id);
    } catch (e, st) {
      debugPrint('[EmploymentTypeService] ERROR: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to delete employment type.');
    }
  }

  Map<String, dynamic> _decode(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>();
}
