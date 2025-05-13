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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      countryId: int.tryParse(json['country_id']?.toString() ?? '') ?? 0,
      requirementId: int.tryParse(json['requirement_id']?.toString() ?? '') ?? 0,
      filePath: json['file_path']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      adminNote: json['admin_note']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
} 