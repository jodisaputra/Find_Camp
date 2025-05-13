import 'package:json_annotation/json_annotation.dart';

part 'requirement.g.dart';

@JsonSerializable()
class Requirement {
  final int id;
  final String requirementName;
  final bool status;
  final bool requiresPayment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Requirement({
    required this.id,
    required this.requirementName,
    required this.status,
    required this.requiresPayment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Requirement.fromJson(Map<String, dynamic> json) => _$RequirementFromJson(json);
  Map<String, dynamic> toJson() => _$RequirementToJson(this);
} 