// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  type: json['type'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  isRead: json['is_read'] as bool? ?? false,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'type': instance.type,
  'title': instance.title,
  'body': instance.body,
  'is_read': instance.isRead,
  'metadata': instance.metadata,
  'created_at': instance.createdAt?.toIso8601String(),
};
