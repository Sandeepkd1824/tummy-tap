import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  static const String route = "/otp";

  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = "";

  Future<void> _verifyOtpAndLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    // Step 1: Verify OTP
    final res = await ApiService.verifyOtp(email, _otpController.text.trim());

    if (res.containsKey("error")) {
      setState(() => _errorMessage = res["error"]);
    } else if (res.containsKey("message") &&
        res["message"].toString().contains("success")) {
      // ✅ OTP verified → now login automatically
      final loginRes = await ApiService.loginUser(email, password);

      if (loginRes.containsKey("access") && loginRes.containsKey("refresh")) {
        // Save tokens
        await TokenStorage.saveTokens(
          loginRes["access"],
          loginRes["refresh"],
        );

        // Go to Home
        Navigator.pushReplacementNamed(context, HomeScreen.route);
      } else {
        setState(() => _errorMessage = loginRes["error"] ?? "Login failed");
      }
    } else {
      setState(() => _errorMessage = "Invalid OTP");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final email = args?["email"] ?? "";
    final password = args?["password"] ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("OTP sent to $email"),
            const SizedBox(height: 10),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _verifyOtpAndLogin(email, password),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify OTP"),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
