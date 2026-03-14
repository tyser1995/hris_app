class OrgUserModel {
  final String userId;
  final String email;
  final String role;
  final String? organizationId;
  final String? organizationName;
  final DateTime? createdAt;
  final DateTime? emailConfirmedAt;
  final DateTime? lastSignInAt;

  const OrgUserModel({
    required this.userId,
    required this.email,
    required this.role,
    this.organizationId,
    this.organizationName,
    this.createdAt,
    this.emailConfirmedAt,
    this.lastSignInAt,
  });

  bool get isActivated => emailConfirmedAt != null;

  factory OrgUserModel.fromJson(Map<String, dynamic> json) => OrgUserModel(
        userId: json['user_id'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        organizationId: json['organization_id'] as String?,
        organizationName: json['organization_name'] as String?,
        createdAt: _parseDate(json['created_at']),
        emailConfirmedAt: _parseDate(json['email_confirmed_at']),
        lastSignInAt: _parseDate(json['last_sign_in_at']),
      );

  static DateTime? _parseDate(dynamic v) =>
      v == null ? null : DateTime.tryParse(v as String);
}
