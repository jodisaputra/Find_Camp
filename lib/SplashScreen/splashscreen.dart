import 'package:find_camp/Style/theme.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:find_camp/OnBoarding/getstarted.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Expanded(
            child: Center(
              child: LottieBuilder.asset("assets/Lottie/Splash_Screen.json"),
            ),
          ),
        ],
      ),
      nextScreen: const Getstarted(),
      splashIconSize: 400,
      backgroundColor: whitecolor,
      duration: 5000,
      splashTransition: SplashTransition.fadeTransition,
    );
  }
}
