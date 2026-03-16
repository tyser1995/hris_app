import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_mapper.dart';
import '../models/employment_type_model.dart';

class EmploymentTypeService {
  final _client = SupabaseConfig.client;

  Future<List<EmploymentTypeModel>> getEmploymentTypes() async {
    try {
      debugPrint('[EmploymentTypeService] fetching employment types');
      final raw = await _client
          .from(AppConstants.tableEmploymentTypes)
          .select()
          .order('name');
      final list = (jsonDecode(jsonEncode(raw)) as List)
          .cast<Map<String, dynamic>>();
      debugPrint('[EmploymentTypeService] fetched ${list.length} types');
      return list.map(EmploymentTypeModel.fromJson).toList();
    } catch (e, st) {
      debugPrint('[EmploymentTypeService] ERROR fetching types: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load employment types.');
    }
  }

  Future<EmploymentTypeModel> createEmploymentType({
    required String name,
    required String organizationId,
  }) async {
    try {
      final raw = await _client
          .from(AppConstants.tableEmploymentTypes)
          .insert({'name': name.trim(), 'organization_id': organizationId})
          .select()
          .single();
      return EmploymentTypeModel.fromJson(
          (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>());
    } catch (e, st) {
      debugPrint('[EmploymentTypeService] ERROR creating type: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to create employment type.');
    }
  }

  Future<EmploymentTypeModel> updateEmploymentType({
    required String id,
    required String name,
  }) async {
    try {
      final raw = await _client
          .from(AppConstants.tableEmploymentTypes)
          .update({'name': name.trim()})
          .eq('id', id)
          .select()
          .single();
      return EmploymentTypeModel.fromJson(
          (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>());
    } catch (e, st) {
      debugPrint('[EmploymentTypeService] ERROR updating type: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to update employment type.');
    }
  }

  Future<void> deleteEmploymentType(String id) async {
    try {
      await _client
          .from(AppConstants.tableEmploymentTypes)
          .delete()
          .eq('id', id);
    } catch (e, st) {
      debugPrint('[EmploymentTypeService] ERROR deleting type: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to delete employment type.');
    }
  }
}
