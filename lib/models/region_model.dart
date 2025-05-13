class Region {
  final int id;
  final String name;
  final String imageUrl;

  Region({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'],
      imageUrl: json['image'],
    );
  }
}
