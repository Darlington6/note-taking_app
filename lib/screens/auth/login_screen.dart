// import packages/modules

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
  // Clean up the controllers to free memory when the widget is disposed
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set back arrow color to white for enhanced visibility
        ),
        centerTitle: true,
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blueGrey[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 24),

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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700
                    ),
                    child: const Text('Login', style: TextStyle(color: Colors.white),),
                  ),

            const SizedBox(height: 24),

            // Redirect to Notes Screen
            RichText(
              text: TextSpan(
                text: "Don't have an account yet? ",
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: "Sign up",
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        );
                      },
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}