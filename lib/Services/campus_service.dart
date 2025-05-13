import 'dart:convert';
import 'package:find_camp/services/api_service.dart';

class CampusService {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> getCampuses() async {
    try {
      final response = await _apiService.get('/api/campuses');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load campuses');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCampusesByCountry(String country) async {
    try {
      final response = await _apiService.get('/api/campuses/country/$country');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load campuses');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCampusesByCountryId(String countryId) async {
    try {
      final response = await _apiService.get('/api/campuses/country-id/$countryId');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) {
          return []; // Return empty list if no campuses found
        }
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load campuses: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('Error in getCampusesByCountryId: $e');
      throw Exception('Error fetching campuses: $e');
    }
  }

  Future<Map<String, dynamic>> getCampusDetail(String id) async {
    try {
      final response = await _apiService.get('/api/campuses/$id');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load campus details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 