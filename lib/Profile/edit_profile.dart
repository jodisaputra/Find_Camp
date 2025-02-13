import 'dart:io';
import 'package:find_camp/Style/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:find_camp/services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  final ApiService _apiService = ApiService();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  int? _selectedCountryId;
  bool _isLoading = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    checkAuthState(); // Add this line
    _loadUserData();
  }

  void checkAuthState() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User is logged in');
      print('UID: ${user.uid}');
      print('Email: ${user.email}');
      user.getIdToken().then((token) {
        print('Token: $token');
      });
    } else {
      print('No user is logged in');
    }
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      final userData = await _apiService.getUserData();

      setState(() {
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';

        // Format date properly if it exists
        if (userData['date_of_birth'] != null &&
            userData['date_of_birth'].isNotEmpty) {
          try {
            final date = DateTime.parse(userData['date_of_birth']);
            _dobController.text =
                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
          } catch (e) {
            _dobController.text = userData['date_of_birth'];
          }
        }

        // Handle country data
        _selectedCountryId = userData['country_id'];
        _loadCountryName(); // Load country name based on ID

        _profileImageUrl = userData['profile_image_url'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCountryName() async {
    if (_selectedCountryId != null) {
      try {
        final countries = await _apiService.getCountries();
        final country = countries.firstWhere(
          (c) => c['id'] == _selectedCountryId,
          orElse: () => {'name': ''},
        );
        if (mounted) {
          setState(() {
            _countryController.text = country['name'] ?? '';
          });
        }
      } catch (e) {
        print('Error loading country name: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        // Upload image immediately after picking
        await _uploadImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      setState(() => _isLoading = true);

      final newImageUrl = await _apiService.updateProfileImage(_imageFile!);

      setState(() {
        _profileImageUrl = newImageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectCountry() async {
    try {
      final countries = await _apiService.getCountries();

      // ignore: use_build_context_synchronously
      final country = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select Country'),
            children: countries
                .map((country) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, country),
                      child: Text(country['name']),
                    ))
                .toList(),
          );
        },
      );

      if (country != null) {
        setState(() {
          _countryController.text = country['name'];
          _selectedCountryId = country['id'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load countries: $e')),
      );
    }
  }

  Future<void> _saveChanges() async {
    try {
      setState(() => _isLoading = true);

      await _apiService.updateProfile(
        name: _nameController.text,
        dateOfBirth: _dobController.text,
        countryId: _selectedCountryId,
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    super.dispose();
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!) as ImageProvider
                                : _profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                        as ImageProvider
                                    : const AssetImage(
                                        'assets/profile_image.png'),
                          ),
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
                      enabled: false, // Email cannot be updated
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _countryController,
                      readOnly: true,
                      onTap: _selectCountry,
                      decoration: const InputDecoration(
                        labelText: 'Country/Region',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purplecolor,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
