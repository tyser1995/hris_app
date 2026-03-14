class CompanySettingsModel {
  final String? organizationId; // null when falling back to singleton
  final String employeeCodePattern;
  final int employeeCodeSequence;
  final String? companyName;
  final String? systemTitle;
  final String? primaryColor; // hex e.g. '#2563EB'
  final String? logoUrl;

  const CompanySettingsModel({
    this.organizationId,
    required this.employeeCodePattern,
    required this.employeeCodeSequence,
    this.companyName,
    this.systemTitle,
    this.primaryColor,
    this.logoUrl,
  });

  /// Maps from the legacy `company_settings` singleton row.
  factory CompanySettingsModel.fromJson(Map<String, dynamic> json) =>
      CompanySettingsModel(
        employeeCodePattern:
            json['employee_code_pattern'] as String? ?? 'YY-###',
        employeeCodeSequence: json['employee_code_sequence'] as int? ?? 0,
        companyName: json['company_name'] as String?,
        systemTitle: json['system_title'] as String?,
        primaryColor: json['primary_color'] as String?,
        logoUrl: json['logo_url'] as String?,
      );

  /// Maps from the `organizations` table (multi-tenant).
  factory CompanySettingsModel.fromOrgJson(Map<String, dynamic> json) =>
      CompanySettingsModel(
        organizationId: json['id'] as String?,
        employeeCodePattern:
            json['employee_code_pattern'] as String? ?? 'YY-###',
        employeeCodeSequence: json['employee_code_sequence'] as int? ?? 0,
        companyName: json['name'] as String?,
        systemTitle: json['system_title'] as String?,
        primaryColor: json['primary_color'] as String?,
        logoUrl: json['logo_url'] as String?,
      );

  CompanySettingsModel copyWith({
    String? organizationId,
    String? employeeCodePattern,
    int? employeeCodeSequence,
    String? companyName,
    String? systemTitle,
    String? primaryColor,
    String? logoUrl,
  }) =>
      CompanySettingsModel(
        organizationId: organizationId ?? this.organizationId,
        employeeCodePattern:
            employeeCodePattern ?? this.employeeCodePattern,
        employeeCodeSequence:
            employeeCodeSequence ?? this.employeeCodeSequence,
        companyName: companyName ?? this.companyName,
        systemTitle: systemTitle ?? this.systemTitle,
        primaryColor: primaryColor ?? this.primaryColor,
        logoUrl: logoUrl ?? this.logoUrl,
      );

  static const CompanySettingsModel defaults = CompanySettingsModel(
    employeeCodePattern: 'YY-###',
    employeeCodeSequence: 0,
  );
}
