import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_request_model.freezed.dart';
part 'leave_request_model.g.dart';

@freezed
class LeaveRequestModel with _$LeaveRequestModel {
  const factory LeaveRequestModel({
    required String id,
    required String employeeId,
    String? employeeFullName,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required double daysRequested,
    String? reason,
    required String status,
    String? supervisorId,
    DateTime? supervisorActionAt,
    String? supervisorRemarks,
    String? hrApproverId,
    DateTime? hrActionAt,
    String? hrRemarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _LeaveRequestModel;

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestModelFromJson(json);
}

extension LeaveRequestModelX on LeaveRequestModel {
  bool get isPending =>
      status == 'pending_supervisor' || status == 'pending_hr';

  bool get isApproved => status == 'approved';

  bool get isRejected => status == 'rejected';

  String get leaveTypeLabel {
    switch (leaveType) {
      case 'vacation':
        return 'Vacation Leave';
      case 'sick':
        return 'Sick Leave';
      case 'emergency':
        return 'Emergency Leave';
      case 'maternity':
        return 'Maternity Leave';
      case 'paternity':
        return 'Paternity Leave';
      case 'without_pay':
        return 'Leave Without Pay';
      default:
        return leaveType;
    }
  }
}
