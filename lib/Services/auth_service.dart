import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'package:logging/logging.dart';
import 'session_service.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'openid',
    ],
  );

  final Logger _logger = Logger('AuthService');
  late final SessionService _sessionService;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _sessionService = SessionService();
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
      if (record.error != null) {
        print('Error details: ${record.error}');
        print('Stack trace: ${record.stackTrace}');
      }
    });
  }

  // User registration
  Future<Map<String, dynamic>> register(
      String name, 
      String email, 
      String password, 
      String passwordConfirmation) async {
    try {
      _logger.info('Starting user registration for: $email');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        _logger.severe('Registration request timed out after 30 seconds');
        throw Exception('Connection timeout');
      });

      _logger.info('Registration response status code: ${response.statusCode}');
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Save session data
        await _sessionService.saveSession(data);
        _logger.info('User registered successfully: $email');
        return {
          'success': true,
          'user': User.fromJson(data['user']),
          'message': data['message'] ?? 'Registration successful',
        };
      } else {
        _logger.warning('Registration failed: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to register',
          'errors': data['errors'],
        };
      }
    } catch (e, stackTrace) {
      _logger.severe('Error during registration', e, stackTrace);
      return {
        'success': false,
        'message': 'An error occurred during registration: $e',
      };
    }
  }

  // Regular email/password login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save session data
        await _sessionService.saveSession(data);
        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to login',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Add this method to your AuthService class
  Future<void> testApiConnection() async {
    try {
      final response =
          await http.get(Uri.parse('${ApiConfig.baseUrl}/api/test'));
      _logger.info('Test API connection: ${response.statusCode}');
      _logger.info('Test API response: ${response.body}');
    } catch (e) {
      _logger.severe('API connection test failed: $e');
    }
  }

  // Google Sign In
  Future<Map<String, dynamic>> signInWithGoogle(BuildContext context) async {
    try {
      _logger.info('Starting Google Sign-In process');

      const String fullUrl =
          '${ApiConfig.baseUrl}${ApiConfig.googleCallbackEndpoint}';
      _logger.info('Full URL being called: $fullUrl');

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.warning('Google sign in was cancelled by user');
        return {
          'success': false,
          'message': 'Google sign in was cancelled',
        };
      }

      _logger.info('Successfully authenticated with Google: ${googleUser.email}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      _logger.info('ID Token: ${googleAuth.idToken ?? "NULL"}');
      _logger.info('Access Token: ${googleAuth.accessToken ?? "NULL"}');

      // Check if either token is available
      String tokenToSend;
      String tokenField;

      if (googleAuth.idToken != null && googleAuth.idToken!.isNotEmpty) {
        _logger.info('Using ID token for authentication');
        tokenToSend = googleAuth.idToken!;
        tokenField = 'id_token';
      } else if (googleAuth.accessToken != null &&
          googleAuth.accessToken!.isNotEmpty) {
        _logger.info('Using access token as fallback');
        tokenToSend = googleAuth.accessToken!;
        tokenField = 'access_token';
      } else {
        _logger.severe('Failed to obtain any token from Google');
        return {
          'success': false,
          'message': 'Failed to obtain authentication tokens from Google',
        };
      }

      // Prepare the request body
      final requestBody = jsonEncode({
        tokenField: tokenToSend,
      });
      _logger.fine('Request body prepared (token length: ${tokenToSend.length})');

      // Send token to Laravel backend with timeout
      final response = await http
          .post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.googleCallbackEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      )
          .timeout(const Duration(seconds: 30), onTimeout: () {
        _logger.severe('Request timed out after 30 seconds');
        throw Exception('Connection timeout');
      });

      _logger.info(
          'Received response from backend. Status code: ${response.statusCode}');
      _logger.fine(
          'Response body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');

      // Check if response is valid JSON
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        _logger.severe(
            'Received HTML instead of JSON. Server may be returning an error page.');
        return {
          'success': false,
          'message': 'Server returned HTML instead of JSON. Check server logs.',
        };
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        _logger.severe('Failed to parse response as JSON', e);
        return {
          'success': false,
          'message':
              'Invalid response format: ${response.body.substring(0, 100)}...',
        };
      }

      if (response.statusCode == 200) {
        // Save session data
        await _sessionService.saveSession(data);
        _logger.info('Successfully authenticated and saved user data');
        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        _logger.warning(
            'Authentication failed with status code: ${response.statusCode}');
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to authenticate with Google',
        };
      }
    } catch (e, stackTrace) {
      _logger.severe('Error during Google Sign-In', e, stackTrace);
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return _sessionService.getCurrentUser();
  }

  // Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _sessionService.isLoggedIn();
  }

  // Logout
  Future<void> logout() async {
    await _sessionService.logout();
  }
}