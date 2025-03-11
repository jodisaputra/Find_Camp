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
      id: json['id'],
      name: json['name'],
      imageUrl: json['image'],
    );
  }
}
