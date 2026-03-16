import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/supabase/supabase_config.dart';
import '../core/errors/error_mapper.dart';
import '../models/leave_type_model.dart';

class LeaveTypeService {
  final _client = SupabaseConfig.client;

  static const _table = 'leave_types';

  Future<List<LeaveTypeModel>> getLeaveTypes() async {
    try {
      debugPrint('[LeaveTypeService] fetching leave types');
      final raw = await _client.from(_table).select().order('name');
      final list =
          (jsonDecode(jsonEncode(raw)) as List).cast<Map<String, dynamic>>();
      debugPrint('[LeaveTypeService] fetched ${list.length} types');
      return list.map(LeaveTypeModel.fromJson).toList();
    } catch (e, st) {
      debugPrint('[LeaveTypeService] ERROR fetching types: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load leave types.');
    }
  }

  Future<LeaveTypeModel> createLeaveType({
    required String name,
    required String organizationId,
  }) async {
    try {
      final raw = await _client
          .from(_table)
          .insert({'name': name.trim(), 'organization_id': organizationId})
          .select()
          .single();
      return LeaveTypeModel.fromJson(
          (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>());
    } catch (e, st) {
      debugPrint('[LeaveTypeService] ERROR creating type: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to create leave type.');
    }
  }

  Future<LeaveTypeModel> updateLeaveType({
    required String id,
    required String name,
  }) async {
    try {
      final raw = await _client
          .from(_table)
          .update({'name': name.trim()})
          .eq('id', id)
          .select()
          .single();
      return LeaveTypeModel.fromJson(
          (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>());
    } catch (e, st) {
      debugPrint('[LeaveTypeService] ERROR updating type: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to update leave type.');
    }
  }

  Future<void> deleteLeaveType(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (e, st) {
      debugPrint('[LeaveTypeService] ERROR deleting type: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to delete leave type.');
    }
  }
}
