import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_mapper.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final _client = SupabaseConfig.client;

  Future<List<ScheduleModel>> getSchedules() async {
    try {
      final raw = await _client
          .from(AppConstants.tableSchedules)
          .select('*, schedule_details(*)')
          .order('name');
      return _decodeList(raw).map((json) {
        return ScheduleModel.fromJson({
          ...json,
          'details': json['schedule_details'],
        });
      }).toList();
    } catch (e, st) {
      debugPrint('[ScheduleService] ERROR fetching schedules: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load schedules.');
    }
  }

  Future<ScheduleModel?> getSchedule(String id) async {
    try {
      final raw = await _client
          .from(AppConstants.tableSchedules)
          .select('*, schedule_details(*)')
          .eq('id', id)
          .maybeSingle();

      if (raw == null) return null;
      final json = _decodeMap(raw);
      return ScheduleModel.fromJson({
        ...json,
        'details': json['schedule_details'],
      });
    } catch (e, st) {
      debugPrint('[ScheduleService] ERROR fetching schedule $id: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load schedule details.');
    }
  }

  Future<ScheduleModel> createSchedule({
    required String name,
    required String type,
    required List<Map<String, dynamic>> details,
  }) async {
    try {
      final schedData = await _client
          .from(AppConstants.tableSchedules)
          .insert({'name': name, 'type': type})
          .select()
          .single();

      final scheduleId = _decodeMap(schedData)['id'] as String;

      final detailsWithId = details
          .map((d) => {...d, 'schedule_id': scheduleId})
          .toList();

      await _client.from(AppConstants.tableScheduleDetails).insert(detailsWithId);

      return (await getSchedule(scheduleId))!;
    } catch (e, st) {
      debugPrint('[ScheduleService] ERROR creating schedule: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to create schedule.');
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      await _client.from(AppConstants.tableSchedules).delete().eq('id', id);
    } catch (e, st) {
      debugPrint('[ScheduleService] ERROR deleting schedule $id: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to delete schedule.');
    }
  }

  List<Map<String, dynamic>> _decodeList(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> _decodeMap(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>();
}
