import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_model.freezed.dart';
part 'employee_model.g.dart';

@freezed
class EmployeeModel with _$EmployeeModel {
  const factory EmployeeModel({
    required String id,
    String? userId,
    required String employeeCode,
    required String firstName,
    required String lastName,
    String? middleName,
    required String employmentType,
    String? departmentId,
    String? departmentName,
    String? positionId,
    String? positionTitle,
    String? supervisorId,
    String? scheduleId,
    required DateTime hireDate,
    required String employmentStatus,
    DateTime? contractStart,
    DateTime? contractEnd,
    String? address,
    String? phone,
    required String email,
    DateTime? birthdate,
    String? civilStatus,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EmployeeModel;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);
}

extension EmployeeModelX on EmployeeModel {
  String get fullName => '$firstName $lastName';

  String get displayName => '$lastName, $firstName${middleName != null ? ' ${middleName![0]}.' : ''}';

  bool get isContractExpiringSoon {
    if (contractEnd == null) return false;
    return contractEnd!.difference(DateTime.now()).inDays <= 30;
  }

  bool get isActive => employmentStatus == 'active';
}
