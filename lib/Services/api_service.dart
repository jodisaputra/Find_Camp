import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:find_camp/models/requirement_upload.dart';
import 'package:find_camp/models/requirement.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  
  // Get all regions
  Future<List<Map<String, dynamic>>> getRegions() async {
    final response = await http.get(
      Uri.parse(ApiConfig.regionsEndpoint),
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
    String url = ApiConfig.countriesEndpoint;
    
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
      Uri.parse('${ApiConfig.baseUrl}/api/countries/$countryId'),
      headers: {'Accept': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } catch (e) {
        print('Error parsing response: $e');
        throw Exception('Failed to parse country details: $e');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Country not found');
    } else {
      throw Exception('Failed to load country details: ${response.statusCode} - ${response.body}');
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

  // Generic GET method
  Future<http.Response> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      headers: {'Accept': 'application/json'},
    );
    return response;
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token being sent: ${token ?? 'NULL'}');
    return token;
  }

  static Future<List<RequirementUpload>> getRequirementUploads() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/requirement-uploads'),
      headers: ApiConfig.getHeaders(token: token),
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['data'] != null) {
          final List<dynamic> data = body['data'];
          return data.map((json) => RequirementUpload.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format: missing data field');
        }
      } catch (e) {
        print('Error parsing response: $e');
        throw Exception('Failed to parse response: $e');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please login again');
    } else {
      throw Exception('Failed to load requirement uploads: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> uploadFile(
    int uploadId,
    File file,
    String fileName,
  ) async {
    final token = await _getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/requirement-uploads/$uploadId/file'),
    );
    request.headers.addAll(ApiConfig.getHeaders(token: token));
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: fileName,
      ),
    );
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    final respJson = json.decode(respStr);

    if (response.statusCode == 200 && respJson['status'] == 'success') {
      // Success
      return;
    } else {
      throw Exception('Failed to upload file: $respStr');
    }
  }

  static Future<void> uploadPaymentFile(
    int uploadId,
    File file,
    String fileName,
  ) async {
    final token = await _getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/requirement-uploads/$uploadId/payment'),
    );
    request.headers.addAll(ApiConfig.getHeaders(token: token));
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: fileName,
      ),
    );
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    final respJson = json.decode(respStr);

    if (response.statusCode == 200 && respJson['status'] == 'success') {
      // Success
      return;
    } else {
      throw Exception('Failed to upload payment file: $respStr');
    }
  }

  static Future<List<Requirement>> getRequirements() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/requirements'),
      headers: ApiConfig.getHeaders(token: token),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Requirement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load requirements');
    }
  }
}