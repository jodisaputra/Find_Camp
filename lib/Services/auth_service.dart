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
      'https://www.googleapis.com/auth/userinfo.email',
    ],
    clientId: '1035961176435-84h7h81jl70kpsr7qe41bjh87j6t5tk0.apps.googleusercontent.com',
    serverClientId: '1035961176435-dpd39tp1l9vpvph40p0a54366l8e94j9.apps.googleusercontent.com',
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
      _logger.info('Package name: com.example.find_camp');
      _logger.info('Scopes requested: ${_googleSignIn.scopes}');
      _logger.info('Google Sign In configuration:');
      _logger.info('- Client ID: ${_googleSignIn.clientId}');
      _logger.info('- Server Client ID: ${_googleSignIn.serverClientId}');

      // Trigger the Google Sign-In flow
      _logger.info('Attempting to sign in with Google...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.warning('Google sign in was cancelled by user');
        return {
          'success': false,
          'message': 'Google sign in was cancelled',
        };
      }

      _logger.info('Successfully authenticated with Google:');
      _logger.info('- Email: ${googleUser.email}');
      _logger.info('- User ID: ${googleUser.id}');
      _logger.info('- Display Name: ${googleUser.displayName}');
      _logger.info('- Photo URL: ${googleUser.photoUrl}');
      _logger.info('- Server Auth Code: ${googleUser.serverAuthCode}');

      // Get authentication details
      _logger.info('Getting authentication tokens...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Validate ID token
      if (googleAuth.idToken == null) {
        _logger.severe('ID token is null after Google authentication');
        _logger.severe('Access token: ${googleAuth.accessToken}');
        _logger.severe('Server auth code: ${googleUser.serverAuthCode}');
        return {
          'success': false,
          'message': 'Failed to get ID token from Google. Please check Google Cloud Console and Firebase Console configuration.',
        };
      }

      // Log untuk debugging
      _logger.info('Got authentication tokens:');
      _logger.info('- ID Token length: ${googleAuth.idToken?.length}');
      _logger.info('- Access Token length: ${googleAuth.accessToken?.length}');
      _logger.info('- ID Token: ${googleAuth.idToken}');

      // Prepare the request body with all available tokens
      final requestBody = jsonEncode({
        'id_token': googleAuth.idToken,
        'access_token': googleAuth.accessToken,
        'server_auth_code': googleUser.serverAuthCode,
        'email': googleUser.email,
        'user_id': googleUser.id,
        'display_name': googleUser.displayName,
        'photo_url': googleUser.photoUrl,
      });

      _logger.info('Sending tokens to backend...');
      _logger.info('Backend URL: ${ApiConfig.googleCallbackEndpoint}');
      _logger.info('Request body: $requestBody');

      // Send token to Laravel backend
      final response = await http
          .post(
        Uri.parse(ApiConfig.googleCallbackEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Platform': 'flutter',
          'X-Client-ID': _googleSignIn.serverClientId ?? '',
        },
        body: requestBody,
      )
          .timeout(const Duration(seconds: 30));

      _logger.info('Backend response:');
      _logger.info('- Status code: ${response.statusCode}');
      _logger.info('- Headers: ${response.headers}');
      _logger.info('- Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _sessionService.saveSession(data);
        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        final errorData = jsonDecode(response.body);
        _logger.severe('Backend authentication failed:');
        _logger.severe('- Status code: ${response.statusCode}');
        _logger.severe('- Error: ${errorData['error']}');
        return {
          'success': false,
          'message': 'Failed to authenticate with backend: ${response.body}',
          'error_details': errorData,
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

  // Helper method untuk mendapatkan device ID
  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
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