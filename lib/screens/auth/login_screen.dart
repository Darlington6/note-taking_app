// import packages/modules
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:note_taking_app/core/constants.dart';
import 'package:note_taking_app/data/services/firebase_service.dart';
import 'package:note_taking_app/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key to manage the form and validate input
  final _formKey = GlobalKey<FormState>();

  // Controllers to capture user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Tracks whether login is in progress
  bool _isLoading = false;

  // Handles login logic and Firebase authentication
  Future<void> _login() async {
    // Validate form inputs (show red errors if any)
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Show loading spinner
    setState(() => _isLoading = true);

    // Attempt login via FirebaseService
    final result = await FirebaseService.loginWithEmail(email, password);

    if (!mounted) return;

    // Handle result from Either (error or success)
    result.fold(
      (error) => _showSnackBar(error), // Show error message
      (success) async {
        _showSnackBar('Login successful!', isSuccess: true);
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, 'notes'); // Navigate to notes
      },
    );

    // Stop loading spinner
    setState(() => _isLoading = false);
  }

  // Displays a styled snackbar with a message
  void _showSnackBar(String message, {bool isSuccess = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? kSuccessColor : kErrorColor,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Clean up controllers when widget is disposed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Builds the UI for the login screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Back arrow color
        centerTitle: true,
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey, // Attach form key
          child: Column(
            children: [
              // Email input field with validator
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),

              const SizedBox(height: 24),

              // Password input field with validator
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: validatePassword,
              ),

              const SizedBox(height: 24),

              // Show loading spinner or login button
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

              const SizedBox(height: 24),

              // Redirect to signup screen
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
                          Navigator.pushReplacementNamed(context, 'signup');
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}