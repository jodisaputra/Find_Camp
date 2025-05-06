import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/requirement_model.dart';
import '../models/requirement_upload_model.dart';

class RequirementService {
  // Get requirements for a specific country
  Future<List<Requirement>> getRequirementsByCountry(int countryId) async {
    final url = '${ApiConfig.countriesEndpoint}/$countryId/requirements';
    final response = await http.get(
      Uri.parse(url),
      headers: ApiConfig.getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Requirement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load requirements: \n${response.body}');
    }
  }

  // Get the user's upload for a requirement
  Future<RequirementUpload?> getUserRequirementUpload({
    required int countryId,
    required int requirementId,
    required String token,
  }) async {
    final url = '${ApiConfig.baseUrl}/api/requirement-uploads/$countryId/$requirementId';
    final response = await http.get(
      Uri.parse(url),
      headers: ApiConfig.getHeaders(token: token),
    );
    if (response.statusCode == 200) {
      return RequirementUpload.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to get upload: ${response.body}');
    }
  }

  // Upload a file for a requirement
  Future<RequirementUpload> uploadRequirementFile({
    required int countryId,
    required int requirementId,
    required File file,
    required String token,
  }) async {
    final url = '${ApiConfig.baseUrl}/api/requirement-uploads';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(ApiConfig.getHeaders(token: token));
    request.fields['country_id'] = countryId.toString();
    request.fields['requirement_id'] = requirementId.toString();
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 201) {
      return RequirementUpload.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload file: ${response.body}');
    }
  }

  // Get the file download URL
  String getFileUrl(int uploadId) {
    return '${ApiConfig.baseUrl}/api/requirement-uploads/file/$uploadId';
  }
} 