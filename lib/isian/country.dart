import 'package:find_camp/models/country_model.dart';
import 'package:flutter/material.dart';
import 'package:find_camp/services/api_service.dart';
import 'package:find_camp/isian/syarat.dart';
import 'package:find_camp/isian/campus_list_page.dart';

class CountryScreen extends StatefulWidget {
  final int countryId;
  final String name;
  final String flagAsset;

  const CountryScreen({
    super.key,
    required this.countryId,
    required this.name,
    required this.flagAsset,
  });

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  Country? _country;

  @override
  void initState() {
    super.initState();
    _loadCountryDetails();
  }

  Future<void> _loadCountryDetails() async {
    try {
      final countryData = await _apiService.getCountryDetail(widget.countryId);
      print('Country Screen received data: $countryData');
      
      // Handle the data based on its structure
      dynamic countryJson;
      if (countryData is Map) {
        if (countryData['data'] != null) {
          // If the response has a 'data' wrapper
          countryJson = countryData['data'];
          print('Found country in data wrapper: $countryJson');
        } else if (countryData['country'] != null) {
          // If the response has a 'country' wrapper
          countryJson = countryData['country'];
          print('Found country in country wrapper: $countryJson');
        } else {
          // If the response is the country data directly
          countryJson = countryData;
          print('Using raw data as country: $countryJson');
        }
      } else {
        print('Unexpected data type: ${countryData.runtimeType}');
        throw Exception('Unexpected data format from API');
      }
      
      print('Final countryJson before parsing: $countryJson');
      setState(() {
        _country = Country.fromJson(countryJson);
        print('Parsed country object: $_country');
        print('Description after parsing: ${_country?.description}');
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading country details: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Failed to load country details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      expandedHeight: 240,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                              child: Image.network(
                                widget.flagAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image,
                                        size: 50, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(32),
                                  bottomRight: Radius.circular(32),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.25),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 24,
                              bottom: 24,
                              right: 24,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.name,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _country?.regionName ?? '',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        ...List.generate(5, (index) {
                                          return Icon(
                                            index < (_country?.rating?.floor() ?? 0)
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 20,
                                          );
                                        }),
                                        const SizedBox(width: 4),
                                        Text(
                                          (_country?.rating ?? 0).toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _country?.description ?? 'No description available.',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            const Text(
                              'Plan Your Trip',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SyaratScreen(
                                        countryId: widget.countryId,
                                        countryName: widget.name,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  backgroundColor: const Color(0xFF7B2FF2),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'Apply',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CampusListPage(countryId: widget.countryId.toString(), countryName: widget.name),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.location_pin,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                label: const Text(
                                  'View Campus',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  backgroundColor: const Color(0xFFF357A8),
                                  elevation: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}