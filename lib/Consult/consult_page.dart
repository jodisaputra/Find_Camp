import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:find_camp/Widget/navbar.dart';

class ConsultPage extends StatelessWidget {
  const ConsultPage({super.key});

  /// Fungsi untuk membuka WhatsApp dengan nomor yang diberikan
  Future<void> openWhatsApp(BuildContext context, String phoneNumber) async {
    const message = 'Hello, I would like to consult with you.';
    final Uri whatsappUri = Uri.parse('whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}');
    final Uri fallbackUri = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

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
                'To consult with us, please click on one of the buttons below.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.description_rounded),
                      label: const Text('Doc Consult', style: TextStyle(fontSize: 16)),
                      onPressed: () => openWhatsApp(context, '+62 895-0925-7148'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.school_rounded),
                      label: const Text('Univ Consult', style: TextStyle(fontSize: 16)),
                      onPressed: () => openWhatsApp(context, '+62 823-8400-5856'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.more_horiz_rounded),
                      label: const Text('More', style: TextStyle(fontSize: 16)),
                      onPressed: () => openWhatsApp(context, '+62 821-7148-7042'),
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
