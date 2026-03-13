import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_model.freezed.dart';
part 'schedule_model.g.dart';

@freezed
class ScheduleModel with _$ScheduleModel {
  const factory ScheduleModel({
    required String id,
    required String name,
    required String type,
    @Default([]) List<ScheduleDetailModel> details,
    DateTime? createdAt,
  }) = _ScheduleModel;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);
}

@freezed
class ScheduleDetailModel with _$ScheduleDetailModel {
  const factory ScheduleDetailModel({
    required String id,
    required String scheduleId,
    int? dayOfWeek,
    required String startTime,
    required String endTime,
    String? periodLabel,
  }) = _ScheduleDetailModel;

  factory ScheduleDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleDetailModelFromJson(json);
}
