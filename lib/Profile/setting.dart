import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Security'),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Privacy'),
          ),
          SizedBox(height: 10),
          Text('Support & About',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Help & Support'),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Terms and Policies'),
          ),
          SizedBox(height: 10),
          Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            leading: Icon(Icons.flag_outlined),
            title: Text('Report a problem'),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
          ),
        ],
      ),
    );
  }
}
