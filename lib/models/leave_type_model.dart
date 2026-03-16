class LeaveTypeModel {
  final String id;
  final String name;
  final String organizationId;
  final DateTime createdAt;

  const LeaveTypeModel({
    required this.id,
    required this.name,
    required this.organizationId,
    required this.createdAt,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      organizationId: json['organization_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
