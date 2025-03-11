class Country {
  final int id;
  final String name;
  final int regionId;
  final String regionName;
  final String flagUrl;
  final double rating;
  final String? description;

  Country({
    required this.id,
    required this.name,
    required this.regionId,
    required this.regionName,
    required this.flagUrl,
    required this.rating,
    this.description,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? region = json['region'];

    return Country(
      id: json['id'],
      name: json['name'],
      regionId: json['region_id'],
      regionName: region != null ? region['name'] : '',
      flagUrl: json['flag'],
      rating: double.parse(json['rating'].toString()),
      description: json['description'],
    );
  }
}
