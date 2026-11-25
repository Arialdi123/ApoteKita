import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/user.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/user/home_screen.dart';
import '../screens/apoteker/apoteker_dashboard_screen.dart';
import '../screens/pegawai/pegawai_dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import 'splash_screen_wrapper.dart';

/// AuthGate memantau status autentikasi & mengarahkan pengguna
/// ke dashboard yang sesuai dengan role-nya (Pengguna, Apoteker, Pegawai, Admin).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static Widget widgetForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const AdminDashboardScreen();
      case UserRole.apoteker:
        return const ApotekerDashboardScreen();
      case UserRole.pegawai:
        return const PegawaiDashboardScreen();
      case UserRole.user:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final bool firebaseAvailable = _isFirebaseAvailable();

    return ListenableBuilder(
      listenable: authService,
      builder: (context, _) {
        // Jika sesi sudah aktif di AuthService (akun 4 role / Firebase tersinkron)
        if (authService.isLoggedIn && authService.currentUser != null) {
          return widgetForRole(authService.currentUser!.role);
        }

        if (firebaseAvailable) {
          return StreamBuilder<fb_auth.User?>(
            stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreenWrapper();
              }

              if (snapshot.hasData && snapshot.data != null) {
                if (!authService.isLoggedIn) {
                  authService.syncFromFirebaseUser(snapshot.data!);
                }
                final role = authService.currentUser?.role ?? UserRole.user;
                return widgetForRole(role);
              }

              if (authService.isLoggedIn && authService.currentUser != null) {
                return widgetForRole(authService.currentUser!.role);
              }

              return const LoginScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }

  bool _isFirebaseAvailable() {
    try {
      fb_auth.FirebaseAuth.instance;
      return true;
    } catch (_) {
      return false;
    }
  }
}
