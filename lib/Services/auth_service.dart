import 'dart:convert';
import 'dart:io' as IO;
import 'package:find_camp/Config/config.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = '${Config.BASE_URL}/api/auth';

  bool _validateUrl() {
    try {
      final uri = Uri.parse(baseUrl);
      return uri.isScheme('HTTPS');
    } catch (e) {
      print('Invalid URL: $e');
      return false;
    }
  }

  // Add this method for immediate response
  String getInitialUserName() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'Guest';
  }

  Future<Map<String, dynamic>> getUserDataFromServer() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'firebase_uid': currentUser.uid,
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        await _storeUserData(userData['user']);
        return userData['user'];
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to get user data');
      }
    } catch (e) {
      print('Error getting user data from server: $e');
      // Try to get cached data
      final cachedData = await getCachedUserData();
      if (cachedData != null) {
        return cachedData;
      }
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'idToken': idToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['user'] != null) {
          await _storeUserData(responseData['user']);
        }
        return responseData;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to login');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<Map<String, dynamic>> loginWithEmailPassword(String email,
      String password) async {
    try {
      print('Attempting to login with email: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Laravel Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['firebase_token'] != null) {
          try {
            await FirebaseAuth.instance
                .signInWithCustomToken(responseData['firebase_token']);
            print('Firebase Authentication successful');

            if (responseData['user'] != null) {
              await _storeUserData(responseData['user']);
            }

            final userData = await getUserDataFromServer();
            responseData['user_details'] = userData;
          } catch (firebaseError) {
            print('Firebase Error: $firebaseError');
            throw Exception('Firebase authentication failed: $firebaseError');
          }
        }

        return responseData;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to login');
      }
    } catch (e) {
      print('Login Error: $e');
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData));
      print('User data stored successfully');
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  Future<Map<String, dynamic>?> getCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
    } catch (e) {
      print('Error getting cached user data: $e');
    }
    return null;
  }

  // Fixed: Changed to return Future<String>
  Future<String> getCurrentUserName() async {
    try {
      final userData = await getUserDataFromServer();
      return userData['name'] ?? 'Guest';
    } catch (e) {
      final user = FirebaseAuth.instance.currentUser;
      return user?.displayName ?? 'Guest';
    }
  }

  Future<String?> getCurrentUserEmail() async {
    try {
      final userData = await getUserDataFromServer();
      return userData['email'];
    } catch (e) {
      final user = FirebaseAuth.instance.currentUser;
      return user?.email;
    }
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error during sign out: $e');
      throw Exception('Failed to sign out: $e');
    }
  }
}