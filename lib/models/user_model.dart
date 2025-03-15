class User {
  final int id;
  final String name;
  final String email;
  final String? profileImagePath;
  final String? googleId;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? dateOfBirth;
  final String? country;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImagePath,
    this.googleId,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.dateOfBirth,
    this.country,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImagePath: json['profile_image_path'],
      googleId: json['google_id'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      dateOfBirth: json['date_of_birth'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_path': profileImagePath,
      'google_id': googleId,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'date_of_birth': dateOfBirth,
      'country': country,
    };
  }
}