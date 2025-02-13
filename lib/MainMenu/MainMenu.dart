import 'package:find_camp/Services/api_service.dart';
import 'package:find_camp/Services/auth_service.dart';
import 'package:find_camp/models/country.dart';
import 'package:find_camp/models/region.dart';
import 'package:flutter/material.dart';
import 'package:find_camp/Widget/navbar.dart';
import 'package:find_camp/isian/country.dart';

class MainMenu extends StatefulWidget {
  final String username;

  const MainMenu({super.key, required this.username});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final _authService = AuthService();
  final _apiService = ApiService();
  late String username;
  bool _isLoadingUser = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _selectedRegion = '';

  List<Region> _regions = [];
  List<Country> _countries = [];
  List<Country> _filteredCountries = [];
  bool _isLoading = true;

  // final List<Map<String, String>> regions = [
  //   {'name': 'Southeast Asia', 'asset': 'assets/Image/southeast_asia.png'},
  //   {'name': 'West Asia', 'asset': 'assets/Image/west_asia.png'},
  //   {'name': 'East Asia', 'asset': 'assets/Image/east_asia.png'},
  //   {'name': 'South Asia', 'asset': 'assets/Image/south_asia.png'},
  //   {'name': 'Middle Asia', 'asset': 'assets/Image/middle_asia.png'},
  // ];
  //
  // final List<Map<String, dynamic>> countries = [
  //   {'name': 'South Korea', 'region': 'East Asia', 'flag': 'assets/Image/south_korea2.jpg', 'rating': 4.8},
  //   {'name': 'Myanmar', 'region': 'Southeast Asia', 'flag': 'assets/Image/myanmar.png', 'rating': 4.7},
  //   {'name': 'Singapore', 'region': 'Southeast Asia', 'flag': 'assets/Image/singapore2.jpg', 'rating': 4.9},
  //   {'name': 'Malaysia', 'region': 'Southeast Asia', 'flag': 'assets/Image/malaysia2.jpeg', 'rating': 4.6},
  //   {'name': 'Philippines', 'region': 'Southeast Asia', 'flag': 'assets/Image/philippines.png', 'rating': 4.5},
  //   {'name': 'Indonesia', 'region': 'Southeast Asia', 'flag': 'assets/Image/indonesia.jpg', 'rating': 4.4},
  // ];

  @override
  void initState() {
    super.initState();
    username = widget.username.isNotEmpty
        ? widget.username
        : _authService.getInitialUserName();
    _loadInitialData();

    _loadData();
    _loadUserData();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
        _filterCountries();
      });
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final name = await _authService.getCurrentUserName();
      if (mounted) {
        setState(() {
          username = name;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    }
    _loadData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserDataFromServer();
      setState(() {
        username = userData['name'] ?? 'Guest';
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        username = widget.username.isNotEmpty
            ? widget.username
            : _authService.getInitialUserName();
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final regionsData = await _apiService.getRegions();
      final countriesData = await _apiService.getCountries();

      setState(() {
        _regions = regionsData.map((data) => Region.fromJson(data)).toList();
        _countries =
            countriesData.map((data) => Country.fromJson(data)).toList();
        _filteredCountries = _countries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error - show snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  void _filterCountries() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> filteredData;
      if (_searchText.isNotEmpty) {
        filteredData = await _apiService.searchCountries(_searchText);
      } else if (_selectedRegion.isNotEmpty) {
        filteredData = await _apiService.getCountriesByRegion(_selectedRegion);
      } else {
        filteredData = await _apiService.getCountries();
      }

      setState(() {
        _filteredCountries =
            filteredData.map((data) => Country.fromJson(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error filtering countries: $e')),
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
      body: Padding(
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
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
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
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildGreeting() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/Image/profile_image.png'),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hello Fams!',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            _isLoadingUser
                ? const SizedBox(
                    width: 80,
                    child: LinearProgressIndicator(),
                  )
                : Text(
                    username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
        children: _regions
            .map((region) => _buildRegionItem(region.name, region.imageUrl))
            .toList(),
      ),
    );
  }

  void _selectRegion(String region) async {
    setState(() {
      _selectedRegion = region == _selectedRegion ? '' : region;
      _searchController.clear();
    });

    // Call API to filter countries by region
    setState(() => _isLoading = true);
    try {
      if (_selectedRegion.isEmpty) {
        // If no region selected, get all countries
        final countriesData = await _apiService.getCountries();
        setState(() {
          _filteredCountries =
              countriesData.map((data) => Country.fromJson(data)).toList();
        });
      } else {
        // Get countries filtered by selected region
        final filteredData =
            await _apiService.getCountriesByRegion(_selectedRegion);
        setState(() {
          _filteredCountries =
              filteredData.map((data) => Country.fromJson(data)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error filtering by region: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildRegionItem(String regionName, String? imageUrl) {
    return GestureDetector(
      onTap: () => _selectRegion(regionName),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: _selectedRegion == regionName
                  ? Colors.blueAccent
                  : Colors.grey[200],
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? Icon(Icons.image)
                  : null, // Show icon if no image
            ),
            const SizedBox(height: 8),
            Text(regionName, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemCount: _filteredCountries.length,
        itemBuilder: (context, index) {
          final country = _filteredCountries[index];
          return _buildCountryCard(
            name: country.name,
            region: country.region,
            flagUrl: country.flagUrl,
            rating: country.rating,
          );
        },
      ),
    );
  }

  Widget _buildCountryCard({
    required String name,
    required String region,
    String? flagUrl,
    required double rating,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CountryScreen(
              name: name,
              flagAsset: flagUrl ?? '',
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
                child: flagUrl != null
                    ? Image.network(
                        flagUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.error_outline,
                              size: 40,
                              color: Colors.red,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      region,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
