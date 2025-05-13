import 'package:json_annotation/json_annotation.dart';
import 'requirement.dart';

part 'requirement_upload.g.dart';

@JsonSerializable()
class RequirementUpload {
  final int id;
  final int userId;
  final int countryId;
  final int requirementId;
  final String filePath;
  final String status;
  final String? adminNote;
  final String? paymentPath;
  final String? paymentStatus;
  final String? paymentNote;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Requirement requirement;

  RequirementUpload({
    required this.id,
    required this.userId,
    required this.countryId,
    required this.requirementId,
    required this.filePath,
    required this.status,
    this.adminNote,
    this.paymentPath,
    this.paymentStatus,
    this.paymentNote,
    required this.createdAt,
    required this.updatedAt,
    required this.requirement,
  });

  factory RequirementUpload.fromJson(Map<String, dynamic> json) => _$RequirementUploadFromJson(json);
  Map<String, dynamic> toJson() => _$RequirementUploadToJson(this);

  String get fileUrl => filePath;
  String? get paymentUrl => paymentPath;
  bool get requiresPayment => requirement.requiresPayment;
  bool get hasPaymentUploaded => paymentPath != null;
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentAccepted => paymentStatus == 'accepted';
  bool get isPaymentRefused => paymentStatus == 'refused';
} 