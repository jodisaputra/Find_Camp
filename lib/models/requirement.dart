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

  factory Requirement.fromJson(Map<String, dynamic> json) => Requirement(
    id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
    requirementName: json['requirement_name'] as String? ?? '',
    status: json['status'] is bool ? json['status'] : (json['status'].toString() == 'true'),
    requiresPayment: json['requires_payment'] is bool ? json['requires_payment'] : (json['requires_payment'].toString() == 'true'),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
  Map<String, dynamic> toJson() => _$RequirementToJson(this);
} 