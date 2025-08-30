import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String route = "/register";

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = "";

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final res = await ApiService.registerUser(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (res.containsKey("error")) {
      setState(() => _errorMessage = res["error"]);
    } else {
      // ✅ Pass username, email, password to OTP screen
      Navigator.pushReplacementNamed(
        context,
        OTPScreen.route,
        arguments: {
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        },
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _registerUser,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Register"),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
