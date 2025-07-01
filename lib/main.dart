// import packages/modules
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_taking_app/screens/home/splash_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/note_provider.dart';

void main() async {
  // Ensure binding before initializing Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with generated config
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Register all providers here
      providers: [
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(), // Initial screen
      ),
    );
  }
}