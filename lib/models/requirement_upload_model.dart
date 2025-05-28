import 'requirement_model.dart';

class RequirementUpload {
  final int id;
  final int userId;
  final int countryId;
  final int requirementId;
  final String filePath;
  final String status;
  final String? adminNote;
  final DateTime createdAt;
  final String? paymentPath;
  final String? paymentStatus;
  final String? paymentNote;
  final Requirement? requirement;
  final String? adminDocumentPath;

  RequirementUpload({
    required this.id,
    required this.userId,
    required this.countryId,
    required this.requirementId,
    required this.filePath,
    required this.status,
    this.adminNote,
    required this.createdAt,
    this.paymentPath,
    this.paymentStatus,
    this.paymentNote,
    this.requirement,
    this.adminDocumentPath,
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
      paymentPath: json['payment_path']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      paymentNote: json['payment_note']?.toString(),
      requirement: json['requirement'] != null ? Requirement.fromJson(json['requirement']) : null,
      adminDocumentPath: json['admin_document_path'],
    );
  }
} 