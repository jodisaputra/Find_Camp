class Country {
  final int id;
  final String name;
  final int? regionId;
  final String? regionName;
  final String? flagUrl;
  final double? rating;
  final String? description;

  Country({
    required this.id,
    required this.name,
    this.regionId,
    this.regionName,
    this.flagUrl,
    this.rating,
    this.description,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? region = json['region'];

    return Country(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      regionId: json['region_id'] != null ? int.tryParse(json['region_id'].toString()) : null,
      regionName: region != null ? region['name'] as String? : null,
      flagUrl: json['flag'] as String?,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      description: json['description'] as String?,
    );
  }
}
