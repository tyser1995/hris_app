// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DepartmentModelImpl _$$DepartmentModelImplFromJson(
  Map<String, dynamic> json,
) => _$DepartmentModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  headId: json['head_id'] as String?,
  headFullName: json['head_full_name'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$DepartmentModelImplToJson(
  _$DepartmentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'head_id': instance.headId,
  'head_full_name': instance.headFullName,
  'created_at': instance.createdAt?.toIso8601String(),
};
