class Requirement {
  final int id;
  final String requirementName;
  final bool status;
  final bool requiresPayment;
  final String? notes;

  Requirement({
    required this.id,
    required this.requirementName,
    required this.status,
    required this.requiresPayment,
    this.notes,
  });

  factory Requirement.fromJson(Map<String, dynamic> json) {
    return Requirement(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      requirementName: json['requirement_name'],
      status: json['status'] is bool ? json['status'] : json['status'] == 1,
      requiresPayment: json['requires_payment'] is bool ? json['requires_payment'] : json['requires_payment'] == 1,
      notes: json['notes'],
    );
  }
} 