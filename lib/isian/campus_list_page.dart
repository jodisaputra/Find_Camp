import 'package:flutter/material.dart';
import 'package:find_camp/isian/campus_detail_page.dart';
import 'package:find_camp/Widget/navbar.dart';
import 'package:find_camp/services/campus_service.dart';

class CampusListPage extends StatefulWidget {
  final String countryId;
  final String countryName;

  const CampusListPage({super.key, required this.countryId, required this.countryName});

  @override
  State<CampusListPage> createState() => _CampusListPageState();
}

class _CampusListPageState extends State<CampusListPage> {
  List<Map<String, dynamic>> campuses = [];
  bool isLoading = true;
  String? error;
  final CampusService _campusService = CampusService();

  @override
  void initState() {
    super.initState();
    fetchCampuses();
  }

  Future<void> fetchCampuses() async {
    try {
      final data = await _campusService.getCampusesByCountryId(widget.countryId);
      print('Fetched campuses: $data');
      setState(() {
        campuses = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching campuses: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus - ${widget.countryName}',
            style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : campuses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No campuses found for this country',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: fetchCampuses,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: campuses.length,
                      padding: const EdgeInsets.all(16.0),
                      itemBuilder: (context, index) {
                        final campus = campuses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                campus['logo_url'] ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  return const Icon(Icons.error);
                                },
                              ),
                            ),
                            title: Text(
                              campus['name'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${campus['rating'].toString()}/5.0',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CampusDetailPage(
                                    id: campus['id'].toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
