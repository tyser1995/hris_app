// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaveRequestModelImpl _$$LeaveRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$LeaveRequestModelImpl(
  id: json['id'] as String,
  employeeId: json['employee_id'] as String,
  employeeFullName: json['employee_full_name'] as String?,
  leaveType: json['leave_type'] as String,
  startDate: DateTime.parse(json['start_date'] as String),
  endDate: DateTime.parse(json['end_date'] as String),
  daysRequested: (json['days_requested'] as num).toDouble(),
  reason: json['reason'] as String?,
  status: json['status'] as String,
  supervisorId: json['supervisor_id'] as String?,
  supervisorActionAt: json['supervisor_action_at'] == null
      ? null
      : DateTime.parse(json['supervisor_action_at'] as String),
  supervisorRemarks: json['supervisor_remarks'] as String?,
  hrApproverId: json['hr_approver_id'] as String?,
  hrActionAt: json['hr_action_at'] == null
      ? null
      : DateTime.parse(json['hr_action_at'] as String),
  hrRemarks: json['hr_remarks'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$LeaveRequestModelImplToJson(
  _$LeaveRequestModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'employee_id': instance.employeeId,
  'employee_full_name': instance.employeeFullName,
  'leave_type': instance.leaveType,
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate.toIso8601String(),
  'days_requested': instance.daysRequested,
  'reason': instance.reason,
  'status': instance.status,
  'supervisor_id': instance.supervisorId,
  'supervisor_action_at': instance.supervisorActionAt?.toIso8601String(),
  'supervisor_remarks': instance.supervisorRemarks,
  'hr_approver_id': instance.hrApproverId,
  'hr_action_at': instance.hrActionAt?.toIso8601String(),
  'hr_remarks': instance.hrRemarks,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
