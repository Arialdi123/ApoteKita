import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const ApoteKitaApp());
}

class ApoteKitaApp extends StatelessWidget {
  const ApoteKitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ApoteKita',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6CE421),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
