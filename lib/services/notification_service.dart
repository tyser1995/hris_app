import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:postgrest/postgrest.dart';
import '../config/supabase/supabase_config.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_mapper.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _client = SupabaseConfig.client;

  Future<List<NotificationModel>> getNotifications({
    required String userId,
    bool unreadOnly = false,
    int page = 0,
  }) async {
    final offset = page * AppConstants.pageSize;
    try {
      PostgrestFilterBuilder query = _client
          .from(AppConstants.tableNotifications)
          .select()
          .eq('user_id', userId);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final raw = await query
          .range(offset, offset + AppConstants.pageSize - 1)
          .order('created_at', ascending: false);

      return _decodeList(raw).map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e, st) {
      debugPrint('[NotificationService] ERROR fetching notifications: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to load notifications.');
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _client
          .from(AppConstants.tableNotifications)
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .count();
      return response.count;
    } catch (e, st) {
      debugPrint('[NotificationService] ERROR fetching unread count: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to fetch notification count.');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from(AppConstants.tableNotifications)
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e, st) {
      debugPrint('[NotificationService] ERROR marking notification as read: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to mark notification as read.');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from(AppConstants.tableNotifications)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e, st) {
      debugPrint('[NotificationService] ERROR marking all as read: $e\n$st');
      throw ErrorMapper.map(e, 'Failed to mark all notifications as read.');
    }
  }

  Stream<List<NotificationModel>> streamUnread(String userId) {
    return _client
        .from(AppConstants.tableNotifications)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) {
          return _decodeList(data)
              .map((e) => NotificationModel.fromJson(e))
              .where((n) => !n.isRead)
              .toList();
        });
  }

  List<Map<String, dynamic>> _decodeList(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as List).cast<Map<String, dynamic>>();

  Map<String, dynamic> _decodeMap(dynamic raw) =>
      (jsonDecode(jsonEncode(raw)) as Map).cast<String, dynamic>();
}
