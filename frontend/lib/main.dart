import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TummyTap',
      theme: AppThemes.spicy, // 👈 Change theme here
      initialRoute: LoginScreen.route,
      routes: {
        LoginScreen.route: (context) => const LoginScreen(),
        RegisterScreen.route: (context) => const RegisterScreen(),
        OTPScreen.route: (context) => const OTPScreen(),
        HomeScreen.route: (context) => const HomeScreen(),
      },
    );
  }
}
