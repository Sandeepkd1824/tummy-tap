import 'package:flutter/material.dart';
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
      title: 'JWT OTP Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      
      // ✅ Start with Login by default
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
