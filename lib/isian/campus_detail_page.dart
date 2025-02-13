import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CampusDetailPage extends StatelessWidget {
  final String name;
  final String logo;
  final String banner;
  final double rating;
  final String description;
  final String phone;
  final String email;
  final String website;

  const CampusDetailPage({super.key, 
    required this.name,
    required this.logo,
    required this.banner,
    required this.rating,
    required this.description,
    required this.phone,
    required this.email,
    required this.website,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
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
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: Image.asset(
                    banner,
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 280,
                  right: 20,
                  child: CircleAvatar(
                    backgroundImage: AssetImage(logo),
                    radius: 30,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // University Name
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        '$rating/5.0',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Description Section
                  Text(
                    'University Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  // Contact Information
                  ListTile(
                    leading: Icon(Icons.school, color: Colors.green),
                    title: Text('Major'),
                  ),
                  ListTile(
                    leading: Icon(Icons.language, color: Colors.blue),
                    title: Text('Website'),
                    onTap: () => _launchURL(website),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.orange),
                    title: Text(phone),
                  ),
                  ListTile(
                    leading: Icon(Icons.email, color: Colors.red),
                    title: Text(email),
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
