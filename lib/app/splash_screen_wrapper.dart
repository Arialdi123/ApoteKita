import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget loading tipis yang muncul saat AuthGate menunggu stream Firebase.
/// Ini menggantikan layar putih kosong di antara splash native dan UI utama.
class SplashScreenWrapper extends StatelessWidget {
  const SplashScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0CA9BA)),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

