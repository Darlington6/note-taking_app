// import packages/modules

import 'package:flutter/material.dart';
import 'package:note_taking_app/data/services/firebase_service.dart';
import 'package:note_taking_app/utils/validators.dart';
import 'package:note_taking_app/notes/notes_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Login logic using FirebaseService
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (emailError != null || passwordError != null) {
      _showSnackBar(emailError ?? passwordError!);
      return;
    }

    setState(() => _isLoading = true);

    final result = await FirebaseService.loginWithEmail(email, password);

    if (!mounted) return;

    result.fold(
      (error) => _showSnackBar(error),
      (success) async {
        _showSnackBar('Login successful!', isSuccess: true);
        await Future.delayed(const Duration(seconds: 1)); // Wait before navigating
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NotesScreen()),
        );
      },
    );

    setState(() => _isLoading = false);
  }

  // Shows a styled SnackBar for errors or success
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
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),

            const SizedBox(height: 24),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),

            const SizedBox(height: 24),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text("Don't have an account yet? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}