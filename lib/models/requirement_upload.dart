import 'package:json_annotation/json_annotation.dart';
import 'requirement.dart';
import 'country_model.dart';

part 'requirement_upload.g.dart';

@JsonSerializable()
class RequirementUpload {
  final int? id;
  final int? userId;
  final int? countryId;
  final int? requirementId;
  final String filePath;
  final String status;
  final String? adminNote;
  final String? paymentPath;
  final String? paymentStatus;
  final String? paymentNote;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Requirement requirement;
  final Country? country;

  RequirementUpload({
    this.id,
    this.userId,
    this.countryId,
    this.requirementId,
    required this.filePath,
    required this.status,
    this.adminNote,
    this.paymentPath,
    this.paymentStatus,
    this.paymentNote,
    required this.createdAt,
    required this.updatedAt,
    required this.requirement,
    this.country,
  });

  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory RequirementUpload.fromJson(Map<String, dynamic> json) => RequirementUpload(
    id: parseInt(json['id']),
    userId: parseInt(json['user_id']),
    countryId: parseInt(json['country_id']),
    requirementId: parseInt(json['requirement_id']),
    filePath: json['file_path'] as String? ?? '',
    status: json['status'] as String? ?? '',
    adminNote: json['admin_note'] as String?,
    paymentPath: json['payment_path'] as String?,
    paymentStatus: json['payment_status'] as String?,
    paymentNote: json['payment_note'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    requirement: Requirement.fromJson(json['requirement'] as Map<String, dynamic>),
    country: json['country'] != null ? Country.fromJson(json['country'] as Map<String, dynamic>) : null,
  );
  Map<String, dynamic> toJson() => _$RequirementUploadToJson(this);

  String get fileUrl => filePath;
  String? get paymentUrl => paymentPath;
  bool get requiresPayment => requirement.requiresPayment;
  bool get hasPaymentUploaded => paymentPath != null;
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentAccepted => paymentStatus == 'accepted';
  bool get isPaymentRefused => paymentStatus == 'refused';
} 