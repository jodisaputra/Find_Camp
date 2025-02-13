import 'package:flutter/material.dart';
import 'package:find_camp/isian/form.dart'; // Import the FormScreen from form.dart

class SyaratVisaScreen extends StatelessWidget {
  const SyaratVisaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Visa - Malaysia',
          style: TextStyle(fontWeight: FontWeight.bold), // Make the title bold
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Implement back button functionality here
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(
                  image: Image.asset('assets/Image/personal_bond.jpg'),
                  title: 'Personal Bond',
                  description: 'Personal bond ini sendiri adalah surat tanggungan dengan biaya yang bervariasi.'
              ),
              SizedBox(height: 16.0),
              _buildCard(
                  image: Image.asset('assets/Image/health_checkup.jpg'),
                  title: 'Persiapan Dokumen',
                  description: 'Pemeriksaan kesehatan di Klinik Panel Layanan Global Pendidikan Malaysia Pusat Kesehatan Universitas Negeri yang disetujui.'
              ),
              SizedBox(height: 16.0),
              _buildCard(
                  image: Image.asset('assets/Image/clock.jpg'),
                  title: 'Persyaratan Kesehatan',
                  description: 'Proses pengajuan Surat Persetujuan Visa Pelajar Malaysia hingga menerima Student Pass membutuhkan waktu 4-6 minggu.'
              ),
              SizedBox(height: 16.0),
              _buildCard(
                  image: Image.asset('assets/Image/money.jpg'),
                  title: 'Proses Pengajuan',
                  description: 'Mengurus student pass membutuhkan biaya RM60.00 per tahun.'
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FormScreen()), // Navigate to FormScreen from form.dart
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8C52FF),
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(50.0),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Apply'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required Image image,
    required String title,
    required String description,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          image,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8.0),
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
