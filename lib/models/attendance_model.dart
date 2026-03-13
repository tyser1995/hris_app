import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

@freezed
class AttendanceModel with _$AttendanceModel {
  const factory AttendanceModel({
    required String id,
    required String employeeId,
    String? employeeCode,
    String? employeeFullName,
    required DateTime date,
    DateTime? timeIn,
    DateTime? timeOut,
    String? scheduleId,
    @Default(0) int lateMinutes,
    @Default(0) int undertimeMinutes,
    @Default(0) int overtimeMinutes,
    required String status,
    @Default('web') String source,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AttendanceModel;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);
}

extension AttendanceModelX on AttendanceModel {
  double get overtimeHours => overtimeMinutes / 60;

  bool get isCheckedOut => timeOut != null;

  Duration? get totalWorkDuration {
    if (timeIn == null || timeOut == null) return null;
    return timeOut!.difference(timeIn!);
  }
}
