import 'package:find_camp/Style/theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:find_camp/OnBoarding/getstarted.dart';
import 'package:find_camp/Services/session_service.dart';
import 'package:find_camp/Services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final SessionService _sessionService;
  late final AuthService _authService;
  late final AnimationController _controller;
  bool _isAnimationComplete = false;
  bool _isSessionChecked = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _isAnimationComplete = true;
      });
      _checkSessionAndNavigate();
    }
  }

  void _initializeServices() {
    _sessionService = SessionService();
    _authService = AuthService();
  }

  Future<void> _checkSessionAndNavigate() async {
    if (_isSessionChecked) return;
    _isSessionChecked = true;

    try {
      final isLoggedIn = await _sessionService.isLoggedIn();
      if (!mounted) return;

      if (isLoggedIn) {
        final user = await _sessionService.getCurrentUser();
        if (user != null && mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/mainmenu',
            arguments: user.name,
          );
        } else if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Getstarted()),
        );
      }
    } catch (e) {
      print('Error checking session: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Getstarted()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whitecolor,
      body: Center(
        child: LottieBuilder.asset(
          "assets/Lottie/Splash_Screen.json",
          width: 400,
          height: 400,
          controller: _controller,
          onLoaded: (composition) {
            _controller.forward();
          },
        ),
      ),
    );
  }
}
