import 'dart:io';

import 'package:find_camp/Config/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = '${Config.BASE_URL}/api';
  static const String storageUrl = '${Config.BASE_URL}/storage';

  static String getStorageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$storageUrl/$path';
  }

  // Helper method to get firebase token
  Future<String?> _getFirebaseToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');
      final token = await user.getIdToken();
      return token;
    } catch (e) {
      print('Error getting Firebase token: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getRegions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/regions'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final regions = List<Map<String, dynamic>>.from(data['data']);
        return regions.map((region) {
          if (region['image_url'] != null) {
            region['image_url'] = getStorageUrl(region['image_url'].toString());
          }
          return region;
        }).toList();
      } else {
        throw Exception('Failed to load regions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getRegions: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/countries'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final countries = List<Map<String, dynamic>>.from(data['data']);
        return countries.map((country) {
          if (country['flag_url'] != null) {
            country['flag_url'] = getStorageUrl(country['flag_url'].toString());
          }
          return country;
        }).toList();
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getCountries: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchCountries(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/countries?search=$query'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to search countries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in searchCountries: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCountriesByRegion(String region) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/countries?region=$region'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(
            'Failed to load countries by region: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getCountriesByRegion: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Get user data
  Future<Map<String, dynamic>> getUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      final token = await _getFirebaseToken();
      if (token == null) throw Exception('Failed to get authentication token');

      print('Making request to: $baseUrl/user'); // Debug log
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'firebase_uid': user.uid,
        },
      ).timeout(const Duration(seconds: 10));

      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['user'];

        // Convert profile image path to full URL if exists
        if (userData['profile_image'] != null) {
          userData['profile_image_url'] =
              getStorageUrl(userData['profile_image']);
        }

        return userData;
      } else {
        throw Exception(
            'Failed to load user data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getUserData: $e');
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? dateOfBirth,
    int? countryId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      final token = await _getFirebaseToken();
      if (token == null) throw Exception('Failed to get authentication token');

      final response = await http
          .post(
            Uri.parse('$baseUrl/user/update'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'firebase_uid': user.uid,
            },
            body: jsonEncode({
              'name': name,
              'date_of_birth': dateOfBirth,
              'country_id': countryId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['user'];
      } else {
        throw Exception(
            'Failed to update profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in updateProfile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update profile image
  Future<String> updateProfileImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      final token = await _getFirebaseToken();
      if (token == null) throw Exception('Failed to get authentication token');

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/update-image'),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'firebase_uid': user.uid,
      });

      // Add file
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'profile_image',
        stream,
        length,
        filename: 'profile_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Image upload response: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['profile_image_url'];
      } else {
        throw Exception(
            'Failed to update profile image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in updateProfileImage: $e');
      throw Exception('Failed to update profile image: $e');
    }
  }
}
