// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) {
  return _AttendanceModel.fromJson(json);
}

/// @nodoc
mixin _$AttendanceModel {
  String get id => throw _privateConstructorUsedError;
  String get employeeId => throw _privateConstructorUsedError;
  String? get employeeCode => throw _privateConstructorUsedError;
  String? get employeeFullName => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  DateTime? get timeIn => throw _privateConstructorUsedError;
  DateTime? get timeOut => throw _privateConstructorUsedError;
  String? get scheduleId => throw _privateConstructorUsedError;
  int get lateMinutes => throw _privateConstructorUsedError;
  int get undertimeMinutes => throw _privateConstructorUsedError;
  int get overtimeMinutes => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AttendanceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceModelCopyWith<AttendanceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceModelCopyWith<$Res> {
  factory $AttendanceModelCopyWith(
    AttendanceModel value,
    $Res Function(AttendanceModel) then,
  ) = _$AttendanceModelCopyWithImpl<$Res, AttendanceModel>;
  @useResult
  $Res call({
    String id,
    String employeeId,
    String? employeeCode,
    String? employeeFullName,
    DateTime date,
    DateTime? timeIn,
    DateTime? timeOut,
    String? scheduleId,
    int lateMinutes,
    int undertimeMinutes,
    int overtimeMinutes,
    String status,
    String source,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$AttendanceModelCopyWithImpl<$Res, $Val extends AttendanceModel>
    implements $AttendanceModelCopyWith<$Res> {
  _$AttendanceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? employeeCode = freezed,
    Object? employeeFullName = freezed,
    Object? date = null,
    Object? timeIn = freezed,
    Object? timeOut = freezed,
    Object? scheduleId = freezed,
    Object? lateMinutes = null,
    Object? undertimeMinutes = null,
    Object? overtimeMinutes = null,
    Object? status = null,
    Object? source = null,
    Object? notes = freezed,
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
            employeeCode: freezed == employeeCode
                ? _value.employeeCode
                : employeeCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            employeeFullName: freezed == employeeFullName
                ? _value.employeeFullName
                : employeeFullName // ignore: cast_nullable_to_non_nullable
                      as String?,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            timeIn: freezed == timeIn
                ? _value.timeIn
                : timeIn // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            timeOut: freezed == timeOut
                ? _value.timeOut
                : timeOut // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            scheduleId: freezed == scheduleId
                ? _value.scheduleId
                : scheduleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            lateMinutes: null == lateMinutes
                ? _value.lateMinutes
                : lateMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            undertimeMinutes: null == undertimeMinutes
                ? _value.undertimeMinutes
                : undertimeMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            overtimeMinutes: null == overtimeMinutes
                ? _value.overtimeMinutes
                : overtimeMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AttendanceModelImplCopyWith<$Res>
    implements $AttendanceModelCopyWith<$Res> {
  factory _$$AttendanceModelImplCopyWith(
    _$AttendanceModelImpl value,
    $Res Function(_$AttendanceModelImpl) then,
  ) = __$$AttendanceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String employeeId,
    String? employeeCode,
    String? employeeFullName,
    DateTime date,
    DateTime? timeIn,
    DateTime? timeOut,
    String? scheduleId,
    int lateMinutes,
    int undertimeMinutes,
    int overtimeMinutes,
    String status,
    String source,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$AttendanceModelImplCopyWithImpl<$Res>
    extends _$AttendanceModelCopyWithImpl<$Res, _$AttendanceModelImpl>
    implements _$$AttendanceModelImplCopyWith<$Res> {
  __$$AttendanceModelImplCopyWithImpl(
    _$AttendanceModelImpl _value,
    $Res Function(_$AttendanceModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? employeeCode = freezed,
    Object? employeeFullName = freezed,
    Object? date = null,
    Object? timeIn = freezed,
    Object? timeOut = freezed,
    Object? scheduleId = freezed,
    Object? lateMinutes = null,
    Object? undertimeMinutes = null,
    Object? overtimeMinutes = null,
    Object? status = null,
    Object? source = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$AttendanceModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeId: null == employeeId
            ? _value.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeCode: freezed == employeeCode
            ? _value.employeeCode
            : employeeCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        employeeFullName: freezed == employeeFullName
            ? _value.employeeFullName
            : employeeFullName // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        timeIn: freezed == timeIn
            ? _value.timeIn
            : timeIn // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        timeOut: freezed == timeOut
            ? _value.timeOut
            : timeOut // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        scheduleId: freezed == scheduleId
            ? _value.scheduleId
            : scheduleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        lateMinutes: null == lateMinutes
            ? _value.lateMinutes
            : lateMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        undertimeMinutes: null == undertimeMinutes
            ? _value.undertimeMinutes
            : undertimeMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        overtimeMinutes: null == overtimeMinutes
            ? _value.overtimeMinutes
            : overtimeMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
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
class _$AttendanceModelImpl implements _AttendanceModel {
  const _$AttendanceModelImpl({
    required this.id,
    required this.employeeId,
    this.employeeCode,
    this.employeeFullName,
    required this.date,
    this.timeIn,
    this.timeOut,
    this.scheduleId,
    this.lateMinutes = 0,
    this.undertimeMinutes = 0,
    this.overtimeMinutes = 0,
    required this.status,
    this.source = 'web',
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory _$AttendanceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceModelImplFromJson(json);

  @override
  final String id;
  @override
  final String employeeId;
  @override
  final String? employeeCode;
  @override
  final String? employeeFullName;
  @override
  final DateTime date;
  @override
  final DateTime? timeIn;
  @override
  final DateTime? timeOut;
  @override
  final String? scheduleId;
  @override
  @JsonKey()
  final int lateMinutes;
  @override
  @JsonKey()
  final int undertimeMinutes;
  @override
  @JsonKey()
  final int overtimeMinutes;
  @override
  final String status;
  @override
  @JsonKey()
  final String source;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AttendanceModel(id: $id, employeeId: $employeeId, employeeCode: $employeeCode, employeeFullName: $employeeFullName, date: $date, timeIn: $timeIn, timeOut: $timeOut, scheduleId: $scheduleId, lateMinutes: $lateMinutes, undertimeMinutes: $undertimeMinutes, overtimeMinutes: $overtimeMinutes, status: $status, source: $source, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.employeeCode, employeeCode) ||
                other.employeeCode == employeeCode) &&
            (identical(other.employeeFullName, employeeFullName) ||
                other.employeeFullName == employeeFullName) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.timeIn, timeIn) || other.timeIn == timeIn) &&
            (identical(other.timeOut, timeOut) || other.timeOut == timeOut) &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            (identical(other.lateMinutes, lateMinutes) ||
                other.lateMinutes == lateMinutes) &&
            (identical(other.undertimeMinutes, undertimeMinutes) ||
                other.undertimeMinutes == undertimeMinutes) &&
            (identical(other.overtimeMinutes, overtimeMinutes) ||
                other.overtimeMinutes == overtimeMinutes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.notes, notes) || other.notes == notes) &&
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
    employeeCode,
    employeeFullName,
    date,
    timeIn,
    timeOut,
    scheduleId,
    lateMinutes,
    undertimeMinutes,
    overtimeMinutes,
    status,
    source,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceModelImplCopyWith<_$AttendanceModelImpl> get copyWith =>
      __$$AttendanceModelImplCopyWithImpl<_$AttendanceModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceModelImplToJson(this);
  }
}

abstract class _AttendanceModel implements AttendanceModel {
  const factory _AttendanceModel({
    required final String id,
    required final String employeeId,
    final String? employeeCode,
    final String? employeeFullName,
    required final DateTime date,
    final DateTime? timeIn,
    final DateTime? timeOut,
    final String? scheduleId,
    final int lateMinutes,
    final int undertimeMinutes,
    final int overtimeMinutes,
    required final String status,
    final String source,
    final String? notes,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$AttendanceModelImpl;

  factory _AttendanceModel.fromJson(Map<String, dynamic> json) =
      _$AttendanceModelImpl.fromJson;

  @override
  String get id;
  @override
  String get employeeId;
  @override
  String? get employeeCode;
  @override
  String? get employeeFullName;
  @override
  DateTime get date;
  @override
  DateTime? get timeIn;
  @override
  DateTime? get timeOut;
  @override
  String? get scheduleId;
  @override
  int get lateMinutes;
  @override
  int get undertimeMinutes;
  @override
  int get overtimeMinutes;
  @override
  String get status;
  @override
  String get source;
  @override
  String? get notes;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceModelImplCopyWith<_$AttendanceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
