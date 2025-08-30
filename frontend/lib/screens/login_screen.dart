import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String route = "/login";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Autofill only once from arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _usernameController.text = args["username"] ?? "";
      _passwordController.text = args["password"] ?? "";
    }
  }

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final res = await ApiService.loginUser(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (res.containsKey("error")) {
      setState(() => _errorMessage = res["error"]);
    } else {
      Navigator.pushReplacementNamed(context, HomeScreen.route);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "username"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _loginUser,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, RegisterScreen.route);
              },
              child: const Center(
                child: Text(
                  "Don’t have an account? Register",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
