class Requirement {
  final int id;
  final String requirementName;
  final bool status;

  Requirement({
    required this.id,
    required this.requirementName,
    required this.status,
  });

  factory Requirement.fromJson(Map<String, dynamic> json) {
    return Requirement(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      requirementName: json['requirement_name'],
      status: json['status'] is bool ? json['status'] : json['status'] == 1,
    );
  }
} 