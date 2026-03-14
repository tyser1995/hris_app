class OrganizationModel {
  final String id;
  final String name;
  final String? systemTitle;
  final String? primaryColor;
  final String? logoUrl;
  final String employeeCodePattern;
  final int employeeCodeSequence;
  final DateTime createdAt;

  const OrganizationModel({
    required this.id,
    required this.name,
    this.systemTitle,
    this.primaryColor,
    this.logoUrl,
    required this.employeeCodePattern,
    required this.employeeCodeSequence,
    required this.createdAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) =>
      OrganizationModel(
        id: json['id'] as String,
        name: json['name'] as String,
        systemTitle: json['system_title'] as String?,
        primaryColor: json['primary_color'] as String?,
        logoUrl: json['logo_url'] as String?,
        employeeCodePattern:
            json['employee_code_pattern'] as String? ?? 'YY-###',
        employeeCodeSequence:
            json['employee_code_sequence'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}
