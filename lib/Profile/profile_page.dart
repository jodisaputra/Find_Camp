import 'package:find_camp/Widget/navbar.dart';
import 'package:find_camp/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:find_camp/Login/login.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/user_model.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final String email;

  const ProfilePage({super.key, required this.username, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Timestamp for cache busting
  int _imageTimestamp = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.getCurrentUser();
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
          _imageTimestamp = DateTime.now().millisecondsSinceEpoch;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading profile: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Get image URL with cache busting
  String _getProfileImageUrl() {
    if (_currentUser?.profileImagePath == null || _currentUser!.profileImagePath!.isEmpty) {
      return '';
    }

    // Check if the URL already has a domain
    if (!_currentUser!.profileImagePath!.startsWith('http')) {
      // Add your API base URL if it's a relative path
      return '${ApiConfig.baseUrl}${_currentUser!.profileImagePath}?t=$_imageTimestamp';
    }

    // If it already has a domain, just add the timestamp
    return '${_currentUser!.profileImagePath}?t=$_imageTimestamp';
  }

  Widget _buildProfileImage() {
    if (_currentUser?.profileImagePath != null && _currentUser!.profileImagePath!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.network(
            _getProfileImageUrl(),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading profile image: $error');
              return const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/Image/profile_image.png'),
              );
            },
          ),
        ),
      );
    } else {
      return const CircleAvatar(
        radius: 40,
        backgroundImage: AssetImage('assets/Image/profile_image.png'),
      );
    }
  }

  Future<void> _logout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Log out the user
      await _authService.logout();

      // Close the loading indicator and navigate to login
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      // Close the loading indicator
      Navigator.pop(context);
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display initial data from route parameters while loading
    final displayName = _currentUser?.name ?? widget.username;
    final displayEmail = _currentUser?.email ?? widget.email;
    
    if (_isLoading) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: 3,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/mainmenu');
                break;
              case 1:
                Navigator.pushNamed(context, '/task');
                break;
              case 2:
                Navigator.pushNamed(context, '/consult');
                break;
              case 3:
                // Do nothing, already on profile
                break;
            }
          },
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadUserProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: 3,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/mainmenu');
                break;
              case 1:
                Navigator.pushNamed(context, '/task');
                break;
              case 2:
                Navigator.pushNamed(context, '/consult');
                break;
              case 3:
                // Do nothing, already on profile
                break;
            }
          },
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                _buildProfileImage(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUser?.name ?? widget.username,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(_currentUser?.email ?? widget.email),
                      if (_currentUser?.country != null && _currentUser!.country!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(_currentUser!.country!, style: TextStyle(color: Colors.grey[600])),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.purple),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                // Navigate to edit profile and refresh when returning
                final result = await Navigator.pushNamed(context, '/editProfile');
                if (result == true) {
                  _loadUserProfile();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.blue),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to privacy policy page
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.green),
              title: const Text('Contact Us'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to contact page
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  'App Version 1.0',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/mainmenu');
              break;
            case 1:
              Navigator.pushNamed(context, '/task');
              break;
            case 2:
              Navigator.pushNamed(context, '/consult');
              break;
            case 3:
              // Do nothing, already on profile
              break;
          }
        },
      ),
    );
  }
}