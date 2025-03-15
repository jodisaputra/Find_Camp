import 'package:flutter/material.dart';
import 'package:find_camp/Widget/Button.dart';
import 'package:find_camp/Login/OTP.dart';

class ForgetPage extends StatelessWidget {
  const ForgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Forgot Your Password?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Corrected here
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 10), // Added a spacer for better readability
            const Text(
              'Enter the registered email to receive help to reset your password.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ButtonFormStyle(
              textName: 'Reset Password',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset OTP sent!'),
                  ),
                );
                // Navigate to OTPPage when user presses reset password
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OTPPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
