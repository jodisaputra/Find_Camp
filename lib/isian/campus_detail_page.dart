import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:find_camp/services/campus_service.dart';

class CampusDetailPage extends StatefulWidget {
  final String id;

  const CampusDetailPage({super.key, required this.id});

  @override
  State<CampusDetailPage> createState() => _CampusDetailPageState();
}

class _CampusDetailPageState extends State<CampusDetailPage> {
  Map<String, dynamic>? campus;
  bool isLoading = true;
  String? error;
  final CampusService _campusService = CampusService();

  @override
  void initState() {
    super.initState();
    fetchCampusDetail();
  }

  Future<void> fetchCampusDetail() async {
    try {
      final data = await _campusService.getCampusDetail(widget.id);
      setState(() {
        campus = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (campus == null) {
      return const Scaffold(
        body: Center(child: Text('Campus not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: Image.network(
                    campus!['banner_url'] ?? '',
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading banner: $error');
                      return Container(
                        width: double.infinity,
                        height: 350,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 50),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 280,
                  right: 20,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(campus!['logo_url'] ?? ''),
                    radius: 30,
                    onBackgroundImageError: (exception, stackTrace) {
                      print('Error loading logo: $exception');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // University Name
                  Text(
                    campus!['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${campus!['rating']}/5.0',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description Section
                  const Text(
                    'University Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    campus!['description'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // Contact Information
                  const ListTile(
                    leading: Icon(Icons.school, color: Colors.green),
                    title: Text('Major'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.language, color: Colors.blue),
                    title: const Text('Website'),
                    onTap: () => _launchURL(campus!['website']),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.orange),
                    title: Text(campus!['phone']),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.red),
                    title: Text(campus!['email']),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch URL
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
