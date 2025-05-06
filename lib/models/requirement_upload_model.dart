class RequirementUpload {
  final int id;
  final int userId;
  final int countryId;
  final int requirementId;
  final String filePath;
  final String status;
  final String? adminNote;
  final DateTime createdAt;

  RequirementUpload({
    required this.id,
    required this.userId,
    required this.countryId,
    required this.requirementId,
    required this.filePath,
    required this.status,
    this.adminNote,
    required this.createdAt,
  });

  factory RequirementUpload.fromJson(Map<String, dynamic> json) {
    return RequirementUpload(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      countryId: int.parse(json['country_id'].toString()),
      requirementId: int.parse(json['requirement_id'].toString()),
      filePath: json['file_path'],
      status: json['status'],
      adminNote: json['admin_note'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
} 