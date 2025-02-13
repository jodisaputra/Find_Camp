class Region {
  final int id;
  final String name;
  final String? imageUrl;  // Make nullable

  Region({
    required this.id,
    required this.name,
    this.imageUrl,  // Make optional
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] ?? 0,  // Provide default value
      name: json['name'] ?? '',  // Provide default value
      imageUrl: json['image'],  // Can be null
    );
  }
}
