class CompanySettingsModel {
  final String employeeCodePattern;
  final int employeeCodeSequence;
  final String? companyName;

  const CompanySettingsModel({
    required this.employeeCodePattern,
    required this.employeeCodeSequence,
    this.companyName,
  });

  factory CompanySettingsModel.fromJson(Map<String, dynamic> json) =>
      CompanySettingsModel(
        employeeCodePattern:
            json['employee_code_pattern'] as String? ?? 'YY-###',
        employeeCodeSequence:
            json['employee_code_sequence'] as int? ?? 0,
        companyName: json['company_name'] as String?,
      );

  CompanySettingsModel copyWith({
    String? employeeCodePattern,
    int? employeeCodeSequence,
    String? companyName,
  }) =>
      CompanySettingsModel(
        employeeCodePattern:
            employeeCodePattern ?? this.employeeCodePattern,
        employeeCodeSequence:
            employeeCodeSequence ?? this.employeeCodeSequence,
        companyName: companyName ?? this.companyName,
      );

  static const CompanySettingsModel defaults = CompanySettingsModel(
    employeeCodePattern: 'YY-###',
    employeeCodeSequence: 0,
  );
}
