// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmployeeModelImpl _$$EmployeeModelImplFromJson(Map<String, dynamic> json) =>
    _$EmployeeModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      employeeCode: json['employee_code'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      middleName: json['middle_name'] as String?,
      employmentType: json['employment_type'] as String,
      departmentId: json['department_id'] as String?,
      departmentName: json['department_name'] as String?,
      positionId: json['position_id'] as String?,
      positionTitle: json['position_title'] as String?,
      supervisorId: json['supervisor_id'] as String?,
      scheduleId: json['schedule_id'] as String?,
      hireDate: DateTime.parse(json['hire_date'] as String),
      employmentStatus: json['employment_status'] as String,
      contractStart: json['contract_start'] == null
          ? null
          : DateTime.parse(json['contract_start'] as String),
      contractEnd: json['contract_end'] == null
          ? null
          : DateTime.parse(json['contract_end'] as String),
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String,
      birthdate: json['birthdate'] == null
          ? null
          : DateTime.parse(json['birthdate'] as String),
      civilStatus: json['civil_status'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$EmployeeModelImplToJson(_$EmployeeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'employee_code': instance.employeeCode,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'middle_name': instance.middleName,
      'employment_type': instance.employmentType,
      'department_id': instance.departmentId,
      'department_name': instance.departmentName,
      'position_id': instance.positionId,
      'position_title': instance.positionTitle,
      'supervisor_id': instance.supervisorId,
      'schedule_id': instance.scheduleId,
      'hire_date': instance.hireDate.toIso8601String(),
      'employment_status': instance.employmentStatus,
      'contract_start': instance.contractStart?.toIso8601String(),
      'contract_end': instance.contractEnd?.toIso8601String(),
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'birthdate': instance.birthdate?.toIso8601String(),
      'civil_status': instance.civilStatus,
      'avatar_url': instance.avatarUrl,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
