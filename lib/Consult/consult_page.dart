import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:find_camp/Widget/Button.dart';
import 'package:find_camp/Widget/navbar.dart';

class ConsultPage extends StatelessWidget {
  const ConsultPage({super.key});

  /// Fungsi untuk membuka WhatsApp
  Future<void> openWhatsApp(BuildContext context) async {
    const phoneNumber = '6282284328889'; // Pastikan format nomor sesuai
    const message = 'Hello, I would like to consult with you.';

    // Gunakan skema WhatsApp atau fallback ke wa.me
    final Uri whatsappUri = Uri.parse(
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}');
    final Uri fallbackUri = Uri.parse(
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorDialog(context);
    }
  }

  /// Menampilkan dialog error jika WhatsApp tidak bisa dibuka
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Unable to open WhatsApp. Please try again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'To consult with us, please click on the button below.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ButtonFormStyle(
                onPressed: () => openWhatsApp(context),
                textName: 'Consulting',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
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
}
