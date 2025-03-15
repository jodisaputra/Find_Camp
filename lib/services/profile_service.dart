import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'package:path/path.dart' as path;

class ProfileService {
  // Get user token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> userData, File? profileImage) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'You are not logged in',
        };
      }

      // If there's a profile image, use multipart request
      if (profileImage != null) {
        return _updateProfileWithImage(userData, profileImage, token);
      } else {
        return _updateProfileWithoutImage(userData, token);
      }
    } catch (e) {
      print('Error updating profile: $e');
      return {
        'success': false,
        'message': 'An error occurred during profile update: $e',
      };
    }
  }

  // Update profile with image (multipart request)
  Future<Map<String, dynamic>> _updateProfileWithImage(
      Map<String, dynamic> userData, File profileImage, String token) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/user/profile');

      print('Updating profile with image:');
      print('Image path: ${profileImage.path}');
      print('Image size: ${await profileImage.length()} bytes');
      print('Image extension: ${path.extension(profileImage.path)}');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add text fields - only add non-null fields
      if (userData['name'] != null) {
        request.fields['name'] = userData['name'].toString();
        print('Adding field: name = ${userData['name']}');
      }

      if (userData['email'] != null) {
        request.fields['email'] = userData['email'].toString();
        print('Adding field: email = ${userData['email']}');
      }

      if (userData['date_of_birth'] != null) {
        request.fields['date_of_birth'] = userData['date_of_birth'].toString();
        print('Adding field: date_of_birth = ${userData['date_of_birth']}');
      }

      if (userData['country'] != null) {
        request.fields['country'] = userData['country'].toString();
        print('Adding field: country = ${userData['country']}');
      }

      if (userData['password'] != null) {
        request.fields['password'] = userData['password'].toString();
        print('Adding field: password = [REDACTED]');

        if (userData['password_confirmation'] != null) {
          request.fields['password_confirmation'] =
              userData['password_confirmation'].toString();
        }
      }

      // Add the image with proper content type
      final extension = path.extension(profileImage.path).replaceFirst('.', '').toLowerCase();
      final contentType = MediaType('image', extension);
      
      final multipartFile = await http.MultipartFile.fromPath(
        'profile_image', // Match the field name in Laravel validator
        profileImage.path,
        contentType: contentType,
      );

      request.files.add(multipartFile);
      print('Added image to request with content type: ${contentType.toString()}');

      // Send the request
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30), // Increased timeout for image upload
          );

      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);

            // Update user data in shared preferences
            if (data['user'] != null) {
              await _updateStoredUserData(data['user']);
            }

            return {
              'success': true,
              'message': data['message'] ?? 'Profile updated successfully',
              'user': data['user'] != null ? User.fromJson(data['user']) : null,
            };
          } catch (e) {
            print('Error parsing JSON response: $e');
            // Check if it's an HTML error page
            if (response.body.contains('<html') ||
                response.body.contains('<!DOCTYPE') ||
                response.body.contains('<br') ||
                response.body.contains('<b>')) {
              return {
                'success': false,
                'message':
                    'Server returned an HTML error page. Please try again later.',
              };
            }
            return {
              'success': false,
              'message': 'Error parsing server response',
            };
          }
        } else {
          return {
            'success': false,
            'message': 'Server returned an empty response',
          };
        }
      } else {
        // Try to parse error response
        try {
          if (response.body.isNotEmpty) {
            if (response.body.contains('<html') ||
                response.body.contains('<!DOCTYPE') ||
                response.body.contains('<br') ||
                response.body.contains('<b>')) {
              return {
                'success': false,
                'message':
                    'Server returned an error page. Please try again later.',
              };
            }

            try {
              final data = jsonDecode(response.body);
              return {
                'success': false,
                'message': data['message'] ?? 'Failed to update profile',
                'errors': data['errors'],
              };
            } catch (e) {
              return {
                'success': false,
                'message': 'Server error. Please try again later.',
              };
            }
          } else {
            return {
              'success': false,
              'message': 'Server returned error ${response.statusCode}',
            };
          }
        } catch (e) {
          return {
            'success': false,
            'message': 'Server returned error ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('Error in multipart request: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Update profile without image (JSON request)
  Future<Map<String, dynamic>> _updateProfileWithoutImage(
      Map<String, dynamic> userData, String token) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/user/profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(userData),
          )
          .timeout(const Duration(seconds: 15));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);

            // Update user data in shared preferences
            if (data['user'] != null) {
              await _updateStoredUserData(data['user']);
            }

            return {
              'success': true,
              'message': data['message'] ?? 'Profile updated successfully',
              'user': data['user'] != null ? User.fromJson(data['user']) : null,
            };
          } catch (e) {
            print('Error parsing JSON response: $e');
            return {
              'success': false,
              'message': 'Error parsing server response',
            };
          }
        } else {
          return {
            'success': false,
            'message': 'Server returned an empty response',
          };
        }
      } else {
        try {
          if (response.body.isNotEmpty) {
            if (response.body.contains('<html') ||
                response.body.contains('<!DOCTYPE') ||
                response.body.contains('<br') ||
                response.body.contains('<b>')) {
              return {
                'success': false,
                'message':
                    'Server returned an error page. Please try again later.',
              };
            }

            final data = jsonDecode(response.body);
            return {
              'success': false,
              'message': data['message'] ?? 'Failed to update profile',
              'errors': data['errors'],
            };
          } else {
            return {
              'success': false,
              'message': 'Server returned error ${response.statusCode}',
            };
          }
        } catch (e) {
          return {
            'success': false,
            'message': 'Server returned error ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('Error in JSON request: $e');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Update stored user data in shared preferences
  Future<void> _updateStoredUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(userData));
      print('Updated user data in shared preferences');
    } catch (e) {
      print('Failed to update user data in shared preferences: $e');
    }
  }
}