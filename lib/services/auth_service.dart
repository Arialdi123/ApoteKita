import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

/// Hasil operasi autentikasi
class AuthResult {
  final bool success;
  final String? message;
  final User? user;

  const AuthResult({
    required this.success,
    this.message,
    this.user,
  });
}

/// Service autentikasi terpadu:
/// - Firebase Auth (Email/Password, Google Sign-In, Phone Auth OTP)
/// - Fallback lokal / dummy untuk kenyamanan pengujian offline/development.
class AuthService {
  // ─── Singleton ─────────────────────────────────────────────────────────────
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ─── State ─────────────────────────────────────────────────────────────────
  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Notifier agar widget (AuthGate) dapat listen perubahan login secara reaktif.
  final ValueNotifier<User?> userNotifier = ValueNotifier<User?>(null);

  /// Set user dan notifikasi listener.
  void _setUser(User? user) {
    _currentUser = user;
    userNotifier.value = user;
  }

  /// Web Client ID dari file google-services.json (client -> oauth_client dengan client_type: 3)
  static const String? serverClientId =
      '419520945853-7h181sj6m6mk9j8a5om939umoleh0843.apps.googleusercontent.com';

  bool _isGoogleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      try {
        await GoogleSignIn.instance.initialize(
          serverClientId: serverClientId,
        );
        _isGoogleSignInInitialized = true;
      } catch (e) {
        debugPrint('GoogleSignIn.initialize notice: $e');
      }
    }
  }

  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  fb_auth.FirebaseAuth? get _firebaseAuth {
    if (_isFirebaseReady) {
      try {
        return fb_auth.FirebaseAuth.instance;
      } catch (e) {
        debugPrint('FirebaseAuth instance error: $e');
      }
    }
    return null;
  }

  // ─── Dummy database pengguna (Fallback & Development) ───────────────────────
  final List<Map<String, dynamic>> _users = [
    {
      'id': 'dev-001',
      'name': 'User ApoteKita',
      'email': 'user@apotekkita.com',
      'phone': '08123456789',
      'password': '123456',
    },
  ];

  // ─── Login Email & Password ───────────────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final auth = _firebaseAuth;
    if (auth != null) {
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser != null) {
          _setUser(User(
            id: fbUser.uid,
            name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'Pengguna',
            email: fbUser.email ?? email,
            phone: fbUser.phoneNumber ?? '',
            photoUrl: fbUser.photoURL,
          ));
          return AuthResult(
            success: true,
            message: 'Login berhasil.',
            user: _currentUser,
          );
        }
      } on fb_auth.FirebaseAuthException catch (e) {
        return AuthResult(
          success: false,
          message: _mapFirebaseAuthError(e.code, e.message),
        );
      } catch (e) {
        debugPrint('Firebase login exception: $e');
      }
    }

    // Fallback: Dummy Local Authentication
    await Future.delayed(const Duration(milliseconds: 600));
    final userMap = _users.firstWhere(
      (u) =>
          u['email'].toString().toLowerCase() == email.trim().toLowerCase() &&
          u['password'] == password,
      orElse: () => {},
    );

    if (userMap.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Email atau password salah. Silakan coba lagi.',
      );
    }

    _setUser(User.fromMap(userMap));
    return AuthResult(
      success: true,
      message: 'Login berhasil.',
      user: _currentUser,
    );
  }

  // ─── Register Akun Baru ────────────────────────────────────────────────────
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final auth = _firebaseAuth;
    if (auth != null) {
      try {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser != null) {
          await fbUser.updateDisplayName(name);
          _setUser(User(
            id: fbUser.uid,
            name: name,
            email: fbUser.email ?? email,
            phone: phone,
          ));
          return AuthResult(
            success: true,
            message: 'Akun berhasil dibuat. Selamat datang di ApoteKita!',
            user: _currentUser,
          );
        }
      } on fb_auth.FirebaseAuthException catch (e) {
        return AuthResult(
          success: false,
          message: _mapFirebaseAuthError(e.code, e.message),
        );
      } catch (e) {
        debugPrint('Firebase register exception: $e');
      }
    }

    // Fallback: Local database register
    await Future.delayed(const Duration(milliseconds: 600));
    final exists = _users.any(
      (u) => u['email'].toString().toLowerCase() == email.trim().toLowerCase(),
    );

    if (exists) {
      return const AuthResult(
        success: false,
        message: 'Email sudah terdaftar. Gunakan email lain.',
      );
    }

    final newUser = {
      'id': 'usr-${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'email': email.trim(),
      'phone': phone.trim(),
      'password': password,
    };
    _users.add(newUser);
    _setUser(User.fromMap(newUser));

    return AuthResult(
      success: true,
      message: 'Akun berhasil dibuat. Silakan masuk.',
      user: _currentUser,
    );
  }

  // ─── Masuk dengan Google (Google Sign-In SDK 7.x) ──────────────────────────
  Future<AuthResult> signInWithGoogle() async {
    try {
      debugPrint('--> [AuthService] Memulai proses Google Sign-In...');

      // Jika serverClientId belum diatur dan Firebase belum dihubungkan
      if (serverClientId == null && !_isFirebaseReady) {
        await Future.delayed(const Duration(milliseconds: 700));
        _setUser(const User(
          id: 'google-demo-user',
          name: 'Pengguna Google Demo',
          email: 'google.demo@apotekkita.com',
          phone: '08123456789',
        ));
        return AuthResult(
          success: true,
          message: 'Berhasil masuk dengan Google (Mode Demo).',
          user: _currentUser,
        );
      }

      await _ensureGoogleSignInInitialized();

      debugPrint('--> [AuthService] Memanggil GoogleSignIn.instance.authenticate()...');
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      debugPrint('--> [AuthService] Berhasil mendapatkan akun Google: ${googleUser.email}');

      // Coba autentikasi ke Firebase jika token tersedia
      try {
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final auth = _firebaseAuth;
        if (auth != null && googleAuth.idToken != null) {
          final fb_auth.AuthCredential credential =
              fb_auth.GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
          );

          final userCredential = await auth.signInWithCredential(credential);
          final fbUser = userCredential.user;

          if (fbUser != null) {
            _setUser(User(
              id: fbUser.uid,
              name: fbUser.displayName ?? googleUser.displayName ?? 'Pengguna Google',
              email: fbUser.email ?? googleUser.email,
              phone: fbUser.phoneNumber ?? '',
              photoUrl: fbUser.photoURL ?? googleUser.photoUrl,
            ));

            return AuthResult(
              success: true,
              message: 'Berhasil masuk dengan akun Google.',
              user: _currentUser,
            );
          }
        }
      } catch (fbErr) {
        debugPrint('--> [AuthService] Firebase credential exchange notice: $fbErr');
        // Jangan batalkan! Akun Google sudah dipilih pengguna di perangkat.
      }

      // Jika Firebase Auth belum berhasil atau offline, gunakan data akun Google langsung
      _setUser(User(
        id: googleUser.id,
        name: googleUser.displayName ?? 'Pengguna Google',
        email: googleUser.email,
        phone: '',
        photoUrl: googleUser.photoUrl,
      ));

      return AuthResult(
        success: true,
        message: 'Berhasil masuk dengan akun Google.',
        user: _currentUser,
      );
    } on GoogleSignInException catch (e) {
      debugPrint('--> [AuthService] GoogleSignInException: code=${e.code}, desc=${e.description}');

      // Pada debug mode di emulator, jika Google Play Services membatalkan karena Developer Error (SHA-1 belum terdaftar)
      if (kDebugMode) {
        debugPrint('--> [AuthService] Mengaktifkan login Google mode pengujian (fallback)...');
        await Future.delayed(const Duration(milliseconds: 500));
        _setUser(const User(
          id: 'google-user-debug',
          name: 'Pengguna Google (Debug)',
          email: 'pengguna.google@apotekkita.com',
          phone: '081234567890',
        ));
        return AuthResult(
          success: true,
          message: 'Berhasil masuk dengan Google (Mode Pengujian).',
          user: _currentUser,
        );
      }

      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const AuthResult(
          success: false,
          message: 'Masuk dengan Google dibatalkan.',
        );
      }
      return AuthResult(
        success: false,
        message: 'Google Sign-In gagal: ${e.description ?? e.code.name}',
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      debugPrint('--> [AuthService] FirebaseAuthException: code=${e.code}, msg=${e.message}');
      if (kDebugMode) {
        _setUser(const User(
          id: 'google-user-debug',
          name: 'Pengguna Google (Debug)',
          email: 'pengguna.google@apotekkita.com',
          phone: '081234567890',
        ));
        return AuthResult(
          success: true,
          message: 'Berhasil masuk dengan Google (Mode Pengujian).',
          user: _currentUser,
        );
      }
      return AuthResult(
        success: false,
        message: _mapFirebaseAuthError(e.code, e.message),
      );
    } catch (e) {
      debugPrint('--> [AuthService] Google Sign-In Error umum: $e');
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        _setUser(const User(
          id: 'google-demo-user',
          name: 'Pengguna Google Demo',
          email: 'google.user@example.com',
          phone: '081298765432',
        ));
        return AuthResult(
          success: true,
          message: 'Berhasil masuk dengan akun Google (Mode Demo).',
          user: _currentUser,
        );
      }
      return AuthResult(
        success: false,
        message: 'Gagal terhubung dengan akun Google: ${e.toString()}',
      );
    }
  }

  // ─── Phone Auth via Firebase (Kirim OTP) ──────────────────────────────────
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
    required Function(User user) onAutoVerified,
  }) async {
    final auth = _firebaseAuth;
    if (auth != null) {
      try {
        await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
            try {
              final userCredential = await auth.signInWithCredential(credential);
              final fbUser = userCredential.user;
              if (fbUser != null) {
                final user = User(
                  id: fbUser.uid,
                  name: fbUser.displayName ?? 'Pengguna Telepon',
                  email: fbUser.email ?? '',
                  phone: fbUser.phoneNumber ?? phoneNumber,
                );
                _currentUser = user;
                onAutoVerified(user);
              }
            } catch (e) {
              onError('Gagal verifikasi otomatis: $e');
            }
          },
          verificationFailed: (fb_auth.FirebaseAuthException e) {
            onError(_mapFirebaseAuthError(e.code, e.message));
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
        return;
      } catch (e) {
        debugPrint('Phone verify error: $e');
      }
    }

    // Demo/Simulated fallback jika Firebase belum setup di perangkat pengembang:
    await Future.delayed(const Duration(milliseconds: 800));
    const simulatedVerificationId = 'demo-verification-id-apotekita';
    onCodeSent(simulatedVerificationId);
  }

  // ─── Verifikasi Kode OTP ──────────────────────────────────────────────────
  Future<AuthResult> verifyOtp({
    required String verificationId,
    required String smsCode,
    String? phoneNumber,
  }) async {
    final auth = _firebaseAuth;
    if (auth != null && verificationId != 'demo-verification-id-apotekita') {
      try {
        final credential = fb_auth.PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        final userCredential = await auth.signInWithCredential(credential);
        final fbUser = userCredential.user;
        if (fbUser != null) {
          _setUser(User(
            id: fbUser.uid,
            name: fbUser.displayName ?? 'Pengguna Telepon',
            email: fbUser.email ?? '',
            phone: fbUser.phoneNumber ?? phoneNumber ?? '',
          ));
          return AuthResult(
            success: true,
            message: 'Verifikasi nomor HP berhasil.',
            user: _currentUser,
          );
        }
      } on fb_auth.FirebaseAuthException catch (e) {
        return AuthResult(
          success: false,
          message: _mapFirebaseAuthError(e.code, e.message),
        );
      } catch (e) {
        return AuthResult(
          success: false,
          message: 'Verifikasi OTP gagal: $e',
        );
      }
    }

    // Demo mode: verifikasi kode 6 digit
    await Future.delayed(const Duration(milliseconds: 600));
    if (smsCode.trim().length == 6) {
      _setUser(User(
        id: 'phone-user-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Pengguna ApoteKita',
        email: '',
        phone: phoneNumber ?? '081234567890',
      ));
      return AuthResult(
        success: true,
        message: 'Verifikasi OTP berhasil.',
        user: _currentUser,
      );
    } else {
      return const AuthResult(
        success: false,
        message: 'Kode OTP tidak valid. Masukkan 6 digit yang benar.',
      );
    }
  }

  // ─── Lupa Password ─────────────────────────────────────────────────────────
  Future<AuthResult> forgotPassword({required String email}) async {
    final auth = _firebaseAuth;
    if (auth != null) {
      try {
        await auth.sendPasswordResetEmail(email: email.trim());
        return const AuthResult(
          success: true,
          message: 'Tautan pemulihan password telah dikirim ke email Anda.',
        );
      } on fb_auth.FirebaseAuthException catch (e) {
        return AuthResult(
          success: false,
          message: _mapFirebaseAuthError(e.code, e.message),
        );
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 600));
    return const AuthResult(
      success: true,
      message:
          'Jika email terdaftar, instruksi pemulihan password akan dikirim ke email Anda.',
    );
  }

  // ─── Ganti Password ────────────────────────────────────────────────────────
  Future<AuthResult> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_currentUser == null) {
      return const AuthResult(
        success: false,
        message: 'Sesi habis. Silakan login kembali.',
      );
    }

    final userMap = _users.firstWhere(
      (u) =>
          u['email'] == _currentUser!.email && u['password'] == oldPassword,
      orElse: () => {},
    );

    if (userMap.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Password lama tidak sesuai.',
      );
    }

    userMap['password'] = newPassword;
    return const AuthResult(
      success: true,
      message: 'Password berhasil diubah.',
    );
  }

  // ─── Sync dari Firebase User (dipakai AuthGate) ────────────────────────────
  /// Menyinkronkan state lokal AuthService dari objek FirebaseUser aktif.
  void syncFromFirebaseUser(fb_auth.User fbUser) {
    _setUser(User(
      id: fbUser.uid,
      name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'Pengguna',
      email: fbUser.email ?? '',
      phone: fbUser.phoneNumber ?? '',
      photoUrl: fbUser.photoURL,
    ));
  }

  // ─── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    try {
      await _firebaseAuth?.signOut();
    } catch (_) {}
    _setUser(null);
  }

  // ─── Helper Pemetaan Pesan Error Firebase ──────────────────────────────────
  String _mapFirebaseAuthError(String code, String? originalMessage) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau kata sandi tidak sesuai.';
      case 'email-already-in-use':
        return 'Email ini sudah digunakan oleh akun lain.';
      case 'invalid-email':
        return 'Format alamat email tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Minimal 6 karakter.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan gagal. Silakan coba lagi nanti.';
      case 'invalid-verification-code':
        return 'Kode OTP yang dimasukkan salah.';
      case 'invalid-phone-number':
        return 'Nomor telepon tidak valid. Pastikan format nomor benar.';
      case 'session-expired':
        return 'Masa berlaku kode OTP telah habis. Silakan kirim ulang.';
      default:
        return originalMessage ?? 'Terjadi kesalahan autentikasi ($code).';
    }
  }
}
