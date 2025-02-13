import 'package:find_camp/OnBoarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:find_camp/Style/theme.dart';
import 'package:find_camp/Widget/Button.dart';

class Getstarted extends StatelessWidget {
  const Getstarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whitecolor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Image/logo.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            Text(
              "Hello Student!",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: bluelight,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Best Partner to find your future.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ButtonFormStyle(
              textName: 'Get Started',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const OnBoarding()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
