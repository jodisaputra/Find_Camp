import 'package:find_camp/Services/auth_service.dart';
import 'package:find_camp/Widget/brandbutton.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:find_camp/MainMenu/MainMenu.dart';
import 'package:find_camp/Style/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final FirebaseAuth auth = FirebaseAuth.instance;

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with credential
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      // Get the Firebase ID token
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) throw Exception('Failed to get Firebase ID token');

      // Send to your Laravel API
      final response = await _authService.loginWithGoogle(idToken);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenu(
            username: response['user']['name'] ?? 'Guest',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithEmailPassword(BuildContext context) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Starting login process'); // Debug log

      final response = await _authService.loginWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );

      print('Login successful, response: $response'); // Debug log

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );

      // Navigate to MainMenu
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenu(
            username: response['user']['name'] ?? 'Guest',
          ),
        ),
      );
    } catch (e) {
      print('Login error: $e'); // Debug log

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Login failed: ${e.toString().replaceAll('Exception:', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 70),
            Image.asset('assets/Image/FindCampLogo.png'),
            const SizedBox(height: 40),
            const Text(
              'ENTER TO FIND YOUR DREAM UNIVERSITY!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),

            // Username TextField
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 10),

            // Password TextField
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgotpassword');
                },
                child: const Text("Forgot Password?"),
              ),
            ),
            const SizedBox(height: 30),

            // Login Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: purplecolor,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.3, vertical: 15),
              ),
              onPressed:
                  _isLoading ? null : () => _signInWithEmailPassword(context),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.login, color: Colors.white),
                        SizedBox(width: 15),
                        Text("Login", style: TextStyle(color: Colors.white)),
                      ],
                    ),
            ),

            const SizedBox(height: 14),

            // Google Login Button
            BrandButton(
              brandIcon: Image.asset(
                'assets/Image/Google_Logo.png',
                height: 24,
              ),
              label: "Continue with Google",
              onPressed: _isLoading
                  ? null
                  : () async {
                      await _signInWithGoogle(context);
                    },
              backgroundColor: Colors.white,
              textColor: Colors.black,
              height: 48,
            ),

            const SizedBox(height: 100),

            const Text(
              "By registering, you agree to the Terms of Service, "
              "Privacy Policy, and Cookie Policy.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
