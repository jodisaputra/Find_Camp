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
import 'dart:math';
import 'package:find_camp/isian/task.dart';
import 'package:find_camp/Consult/consult_page.dart';
import 'package:find_camp/Profile/profile_page.dart';

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
  int _currentIndex = 0;

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
        print('Found user data in SharedPreferences: ${userData.substring(0, min(50, userData.length))}...');
        final userMap = jsonDecode(userData);
        print('Decoded user data: ${jsonEncode(userMap)}');
        
        final user = User.fromJson(userMap);
        print('Parsed user object:');
        print('- Name: ${user.name}');
        print('- Email: ${user.email}');
        print('- Profile Image Path: ${user.profileImagePath}');
        print('- Profile Image URL: ${user.profileImageUrl}');
        
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
    } catch (e, stackTrace) {
      print('Error loading user profile directly: $e');
      print('Stack trace: $stackTrace');
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
    if (_currentUser == null) {
      print('_currentUser is null');
      return '';
    }
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final imagePath = _currentUser!.profileImagePath;
    
    print('Profile Image Path from user: $imagePath');
    
    if (imagePath == null || imagePath.isEmpty) {
      print('Image path is empty');
      return '';
    }

    // Remove leading /storage/ if present
    final cleanPath = imagePath.startsWith('/storage/') 
        ? imagePath.substring(9) 
        : imagePath;
    
    // Construct full URL
    final imageUrl = '${ApiConfig.baseUrl}/storage/$cleanPath';
    print('Constructed image URL: $imageUrl');
    
    // Add cache busting parameter
    final finalUrl = '$imageUrl?t=$timestamp';
    print('Final image URL with cache busting: $finalUrl');
    return finalUrl;
  }

  Widget _buildProfileImage() {
    print('Building profile image widget');
    print('Current user: ${_currentUser?.name}');
    
    final imageUrl = _getProfileImageUrl();
    print('Image URL for widget: $imageUrl');
    
    if (imageUrl.isEmpty) {
      print('Using default profile image (empty URL)');
      return const CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 30, color: Colors.white),
      );
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          headers: const {'cache-control': 'no-cache'},
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            print('Loading progress: ${loadingProgress.expectedTotalBytes != null ? '${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}' : 'indeterminate'}');
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading profile image: $error');
            print('Stack trace: $stackTrace');
            return const Icon(Icons.person, size: 30, color: Colors.grey);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Home page content
    final homePage = RefreshIndicator(
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
    );

    final pages = [
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : homePage,
      TaskScreen(),
      ConsultPage(),
      ProfilePage(
        username: _currentUser?.name ?? widget.username,
        email: _currentUser?.email ?? '',
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildGreeting() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B2FF2), Color(0xFFF357A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
      child: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hello Fams!',
                    style: TextStyle(fontSize: 14, color: Colors.white70)),
                Text(
                  _currentUser?.name ?? widget.username,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _selectedRegion == region.name ? Colors.deepPurple.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            if (_selectedRegion == region.name)
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[100],
              child: ClipOval(
                child: Image.network(
                  region.imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image, size: 30);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(region.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
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
              flagAsset: country.flagUrl ?? '',
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  country.flagUrl ?? '',
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
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text(
                    country.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    country.regionName ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < (country.rating?.floor() ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        (country.rating ?? 0).toStringAsFixed(1),
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
    );
  }
}