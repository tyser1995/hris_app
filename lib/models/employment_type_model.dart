class EmploymentTypeModel {
  final String id;
  final String name;
  final String? organizationId;
  final DateTime createdAt;

  const EmploymentTypeModel({
    required this.id,
    required this.name,
    this.organizationId,
    required this.createdAt,
  });

  factory EmploymentTypeModel.fromJson(Map<String, dynamic> json) =>
      EmploymentTypeModel(
        id: json['id'] as String,
        name: json['name'] as String,
        organizationId: json['organization_id'] as String?,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}
