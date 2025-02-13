import 'package:flutter/material.dart';
import 'package:find_camp/isian/campus_detail_page.dart';
import 'package:find_camp/Widget/navbar.dart';

class CampusListPage extends StatelessWidget {
  final String countryName;

  CampusListPage({super.key, required this.countryName});

  final List<Map<String, dynamic>> campuses = [
    {
      'name': 'University of Malaya',
      'logo': 'assets/Image/um_logo.png',
      'banner': 'assets/Image/um_banner.png',
      'rating': 4.5,
      'description':
          'Universiti Malaya\'s academic programmes are globally acclaimed and highly-ranked worldwide in its individual category while encompassing a broad spectrum of knowledge.',
      'phone': '+60 xxxxxxxx',
      'email': 'info@um.com',
      'website': 'https://www.um.edu.my/',
    },
    {
      'name': 'University of Putra Malaysia',
      'logo': 'assets/Image/upm_logo.png',
      'banner': 'assets/Image/upm_banner.png',
      'rating': 4.3,
      'description':
          'UPM is one of Malaysia\'s premier universities, renowned for its academic excellence and research advancements.',
      'phone': '+60 xxxxxxxx',
      'email': 'info@upm.com',
      'website': 'https://www.upm.edu.my/',
    },
    {
      'name': 'Taylor\'s University',
      'logo': 'assets/Image/taylors_logo.png',
      'banner': 'assets/Image/taylors_banner.png',
      'rating': 4.7,
      'description':
          'Taylor\'s University is recognized for its top-tier academic standards and state-of-the-art facilities.',
      'phone': '+60 xxxxxxxx',
      'email': 'info@taylors.edu.my',
      'website': 'https://university.taylors.edu.my/',
    },
    {
      'name': 'Universiti Sains Malaysia',
      'logo': 'assets/Image/usm_logo.png',
      'banner': 'assets/Image/usm_banner.png',
      'rating': 4.6,
      'description':
          'USM is one of the leading universities in Malaysia, with a strong focus on innovation and community engagement.',
      'phone': '+60 xxxxxxxx',
      'email': 'info@usm.my',
      'website': 'https://www.usm.my/',
    },
    {
      'name': 'UCSI University',
      'logo': 'assets/Image/ucsi_logo.png',
      'banner': 'assets/Image/ucsi_banner.png',
      'rating': 4.4,
      'description':
          'UCSI University is well-known for its multidisciplinary curriculum and a strong emphasis on industry-driven education.',
      'phone': '+60 xxxxxxxx',
      'email': 'info@ucsi.edu.my',
      'website': 'https://www.ucsiuniversity.edu.my/',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus - $countryName',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        itemCount: campuses.length,
        padding: EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          final campus = campuses[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  campus['logo'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                campus['name'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${campus['rating'].toString()}/5.0',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CampusDetailPage(
                      name: campus['name'],
                      logo: campus['logo'],
                      banner: campus['banner'],
                      rating: campus['rating'],
                      description: campus['description'],
                      phone: campus['phone'],
                      email: campus['email'],
                      website: campus['website'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/mainmenu');
              break;
            case 1:
              Navigator.pushNamed(context, '/consult');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
