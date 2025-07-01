// import packages/modules

import 'package:flutter/material.dart';
import 'package:note_taking_app/data/services/firebase_service.dart';
import 'package:note_taking_app/utils/validators.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers for user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // Spinner toggle

  // Sign up logic using FirebaseService
  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (emailError != null || passwordError != null) {
      _showSnackBar(emailError ?? passwordError!);
      return;
    }

    setState(() => _isLoading = true);

    final result = await FirebaseService.signUpWithEmail(email, password);

    if (!mounted) return;

    result.fold(
      (error) => _showSnackBar(error),
      (success) async {
        _showSnackBar('Signup successful. Please log in.', isSuccess: true);
        await Future.delayed(const Duration(seconds: 1)); // Wait before navigating
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
    );

    setState(() => _isLoading = false);
  }

  // Shows styled SnackBar (floating, top-right, green/red)
  void _showSnackBar(String message, {bool isSuccess = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Email input
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Password input
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),

            const SizedBox(height: 24),

            // Button or spinner
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Sign Up'),
                  ),

            const SizedBox(height: 24),

            // Redirect to login
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}