import 'dart:io';
import 'package:find_camp/Style/theme.dart';
import 'package:find_camp/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/painting.dart'; // Add this import for imageCache
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  File? _profileImage;
  String? _currentProfileImagePath;
  DateTime? _selectedDate;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _imageError = false;

  // Timestamp for cache busting
  int _imageTimestamp = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.getCurrentUser();

      if (user != null) {
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _currentProfileImagePath = user.profileImagePath;

          // Set timestamp for cache busting
          _imageTimestamp = DateTime.now().millisecondsSinceEpoch;

          // Set date if available
          if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
            try {
              _selectedDate = DateTime.parse(user.dateOfBirth!);
              _dateController.text =
                  DateFormat('yyyy-MM-dd').format(_selectedDate!);
            } catch (e) {
              print('Error parsing date: $e');
            }
          }

          // Set country if available
          if (user.country != null && user.country!.isNotEmpty) {
            _countryController.text = user.country!;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
          _imageError = false; // Reset error state
        });
        print('Selected image: ${image.path}');
        print('Image file exists: ${await File(image.path).exists()}');
        print('Image file size: ${await File(image.path).length()} bytes');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    // Validate inputs
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _passwordConfirmationController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Prepare user data
      final userData = {
        'name': _nameController.text,
        'date_of_birth': _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : null,
        'country':
            _countryController.text.isNotEmpty ? _countryController.text : null,
      };

      // Only include password if it's changed
      if (_passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text;
        userData['password_confirmation'] =
            _passwordConfirmationController.text;
      }

      // Update profile with a single request (user data + image if available)
      final result = await _profileService.updateProfile(userData, _profileImage);

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        // Update image path if a new one is available in the response
        if (result['user'] != null &&
            result['user'].profileImagePath != null) {
          setState(() {
            _currentProfileImagePath = result['user'].profileImagePath;
            // Reset selected image since it's been uploaded
            _profileImage = null;
            // Update timestamp for cache busting
            _imageTimestamp = DateTime.now().millisecondsSinceEpoch;
          });
        }

        // Clear image cache
        imageCache.clear();
        imageCache.clearLiveImages();

        // Force a reload of user data in the parent screen when returning
        Navigator.pop(context, true);
      } else {
        // Handle error
        String errorMessage = result['message'] ?? 'Failed to update profile';

        // Handle validation errors
        if (result['errors'] != null) {
          final errors = result['errors'] as Map<String, dynamic>;
          final errorMessages =
              errors.values.map((e) => (e as List).join(', ')).join('\n');

          errorMessage = errorMessages;
          
          // Check for image-specific errors
          if (errors.containsKey('profile_image')) {
            setState(() {
              _imageError = true;
            });
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Get image URL with cache busting
  String _getProfileImageUrl() {
    if (_currentProfileImagePath == null || _currentProfileImagePath!.isEmpty) {
      return '';
    }

    // Check if the URL already has a domain
    if (!_currentProfileImagePath!.startsWith('http')) {
      // Add your API base URL if it's a relative path
      return '${ApiConfig.baseUrl}$_currentProfileImagePath?t=$_imageTimestamp';
    }

    // If it already has a domain, just add the timestamp
    return '$_currentProfileImagePath?t=$_imageTimestamp';
  }

  Widget _buildProfileImage() {
    print('Building profile image with path: ${_getProfileImageUrl()}');

    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: _imageError ? Colors.red[100] : Colors.grey[300],
          child: _profileImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.file(
                    _profileImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error displaying selected image: $error');
                      return const Icon(Icons.error, size: 50, color: Colors.red);
                    },
                  ))
              : (_currentProfileImagePath != null &&
                      _currentProfileImagePath!.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        _getProfileImageUrl(),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        cacheWidth: null, // Disable width caching
                        cacheHeight: null, // Disable height caching
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return const Icon(Icons.person,
                              size: 50, color: Colors.grey);
                        },
                      ))
                  : const Icon(Icons.person, size: 50, color: Colors.grey),
        ),
        if (_imageError)
          Positioned(
            bottom: 0,
            right: 15,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning, color: Colors.white, size: 20),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Edit Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        _buildProfileImage(),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: const CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.purple,
                              child: Icon(Icons.edit,
                                  color: Colors.white, size: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_imageError) 
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select a valid image file (JPEG, PNG, under 2MB)',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      enabled: false,
                      fillColor: Color(0xFFEEEEEE),
                      filled: true,
                    ),
                    enabled: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      hintText: 'Leave blank to keep current password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordConfirmationController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      hintText: 'Confirm your new password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country/Region',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    readOnly: true,
                    onTap: () {
                      _showCountryPicker(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purplecolor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Change',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showCountryPicker(BuildContext context) async {
    // Simple list of countries - you can replace with API call
    final countries = [
      'Indonesia',
      'Malaysia',
      'Singapore',
      'United States',
      'United Kingdom',
      'Australia',
      'Canada',
      'Japan',
      'South Korea',
      'China',
      'India',
    ];

    final selectedCountry = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Country'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: countries.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(countries[index]),
                  onTap: () {
                    Navigator.pop(context, countries[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedCountry != null) {
      setState(() {
        _countryController.text = selectedCountry;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _dateController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}