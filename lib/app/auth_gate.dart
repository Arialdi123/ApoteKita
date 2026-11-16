import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/user/home_screen.dart';
import 'splash_screen_wrapper.dart';

/// AuthGate memantau status autentikasi Firebase secara real-time
/// menggunakan [StreamBuilder] + [authStateChanges()].
///
/// Alur:
///   - Waiting    → SplashScreenWrapper (loading awal)
///   - Firebase user masuk   → HomeScreen
///   - Firebase user null → cek AuthService lokal → HomeScreen / LoginScreen
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final bool firebaseAvailable = _isFirebaseAvailable();

    if (firebaseAvailable) {
      return StreamBuilder<fb_auth.User?>(
        stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Saat snapshot masih loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreenWrapper();
          }

          // Firebase user masih login
          if (snapshot.hasData && snapshot.data != null) {
            final authService = AuthService();
            if (!authService.isLoggedIn) {
              final fbUser = snapshot.data!;
              authService.syncFromFirebaseUser(fbUser);
            }
            return const HomeScreen();
          }

          // Fallback: pantau AuthService lokal (untuk demo mode / email dummy)
          // menggunakan ValueListenableBuilder agar reaktif saat user berubah
          return ValueListenableBuilder<dynamic>(
            valueListenable: AuthService().userNotifier,
            builder: (context, user, _) {
              if (user != null) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          );
        },
      );
    }

    // Fallback: jika Firebase belum dikonfigurasi, gunakan state lokal
    return _LocalAuthGate();
  }

  bool _isFirebaseAvailable() {
    try {
      return fb_auth.FirebaseAuth.instance != null;
    } catch (_) {
      return false;
    }
  }
}

/// LocalAuthGate: reaktif terhadap AuthService.userNotifier (ValueNotifier).
class _LocalAuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<dynamic>(
      valueListenable: AuthService().userNotifier,
      builder: (context, user, _) {
        if (user != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
