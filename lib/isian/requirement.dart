class Requirement {
  final int id;
  final String requirementName;
  final String? notes;
  final bool requiresPayment;
  final bool isRequired;

  Requirement({
    required this.id,
    required this.requirementName,
    this.notes,
    required this.requiresPayment,
    required this.isRequired,
  });

  factory Requirement.fromJson(Map<String, dynamic> json) {
    return Requirement(
      id: json['id'],
      requirementName: json['requirement_name'],
      notes: json['notes'],
      requiresPayment: json['requires_payment'] ?? false,
      isRequired: json['is_required'] ?? false,
    );
  }
} 