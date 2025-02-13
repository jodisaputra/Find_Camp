import 'package:find_camp/Login/OTP.dart';
import 'package:find_camp/isian/task.dart';
import 'package:flutter/material.dart';
import 'package:find_camp/Consult/consult_page.dart';
import 'package:find_camp/Profile/profile_page.dart';
import 'package:find_camp/Widget/navbar.dart';
import 'package:find_camp/MainMenu/MainMenu.dart';
import 'package:find_camp/SplashScreen/splashscreen.dart';
import 'package:find_camp/Login/login.dart';
import 'package:find_camp/Login/forgot_password.dart';
import 'package:find_camp/Login/register_email.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:find_camp/Profile/edit_profile.dart';
import 'package:find_camp/Profile/setting.dart';
import 'package:find_camp/isian/form.dart';
// Constants for route names
class Routes {
  static const String splashScreen = '/';
  static const String mainMenu = '/mainmenu';
  static const String profile = '/profile';
  static const String consult = '/consult';
  static const String login = '/login';
  static const String forgotPassword = '/forgotpassword';
  static const String register = '/register';
  static const String editProfile = '/editProfile';
  static const String settings = '/settings';
  static const String task = '/task';
  static const String OTP = '/OTP';
  static const String Form = '/formPage';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindCamp',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splashScreen,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.splashScreen:
            return MaterialPageRoute(builder: (context) => const SplashScreen());
          case Routes.mainMenu:
            final username = settings.arguments as String? ?? "Guest User";
            return MaterialPageRoute(
              builder: (context) => MainMenu(username: username),
            );
          case Routes.profile:
            final args = settings.arguments as Map<String, String>? ?? {"username": "User", "email": ""};
            return MaterialPageRoute(
              builder: (context) => ProfilePage(
                username: args["username"]!,
                email: args["email"]!,
              ),
            );
          case Routes.consult:
            return MaterialPageRoute(builder: (context) => ConsultPage());
          case Routes.login:
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case Routes.forgotPassword:
            return MaterialPageRoute(builder: (context) => ForgetPage());
          case Routes.register:
            return MaterialPageRoute(builder: (context) => RegisterPage());
          case Routes.editProfile:
            return MaterialPageRoute(builder: (context) => EditProfilePage());
          case Routes.settings:
            return MaterialPageRoute(builder: (context) => SettingsPage());
          case Routes.task:
            return MaterialPageRoute(builder: (context) => TaskScreen());
          case Routes.OTP:
            return MaterialPageRoute(builder: (context) => OTPPage());
          case Routes.Form:
            return MaterialPageRoute(builder: (context) => FormScreen());
          default:
            return MaterialPageRoute(
              builder: (context) => ErrorPage(message: 'Route not found: ${settings.name}'),
            );
        }
      },
    );
  }
}

// Example ErrorPage widget to handle invalid routes
class ErrorPage extends StatelessWidget {
  final String message;

  const ErrorPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text(message, style: const TextStyle(fontSize: 16, color: Colors.red)),
      ),
    );
  }
}
