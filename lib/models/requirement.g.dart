// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requirement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Requirement _$RequirementFromJson(Map<String, dynamic> json) => Requirement(
      id: (json['id'] as num).toInt(),
      requirementName: json['requirementName'] as String,
      status: json['status'] as bool,
      requiresPayment: json['requiresPayment'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RequirementToJson(Requirement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requirementName': instance.requirementName,
      'status': instance.status,
      'requiresPayment': instance.requiresPayment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
