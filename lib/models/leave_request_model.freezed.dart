// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeaveRequestModel _$LeaveRequestModelFromJson(Map<String, dynamic> json) {
  return _LeaveRequestModel.fromJson(json);
}

/// @nodoc
mixin _$LeaveRequestModel {
  String get id => throw _privateConstructorUsedError;
  String get employeeId => throw _privateConstructorUsedError;
  String? get employeeFullName => throw _privateConstructorUsedError;
  String get leaveType => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  double get daysRequested => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get supervisorId => throw _privateConstructorUsedError;
  DateTime? get supervisorActionAt => throw _privateConstructorUsedError;
  String? get supervisorRemarks => throw _privateConstructorUsedError;
  String? get hrApproverId => throw _privateConstructorUsedError;
  DateTime? get hrActionAt => throw _privateConstructorUsedError;
  String? get hrRemarks => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LeaveRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaveRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaveRequestModelCopyWith<LeaveRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveRequestModelCopyWith<$Res> {
  factory $LeaveRequestModelCopyWith(
    LeaveRequestModel value,
    $Res Function(LeaveRequestModel) then,
  ) = _$LeaveRequestModelCopyWithImpl<$Res, LeaveRequestModel>;
  @useResult
  $Res call({
    String id,
    String employeeId,
    String? employeeFullName,
    String leaveType,
    DateTime startDate,
    DateTime endDate,
    double daysRequested,
    String? reason,
    String status,
    String? supervisorId,
    DateTime? supervisorActionAt,
    String? supervisorRemarks,
    String? hrApproverId,
    DateTime? hrActionAt,
    String? hrRemarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$LeaveRequestModelCopyWithImpl<$Res, $Val extends LeaveRequestModel>
    implements $LeaveRequestModelCopyWith<$Res> {
  _$LeaveRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaveRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? employeeFullName = freezed,
    Object? leaveType = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? daysRequested = null,
    Object? reason = freezed,
    Object? status = null,
    Object? supervisorId = freezed,
    Object? supervisorActionAt = freezed,
    Object? supervisorRemarks = freezed,
    Object? hrApproverId = freezed,
    Object? hrActionAt = freezed,
    Object? hrRemarks = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            employeeId: null == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
                      as String,
            employeeFullName: freezed == employeeFullName
                ? _value.employeeFullName
                : employeeFullName // ignore: cast_nullable_to_non_nullable
                      as String?,
            leaveType: null == leaveType
                ? _value.leaveType
                : leaveType // ignore: cast_nullable_to_non_nullable
                      as String,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            daysRequested: null == daysRequested
                ? _value.daysRequested
                : daysRequested // ignore: cast_nullable_to_non_nullable
                      as double,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            supervisorId: freezed == supervisorId
                ? _value.supervisorId
                : supervisorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            supervisorActionAt: freezed == supervisorActionAt
                ? _value.supervisorActionAt
                : supervisorActionAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            supervisorRemarks: freezed == supervisorRemarks
                ? _value.supervisorRemarks
                : supervisorRemarks // ignore: cast_nullable_to_non_nullable
                      as String?,
            hrApproverId: freezed == hrApproverId
                ? _value.hrApproverId
                : hrApproverId // ignore: cast_nullable_to_non_nullable
                      as String?,
            hrActionAt: freezed == hrActionAt
                ? _value.hrActionAt
                : hrActionAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            hrRemarks: freezed == hrRemarks
                ? _value.hrRemarks
                : hrRemarks // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaveRequestModelImplCopyWith<$Res>
    implements $LeaveRequestModelCopyWith<$Res> {
  factory _$$LeaveRequestModelImplCopyWith(
    _$LeaveRequestModelImpl value,
    $Res Function(_$LeaveRequestModelImpl) then,
  ) = __$$LeaveRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String employeeId,
    String? employeeFullName,
    String leaveType,
    DateTime startDate,
    DateTime endDate,
    double daysRequested,
    String? reason,
    String status,
    String? supervisorId,
    DateTime? supervisorActionAt,
    String? supervisorRemarks,
    String? hrApproverId,
    DateTime? hrActionAt,
    String? hrRemarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$LeaveRequestModelImplCopyWithImpl<$Res>
    extends _$LeaveRequestModelCopyWithImpl<$Res, _$LeaveRequestModelImpl>
    implements _$$LeaveRequestModelImplCopyWith<$Res> {
  __$$LeaveRequestModelImplCopyWithImpl(
    _$LeaveRequestModelImpl _value,
    $Res Function(_$LeaveRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaveRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? employeeFullName = freezed,
    Object? leaveType = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? daysRequested = null,
    Object? reason = freezed,
    Object? status = null,
    Object? supervisorId = freezed,
    Object? supervisorActionAt = freezed,
    Object? supervisorRemarks = freezed,
    Object? hrApproverId = freezed,
    Object? hrActionAt = freezed,
    Object? hrRemarks = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$LeaveRequestModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeId: null == employeeId
            ? _value.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeFullName: freezed == employeeFullName
            ? _value.employeeFullName
            : employeeFullName // ignore: cast_nullable_to_non_nullable
                  as String?,
        leaveType: null == leaveType
            ? _value.leaveType
            : leaveType // ignore: cast_nullable_to_non_nullable
                  as String,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        daysRequested: null == daysRequested
            ? _value.daysRequested
            : daysRequested // ignore: cast_nullable_to_non_nullable
                  as double,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        supervisorId: freezed == supervisorId
            ? _value.supervisorId
            : supervisorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        supervisorActionAt: freezed == supervisorActionAt
            ? _value.supervisorActionAt
            : supervisorActionAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        supervisorRemarks: freezed == supervisorRemarks
            ? _value.supervisorRemarks
            : supervisorRemarks // ignore: cast_nullable_to_non_nullable
                  as String?,
        hrApproverId: freezed == hrApproverId
            ? _value.hrApproverId
            : hrApproverId // ignore: cast_nullable_to_non_nullable
                  as String?,
        hrActionAt: freezed == hrActionAt
            ? _value.hrActionAt
            : hrActionAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        hrRemarks: freezed == hrRemarks
            ? _value.hrRemarks
            : hrRemarks // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaveRequestModelImpl implements _LeaveRequestModel {
  const _$LeaveRequestModelImpl({
    required this.id,
    required this.employeeId,
    this.employeeFullName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.daysRequested,
    this.reason,
    required this.status,
    this.supervisorId,
    this.supervisorActionAt,
    this.supervisorRemarks,
    this.hrApproverId,
    this.hrActionAt,
    this.hrRemarks,
    this.createdAt,
    this.updatedAt,
  });

  factory _$LeaveRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveRequestModelImplFromJson(json);

  @override
  final String id;
  @override
  final String employeeId;
  @override
  final String? employeeFullName;
  @override
  final String leaveType;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final double daysRequested;
  @override
  final String? reason;
  @override
  final String status;
  @override
  final String? supervisorId;
  @override
  final DateTime? supervisorActionAt;
  @override
  final String? supervisorRemarks;
  @override
  final String? hrApproverId;
  @override
  final DateTime? hrActionAt;
  @override
  final String? hrRemarks;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'LeaveRequestModel(id: $id, employeeId: $employeeId, employeeFullName: $employeeFullName, leaveType: $leaveType, startDate: $startDate, endDate: $endDate, daysRequested: $daysRequested, reason: $reason, status: $status, supervisorId: $supervisorId, supervisorActionAt: $supervisorActionAt, supervisorRemarks: $supervisorRemarks, hrApproverId: $hrApproverId, hrActionAt: $hrActionAt, hrRemarks: $hrRemarks, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveRequestModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.employeeFullName, employeeFullName) ||
                other.employeeFullName == employeeFullName) &&
            (identical(other.leaveType, leaveType) ||
                other.leaveType == leaveType) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.daysRequested, daysRequested) ||
                other.daysRequested == daysRequested) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.supervisorId, supervisorId) ||
                other.supervisorId == supervisorId) &&
            (identical(other.supervisorActionAt, supervisorActionAt) ||
                other.supervisorActionAt == supervisorActionAt) &&
            (identical(other.supervisorRemarks, supervisorRemarks) ||
                other.supervisorRemarks == supervisorRemarks) &&
            (identical(other.hrApproverId, hrApproverId) ||
                other.hrApproverId == hrApproverId) &&
            (identical(other.hrActionAt, hrActionAt) ||
                other.hrActionAt == hrActionAt) &&
            (identical(other.hrRemarks, hrRemarks) ||
                other.hrRemarks == hrRemarks) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    employeeId,
    employeeFullName,
    leaveType,
    startDate,
    endDate,
    daysRequested,
    reason,
    status,
    supervisorId,
    supervisorActionAt,
    supervisorRemarks,
    hrApproverId,
    hrActionAt,
    hrRemarks,
    createdAt,
    updatedAt,
  );

  /// Create a copy of LeaveRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveRequestModelImplCopyWith<_$LeaveRequestModelImpl> get copyWith =>
      __$$LeaveRequestModelImplCopyWithImpl<_$LeaveRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveRequestModelImplToJson(this);
  }
}

abstract class _LeaveRequestModel implements LeaveRequestModel {
  const factory _LeaveRequestModel({
    required final String id,
    required final String employeeId,
    final String? employeeFullName,
    required final String leaveType,
    required final DateTime startDate,
    required final DateTime endDate,
    required final double daysRequested,
    final String? reason,
    required final String status,
    final String? supervisorId,
    final DateTime? supervisorActionAt,
    final String? supervisorRemarks,
    final String? hrApproverId,
    final DateTime? hrActionAt,
    final String? hrRemarks,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$LeaveRequestModelImpl;

  factory _LeaveRequestModel.fromJson(Map<String, dynamic> json) =
      _$LeaveRequestModelImpl.fromJson;

  @override
  String get id;
  @override
  String get employeeId;
  @override
  String? get employeeFullName;
  @override
  String get leaveType;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  double get daysRequested;
  @override
  String? get reason;
  @override
  String get status;
  @override
  String? get supervisorId;
  @override
  DateTime? get supervisorActionAt;
  @override
  String? get supervisorRemarks;
  @override
  String? get hrApproverId;
  @override
  DateTime? get hrActionAt;
  @override
  String? get hrRemarks;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of LeaveRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveRequestModelImplCopyWith<_$LeaveRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
