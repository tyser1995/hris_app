// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceModelImpl _$$AttendanceModelImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceModelImpl(
  id: json['id'] as String,
  employeeId: json['employee_id'] as String,
  employeeCode: json['employee_code'] as String?,
  employeeFullName: json['employee_full_name'] as String?,
  date: DateTime.parse(json['date'] as String),
  timeIn: json['time_in'] == null
      ? null
      : DateTime.parse(json['time_in'] as String),
  timeOut: json['time_out'] == null
      ? null
      : DateTime.parse(json['time_out'] as String),
  scheduleId: json['schedule_id'] as String?,
  lateMinutes: (json['late_minutes'] as num?)?.toInt() ?? 0,
  undertimeMinutes: (json['undertime_minutes'] as num?)?.toInt() ?? 0,
  overtimeMinutes: (json['overtime_minutes'] as num?)?.toInt() ?? 0,
  status: json['status'] as String,
  source: json['source'] as String? ?? 'web',
  notes: json['notes'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$AttendanceModelImplToJson(
  _$AttendanceModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'employee_id': instance.employeeId,
  'employee_code': instance.employeeCode,
  'employee_full_name': instance.employeeFullName,
  'date': instance.date.toIso8601String(),
  'time_in': instance.timeIn?.toIso8601String(),
  'time_out': instance.timeOut?.toIso8601String(),
  'schedule_id': instance.scheduleId,
  'late_minutes': instance.lateMinutes,
  'undertime_minutes': instance.undertimeMinutes,
  'overtime_minutes': instance.overtimeMinutes,
  'status': instance.status,
  'source': instance.source,
  'notes': instance.notes,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
