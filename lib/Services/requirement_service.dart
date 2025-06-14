import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/requirement_model.dart';
import '../models/requirement_upload_model.dart';
import '../services/auth_service.dart';

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
    final url = Uri.parse('${ApiConfig.baseUrl}/api/requirement-uploads/$countryId/$requirementId');
    final headers = ApiConfig.getHeaders(token: token);
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Requirement upload API response (raw): ${response.body}");
      print("Requirement upload parsed data: $data");
      if (data is Map) {
         print("Requirement (if present): ");
         print(data['requirement']);
         print("Requires payment (if present): ");
         print(data['requirement']?['requires_payment']);
      }
      return RequirementUpload.fromJson(data);
    } else {
      print("Requirement upload API error (status: ${response.statusCode}): ${response.body}");
      return null;
    }
  }

  // Upload a file for a requirement
  Future<RequirementUpload> uploadRequirementFile({
    required int countryId,
    required int requirementId,
    required File file,
    required String token,
  }) async {
    const url = '${ApiConfig.baseUrl}/api/requirement-uploads';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(ApiConfig.getHeaders(token: token));
    request.fields['country_id'] = countryId.toString();
    request.fields['requirement_id'] = requirementId.toString();
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return RequirementUpload.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload file: ${response.body}');
    }
  }

  // Get the file download URL
  String getFileUrl(int uploadId) {
    return '${ApiConfig.baseUrl}/api/requirement-uploads/$uploadId/file';
  }

  // Get the file download URL with token
  Future<String> getFileUrlWithToken(int uploadId) async {
    return '${ApiConfig.baseUrl}/api/requirement-uploads/$uploadId/file';
  }

  // Upload a payment file for a requirement upload
  Future<RequirementUpload> uploadPaymentFile({
    required int uploadId,
    required File file,
    required String token,
  }) async {
    final url = '${ApiConfig.baseUrl}/api/requirement-uploads/$uploadId/payment';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(ApiConfig.getHeaders(token: token));
    request.files.add(await http.MultipartFile.fromPath('payment_file', file.path));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return RequirementUpload.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload payment file: ${response.body}');
    }
  }

  // Get the payment file download URL with token
  Future<String> getPaymentFileUrlWithToken(int uploadId) async {
    return '${ApiConfig.baseUrl}/api/requirement-uploads/$uploadId/payment-file';
  }

  // Get all uploads for the current user
  Future<List<RequirementUpload>> getAllUserRequirementUploads(String token) async {
    final url = '${ApiConfig.baseUrl}/api/requirement-uploads';
    final response = await http.get(
      Uri.parse(url),
      headers: ApiConfig.getHeaders(token: token),
    );
    print('Status: [4m${response.statusCode}[24m');
    print('Body: [4m${response.body}[24m');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final uploads = data['data'] as List;
      return uploads.map((json) => RequirementUpload.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load uploads: Status ${response.statusCode}\n${response.body}');
    }
  }

  // Get all uploads grouped by country and requirement
  Future<Map<int, Map<int, RequirementUpload>>> getGroupedUserRequirementUploads(String token) async {
    try {
      final uploads = await getAllUserRequirementUploads(token);
      final Map<int, Map<int, RequirementUpload>> grouped = {};
      for (final upload in uploads) {
        final countryId = upload.countryId;
        final requirementId = upload.requirementId;
        if (countryId != null && requirementId != null) {
          grouped.putIfAbsent(countryId, () => {});
          grouped[countryId]![requirementId] = upload;
        }
      }
      return grouped;
    } catch (e) {
      throw Exception('Error grouping uploads: $e');
    }
  }
} 