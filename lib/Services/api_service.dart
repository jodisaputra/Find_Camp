import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  
  // Get all regions
  Future<List<Map<String, dynamic>>> getRegions() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.regionsEndpoint}'),
      headers: {'Accept': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to load regions: ${response.body}');
    }
  }
  
  // Get countries, optionally filtered by region or search term
  Future<List<Map<String, dynamic>>> getCountries({String? search, int? regionId}) async {
    String url = '${ApiConfig.countriesEndpoint}';
    
    // Add query parameters if provided
    if (search != null || regionId != null) {
      url += '?';
      if (search != null) {
        url += 'search=$search';
      }
      if (regionId != null) {
        url += search != null ? '&' : '';
        url += 'region_id=$regionId';
      }
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to load countries: ${response.body}');
    }
  }
  
  // Get a specific country by ID
  Future<Map<String, dynamic>> getCountryDetail(int countryId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.countriesEndpoint}/$countryId'),
      headers: {'Accept': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load country details: ${response.body}');
    }
  }
  
  // Get all countries for a specific region
  Future<List<Map<String, dynamic>>> getCountriesByRegion(int regionId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.regionsEndpoint}/$regionId/countries'),
      headers: {'Accept': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load countries for region: ${response.body}');
    }
  }
}