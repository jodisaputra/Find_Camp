// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requirement_upload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequirementUpload _$RequirementUploadFromJson(Map<String, dynamic> json) =>
    RequirementUpload(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      countryId: (json['countryId'] as num).toInt(),
      requirementId: (json['requirementId'] as num).toInt(),
      filePath: json['filePath'] as String,
      status: json['status'] as String,
      adminNote: json['adminNote'] as String?,
      paymentPath: json['paymentPath'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      paymentNote: json['paymentNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      requirement:
          Requirement.fromJson(json['requirement'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RequirementUploadToJson(RequirementUpload instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'countryId': instance.countryId,
      'requirementId': instance.requirementId,
      'filePath': instance.filePath,
      'status': instance.status,
      'adminNote': instance.adminNote,
      'paymentPath': instance.paymentPath,
      'paymentStatus': instance.paymentStatus,
      'paymentNote': instance.paymentNote,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'requirement': instance.requirement,
    };
