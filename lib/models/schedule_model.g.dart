// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleModelImpl _$$ScheduleModelImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      details:
          (json['details'] as List<dynamic>?)
              ?.map(
                (e) => ScheduleDetailModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ScheduleModelImplToJson(_$ScheduleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'details': instance.details.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt?.toIso8601String(),
    };

_$ScheduleDetailModelImpl _$$ScheduleDetailModelImplFromJson(
  Map<String, dynamic> json,
) => _$ScheduleDetailModelImpl(
  id: json['id'] as String,
  scheduleId: json['schedule_id'] as String,
  dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  periodLabel: json['period_label'] as String?,
);

Map<String, dynamic> _$$ScheduleDetailModelImplToJson(
  _$ScheduleDetailModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'schedule_id': instance.scheduleId,
  'day_of_week': instance.dayOfWeek,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'period_label': instance.periodLabel,
};
