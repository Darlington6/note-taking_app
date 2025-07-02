// import packages/modules

import 'package:flutter/material.dart';
import '../auth/signup_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Note Taking App",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blueGrey[900],
      ),
      // Use SafeArea widget to prevent overflows
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Vertically centers the children within the Column
            crossAxisAlignment: CrossAxisAlignment.center, // Horizontally aligns the children to the center of the Column
            children: [
              const Text(
                'Welcome to Note-taking App',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Your ultimate companion for planning, organizing, and keeping your notes in one place.',
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 24),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange
                    ),
                  child: const Text(
                    'Get Started', 
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                      ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}