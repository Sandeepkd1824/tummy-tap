import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  static const String route = '/auth';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  String _message = "";
  bool _showOtpField = false; // 👈 control OTP visibility

  void _register() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _message = "Please fill all fields!";
      });
      return;
    }

    final res = await ApiService.registerUser(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _message = res["message"] ?? "OTP sent!";
      _showOtpField = true; // 👈 now show OTP field
    });
  }

  void _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _message = "Please enter OTP!";
      });
      return;
    }

    final res =
        await ApiService.verifyOtp(_emailController.text, _otpController.text);

    setState(() {
      _message = res["message"] ?? "OTP verification failed!";
    });

    if ((res["message"] ?? "").contains("verified")) {
      // Go to login after OTP verified
      _login();
    }
  }

  void _login() async {
    final res = await ApiService.login(
      _usernameController.text.isNotEmpty
          ? _usernameController.text
          : _emailController.text,
      _passwordController.text,
    );

    if (res.containsKey("access")) {
      Navigator.pushReplacementNamed(context, HomeScreen.route);
    } else {
      setState(() {
        _message = res["detail"] ?? "Login failed!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TummyTap Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Step 1: Register fields
            TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username")),
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _register, child: const Text("Register")),

            // Step 2: OTP field (only shows after register)
            if (_showOtpField) ...[
              const SizedBox(height: 20),
              TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(labelText: "Enter OTP")),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _verifyOtp, child: const Text("Verify OTP")),
            ],

            const SizedBox(height: 20),
            Text(_message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
