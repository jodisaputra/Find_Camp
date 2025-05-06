import 'package:find_camp/models/country_model.dart';
import 'package:find_camp/models/region_model.dart';
import 'package:flutter/material.dart';
import 'package:find_camp/Widget/navbar.dart';
import 'package:find_camp/isian/country.dart';
import 'package:find_camp/services/api_service.dart';
import 'package:find_camp/services/auth_service.dart';
import 'package:find_camp/config/api_config.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MainMenu extends StatefulWidget {
  final String username;

  const MainMenu({super.key, required this.username});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  String _searchText = '';
  String _selectedRegion = '';
  int? _selectedRegionId;

  List<Region> _regions = [];
  List<Country> _countries = [];
  List<Country> _filteredCountries = [];

  bool _isLoading = true;
  String? _errorMessage;
  User? _currentUser;
  int _imageTimestamp = DateTime.now().millisecondsSinceEpoch;
  bool _userLoading = true;

  @override
  void initState() {
    super.initState();
    print('MainMenu initState called');
    _loadData();
    _loadUserProfileDirect(); // Use direct loading instead
    
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
        _filterCountries();
      });
    });
  }

  // Direct method to load user data from SharedPreferences
  Future<void> _loadUserProfileDirect() async {
    setState(() {
      _userLoading = true;
    });
    
    try {
      print('Loading user profile directly from SharedPreferences');
      
      // Get user data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');
      
      if (userData != null) {
        print('Found user data in SharedPreferences: ${userData.substring(0, 50)}...');
        final userMap = jsonDecode(userData);
        final user = User.fromJson(userMap);
        
        print('Username: ${user.name}');
        print('Profile image path: ${user.profileImagePath}');
        
        if (mounted) {
          setState(() {
            _currentUser = user;
            _imageTimestamp = DateTime.now().millisecondsSinceEpoch;
            _userLoading = false;
          });
        }
      } else {
        print('No user data found in SharedPreferences');
        if (mounted) {
          setState(() {
            _userLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user profile directly: $e');
      if (mounted) {
        setState(() {
          _userLoading = false;
        });
      }
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load regions
      final regionsData = await _apiService.getRegions();
      final List<Region> regions =
          regionsData.map((data) => Region.fromJson(data)).toList();

      // Load countries
      final countriesData = await _apiService.getCountries();
      final List<Country> countries =
          countriesData.map((data) => Country.fromJson(data)).toList();

      if (mounted) {
        setState(() {
          _regions = regions;
          _countries = countries;
          _filteredCountries = countries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _filterCountries() async {
    if (_searchText.isEmpty && _selectedRegionId == null) {
      setState(() {
        _filteredCountries = _countries;
      });
    } else {
      try {
        // Let the API handle filtering
        final countriesData = await _apiService.getCountries(
          search: _searchText.isEmpty ? null : _searchText,
          regionId: _selectedRegionId,
        );

        if (mounted) {
          setState(() {
            _filteredCountries =
                countriesData.map((data) => Country.fromJson(data)).toList();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error filtering countries: $e')),
          );
        }
      }
    }
  }

  void _selectRegion(String regionName, int regionId) {
    setState(() {
      if (_selectedRegion == regionName) {
        // Deselect current region
        _selectedRegion = '';
        _selectedRegionId = null;
      } else {
        // Select new region
        _selectedRegion = regionName;
        _selectedRegionId = regionId;
      }

      _searchController.clear();
      _filterCountries();
    });
  }

  // Get image URL with cache busting
  String _getProfileImageUrl() {
    if (_currentUser?.profileImagePath == null || _currentUser!.profileImagePath!.isEmpty) {
      return '';
    }

    print('Building profile image URL from: ${_currentUser!.profileImagePath}');
    
    // Check if the URL already has a domain
    if (!_currentUser!.profileImagePath!.startsWith('http')) {
      // Add your API base URL if it's a relative path
      final url = '${ApiConfig.baseUrl}${_currentUser!.profileImagePath}?t=$_imageTimestamp';
      print('Generated image URL: $url');
      return url;
    }

    // If it already has a domain, just add the timestamp
    final url = '${_currentUser!.profileImagePath}?t=$_imageTimestamp';
    print('Generated image URL: $url');
    return url;
  }

  Widget _buildProfileImage() {
    print('Building profile image widget');
    print('Current user: ${_currentUser?.name}');
    print('Profile path: ${_currentUser?.profileImagePath}');
    
    if (_userLoading) {
      return const CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }
    
    if (_currentUser?.profileImagePath != null && _currentUser!.profileImagePath!.isNotEmpty) {
      final imageUrl = _getProfileImageUrl();
      print('Using profile image: $imageUrl');
      
      return CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            // Add cache busting at network image level too
            headers: const {'cache-control': 'no-cache'},
            errorBuilder: (context, error, stackTrace) {
              print('Error loading profile image: $error');
              return const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/Image/profile_image.png'),
              );
            },
          ),
        ),
      );
    } else {
      print('Using default profile image');
      return const CircleAvatar(
        radius: 30,
        backgroundImage: AssetImage('assets/Image/profile_image.png'),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadUserProfileDirect();
                    await _loadData();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        _buildGreeting(),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                        if (_searchText.isEmpty) ...[
                          _buildRegionsRow(),
                          const SizedBox(height: 20),
                        ],
                        _buildCountryGrid(),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on main menu
              break;
            case 1:
              Navigator.pushNamed(context, '/task');
              break;
            case 2:
              Navigator.pushNamed(context, '/consult');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile')
                .then((_) {
                  // Reload user data when returning from profile
                  _loadUserProfileDirect();
                });
              break;
          }
        },
      ),
    );
  }

  Widget _buildGreeting() {
    return Row(
      children: [
        _buildProfileImage(),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hello Fams!',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(
              _currentUser?.name ?? widget.username,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildRegionsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _regions.map((region) => _buildRegionItem(region)).toList(),
      ),
    );
  }

  Widget _buildRegionItem(Region region) {
    return GestureDetector(
      onTap: () => _selectRegion(region.name, region.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: _selectedRegion == region.name
                  ? Colors.blueAccent
                  : Colors.grey[200],
              child: ClipOval(
                child: Image.network(
                  region.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image, size: 30);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(region.name, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryGrid() {
    return Expanded(
      child: _filteredCountries.isEmpty
          ? const Center(child: Text('No countries found'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                return _buildCountryCard(country);
              },
            ),
    );
  }

  Widget _buildCountryCard(Country country) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CountryScreen(
              countryId: country.id,
              name: country.name,
              flagAsset: country.flagUrl,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  country.flagUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 50);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      country.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      country.regionName,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < country.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          country.rating.toStringAsFixed(1),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}