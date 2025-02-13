class Country {
  final int id;
  final String name;
  final String region;
  final String? flagUrl;  // Make nullable
  final double rating;

  Country({
    required this.id,
    required this.name,
    required this.region,
    this.flagUrl,  // Make optional
    required this.rating,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      flagUrl: json['flag'],
      rating: (json['rating'] != null)
          ? double.parse(json['rating'].toString())
          : 0.0,
    );
  }
}