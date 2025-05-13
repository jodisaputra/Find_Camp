import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  
  factory SessionService() {
    return _instance;
  }

  SessionService._internal();

  // Initialize session when app starts
  Future<void> initializeSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');
      final token = prefs.getString('token');
      final expiresAt = prefs.getString('expires_at');

      if (userData != null && token != null && expiresAt != null) {
        // Check if token is expired
        final expiryDate = DateTime.parse(expiresAt);
        if (DateTime.now().isBefore(expiryDate)) {
          // Token is still valid, restore session
          print('Session restored successfully');
          return;
        } else {
          // Token expired, clear session
          print('Session expired, clearing data');
          await logout();
        }
      } else {
        // No session data found
        print('No session data found');
        await logout();
      }
    } catch (e) {
      print('Error initializing session: $e');
      await logout();
    }
  }

  // Save session data
  Future<void> saveSession(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      await prefs.setString('token_type', data['token_type']);
      await prefs.setString('expires_at', data['expires_at']);
      await prefs.setString('user', jsonEncode(data['user']));
      print('Session data saved successfully');
    } catch (e) {
      print('Error saving session data: $e');
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');
      
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final expiresAt = prefs.getString('expires_at');
      
      if (token != null && expiresAt != null) {
        final expiryDate = DateTime.parse(expiresAt);
        return DateTime.now().isBefore(expiryDate);
      }
      return false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Session cleared successfully');
    } catch (e) {
      print('Error during logout: $e');
    }
  }
} 