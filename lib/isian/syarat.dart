import 'package:flutter/material.dart';
import 'package:find_camp/isian/syaratvisa.dart'; // Import the SyaratVisaScreen class
class SyaratScreen extends StatefulWidget {
  const SyaratScreen({super.key});

  @override
  _SyaratScreenState createState() => _SyaratScreenState();
}

class _SyaratScreenState extends State<SyaratScreen> {

  List<bool> checkboxStates = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: const Row(
          children: [
            Text(
              'Syarat',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ],
        ),
        centerTitle: false, // Title aligned to the left
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Visa Card
          _buildCard(
            image: 'assets/Image/visa.jpg', // Replace with your image asset
            title: 'Visa',
            price: 'RP.200.000',
            duration: '14 Days',
            isFree: false, // Not free
            context: context,
            index: 0, // Pass index to update the corresponding checkbox state
          ),
          const SizedBox(height: 16),

          // Letter of Recommendation Card
          _buildCard(
            image: 'assets/Image/recommendation.jpg', // Replace with your image asset
            title: 'Letter of recommendation',
            price: 'FREE',
            duration: '3 Weeks',
            isFree: true, // Free
            context: context,
            index: 1, // Pass index to update the corresponding checkbox state
          ),
          const SizedBox(height: 16),

          // Passport Card
          _buildCard(
            image: 'assets/Image/passport.jpg', // Replace with your image asset
            title: 'Passport',
            price: 'RP.300.000',
            duration: '2 Weeks',
            isFree: false, // Not free
            context: context,
            index: 2, // Pass index to update the corresponding checkbox state
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String image,
    required String title,
    required String price,
    required String duration,
    required bool isFree,
    required BuildContext context,
    required int index,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                image,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),

            // Title and Custom Checkbox (Gray Square)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                // Custom Gray Square Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[300], // Gray background
                  ),
                  child: Checkbox(
                    value: checkboxStates[index], // Use the corresponding state
                    onChanged: (bool? newValue) {
                      setState(() {
                        checkboxStates[index] = newValue ?? false; // Update the state
                      });
                    },
                    activeColor: Colors.green, // Set the check mark color to green
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Price or FREE Text
            Text(
              price,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isFree ? Colors.lightBlue : Colors.red,
              ),
            ),
            const SizedBox(height: 8),

            // Duration and How to Apply? Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Duration
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(duration, style: const TextStyle(color: Colors.grey)),
                  ],
                ),

                // "How to Apply?" Button
                ElevatedButton(
                  onPressed: () {
                    if (title == 'Visa') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SyaratVisaScreen()), // Navigate to SyaratVisaScreen
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C52FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'How to Apply?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
