import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
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

/// Service autentikasi & manajemen pengguna multi-role (Pengguna, Apoteker, Pegawai, Admin):
/// - Firebase Auth (Email/Password, Google Sign-In, Phone Auth OTP)
/// - Cloud Firestore ('users') untuk menyimpan profil & role setiap akun
/// - Akun bawaan untuk semua 4 role agar siap diuji kapan saja.
class AuthService extends ChangeNotifier {
  // ─── Singleton ─────────────────────────────────────────────────────────────
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal() {
    syncUsersFromFirestore();
  }

  // ─── State ─────────────────────────────────────────────────────────────────
  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Web Client ID dari file google-services.json (client -> oauth_client dengan client_type: 3)
  static const String serverClientId =
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

  CollectionReference<Map<String, dynamic>>? get _usersRef {
    if (_isFirebaseReady) {
      try {
        return FirebaseFirestore.instance.collection('users');
      } catch (_) {}
    }
    return null;
  }

  // ─── Daftar Akun Bawaan 4 Role & Pengguna Terkelola ────────────────────────
  final List<Map<String, dynamic>> _users = [
    {
      'id': 'dev-001',
      'name': 'User ApoteKita',
      'email': 'user@apotekkita.com',
      'phone': '081234567890',
      'password': '123456',
      'role': 'user',
      'allergies': <String>['Penisilin'],
    },
    {
      'id': 'staff-apoteker-01',
      'name': 'apt. Siti Rahma, S.Farm.',
      'email': 'apoteker@apotekkita.com',
      'phone': '081298760001',
      'password': '123456',
      'role': 'apoteker',
      'allergies': <String>[],
    },
    {
      'id': 'staff-pegawai-01',
      'name': 'Budi Santoso',
      'email': 'pegawai@apotekkita.com',
      'phone': '081298760002',
      'password': '123456',
      'role': 'pegawai',
      'allergies': <String>[],
    },
    {
      'id': 'staff-admin-01',
      'name': 'Admin ApoteKita',
      'email': 'admin@apotekkita.com',
      'phone': '081298760003',
      'password': '123456',
      'role': 'admin',
      'allergies': <String>[],
    },
  ];

  /// Daftar seluruh pengguna untuk ditampilkan & dikelola Admin
  List<User> get allUsers =>
      _users.map((u) => User.fromMap(u)).toList(growable: false);

  /// Sinkronkan daftar pengguna & role dari Firestore koleksi 'users'
  Future<void> syncUsersFromFirestore() async {
    final ref = _usersRef;
    if (ref == null) return;
    try {
      final snap = await ref.get();
      if (snap.docs.isEmpty) {
        // Seed akun bawaan ke Firestore agar Admin bisa melihat & mengelola semuanya
        for (final u in _users) {
          final safeMap = Map<String, dynamic>.from(u)..remove('password');
          await ref.doc(u['id'].toString()).set(safeMap, SetOptions(merge: true));
        }
        return;
      }

      for (final doc in snap.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final email = (data['email'] ?? '').toString().toLowerCase();
        final idx = _users.indexWhere(
          (u) =>
              u['id'] == data['id'] ||
              (email.isNotEmpty &&
                  u['email'].toString().toLowerCase() == email),
        );
        if (idx != -1) {
          final existingPwd = _users[idx]['password'];
          _users[idx] = {
            ..._users[idx],
            ...data,
            if (existingPwd != null && data['password'] == null)
              'password': existingPwd,
          };
        } else {
          _users.add(data);
        }
      }

      // Perbarui currentUser jika rolenya berubah
      if (_currentUser != null) {
        final updated = _findLocalUserMapByIdOrEmail(
          id: _currentUser!.id,
          email: _currentUser!.email,
        );
        if (updated != null) {
          _currentUser = User.fromMap(updated);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('syncUsersFromFirestore notice: $e');
    }
  }

  Map<String, dynamic>? _findLocalUserMapByIdOrEmail({
    String? id,
    String? email,
  }) {
    final cleanEmail = email?.trim().toLowerCase() ?? '';
    for (final u in _users) {
      if (id != null && id.isNotEmpty && u['id'] == id) return u;
      if (cleanEmail.isNotEmpty &&
          u['email'].toString().toLowerCase() == cleanEmail) {
        return u;
      }
    }
    return null;
  }

  Future<User> _resolveAndPersistFirebaseUser({
    required String uid,
    required String name,
    required String email,
    required String phone,
    String? photoUrl,
  }) async {
    UserRole resolvedRole = UserRole.user;
    List<String> resolvedAllergies = const [];

    final localMatch = _findLocalUserMapByIdOrEmail(id: uid, email: email);
    if (localMatch != null) {
      resolvedRole = UserRoleExtension.fromString(localMatch['role']?.toString());
      if (localMatch['allergies'] is List) {
        resolvedAllergies = List<String>.from(localMatch['allergies']);
      }
    }

    final ref = _usersRef;
    if (ref != null) {
      try {
        final doc = await ref.doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final d = doc.data()!;
          resolvedRole = UserRoleExtension.fromString(d['role']?.toString());
          if (d['allergies'] is List) {
            resolvedAllergies = List<String>.from(d['allergies']);
          }
        } else if (email.isNotEmpty) {
          final byEmail = await ref
              .where('email', isEqualTo: email.trim().toLowerCase())
              .limit(1)
              .get();
          if (byEmail.docs.isNotEmpty) {
            final d = byEmail.docs.first.data();
            resolvedRole = UserRoleExtension.fromString(d['role']?.toString());
            if (d['allergies'] is List) {
              resolvedAllergies = List<String>.from(d['allergies']);
            }
          }
        }
      } catch (e) {
        debugPrint('Firestore role lookup notice: $e');
      }
    }

    final user = User(
      id: uid,
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      role: resolvedRole,
      allergies: resolvedAllergies,
    );

    _upsertLocalAndFirestoreUser(user);
    return user;
  }

  Future<void> _upsertLocalAndFirestoreUser(User user, {String? password}) async {
    final idx = _users.indexWhere(
      (u) =>
          u['id'] == user.id ||
          (user.email.isNotEmpty &&
              u['email'].toString().toLowerCase() ==
                  user.email.toLowerCase()),
    );

    final map = <String, dynamic>{
      if (idx != -1) ..._users[idx],
      ...user.toMap(),
      'password': ?password,
    };

    if (idx != -1) {
      _users[idx] = map;
    } else {
      _users.add(map);
    }
    notifyListeners();

    final ref = _usersRef;
    if (ref != null) {
      try {
        await ref.doc(user.id).set(user.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore upsert user notice: $e');
      }
    }
  }

  // ─── Manajemen Pengguna oleh Admin ─────────────────────────────────────────
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    final idx = _users.indexWhere((u) => u['id'] == userId);
    if (idx == -1) return;

    _users[idx]['role'] = newRole.name;
    if (_currentUser?.id == userId) {
      _currentUser = _currentUser!.copyWith(role: newRole);
    }
    notifyListeners();

    final ref = _usersRef;
    if (ref != null) {
      try {
        await ref.doc(userId).set({'role': newRole.name}, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Failed to update user role in Firestore: $e');
      }
    }
  }

  Future<AuthResult> addManagedUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final exists = _users.any(
      (u) => u['email'].toString().toLowerCase() == cleanEmail,
    );
    if (exists) {
      return const AuthResult(
        success: false,
        message: 'Email sudah digunakan oleh akun lain.',
      );
    }

    final id = 'usr-${DateTime.now().millisecondsSinceEpoch}';
    final user = User(
      id: id,
      name: name.trim(),
      email: cleanEmail,
      phone: phone.trim(),
      role: role,
    );

    await _upsertLocalAndFirestoreUser(user, password: password);
    // Simpan password akun staf/lokal agar bisa dipakai login langsung dari perangkat lain
    final ref = _usersRef;
    if (ref != null) {
      try {
        await ref.doc(id).set(
          {...user.toMap(), 'password': password},
          SetOptions(merge: true),
        );
      } catch (_) {}
    }

    return AuthResult(
      success: true,
      message: 'Akun ${role.label} berhasil ditambahkan.',
      user: user,
    );
  }

  Future<bool> deleteManagedUser(String userId) async {
    if (_currentUser?.id == userId) return false;
    final before = _users.length;
    _users.removeWhere((u) => u['id'] == userId);
    if (_users.length == before) return false;
    notifyListeners();

    final ref = _usersRef;
    if (ref != null) {
      try {
        await ref.doc(userId).delete();
      } catch (e) {
        debugPrint('Failed to delete user from Firestore: $e');
      }
    }
    return true;
  }

  Future<void> updateCurrentUserAllergies(List<String> allergies) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(allergies: allergies);
    await _upsertLocalAndFirestoreUser(_currentUser!);
  }

  // ─── Login Email & Password ───────────────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // Sinkronkan perubahan akun/role terbaru dari Firestore terlebih dahulu
    await syncUsersFromFirestore();

    // 1. Cek akun bawaan 4 role / akun yang dibuat Admin
    final localMap = _users.firstWhere(
      (u) =>
          u['email'].toString().toLowerCase() == cleanEmail &&
          u['password'] != null &&
          u['password'] == password,
      orElse: () => {},
    );

    if (localMap.isNotEmpty) {
      // Pastikan sesi Firebase lama (misal Google) di-signOut bila berbeda akun
      try {
        final fbCurrent = _firebaseAuth?.currentUser;
        if (fbCurrent != null &&
            fbCurrent.email?.toLowerCase() != cleanEmail) {
          await _firebaseAuth?.signOut();
        }
      } catch (_) {}

      _currentUser = User.fromMap(localMap);
      notifyListeners();
      return AuthResult(
        success: true,
        message: 'Login berhasil sebagai ${_currentUser!.role.label}.',
        user: _currentUser,
      );
    }

    // 2. Cek Firebase Authentication
    final auth = _firebaseAuth;
    if (auth != null) {
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser != null) {
          _currentUser = await _resolveAndPersistFirebaseUser(
            uid: fbUser.uid,
            name: fbUser.displayName ??
                fbUser.email?.split('@').first ??
                'Pengguna',
            email: fbUser.email ?? cleanEmail,
            phone: fbUser.phoneNumber ?? '',
            photoUrl: fbUser.photoURL,
          );
          notifyListeners();
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

    return const AuthResult(
      success: false,
      message: 'Email atau password salah. Silakan coba lagi.',
    );
  }

  // ─── Register Akun Baru ────────────────────────────────────────────────────
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final auth = _firebaseAuth;
    if (auth != null) {
      try {
        final credential = await auth.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser != null) {
          await fbUser.updateDisplayName(name);
          final created = User(
            id: fbUser.uid,
            name: name.trim(),
            email: fbUser.email ?? cleanEmail,
            phone: phone.trim(),
            role: UserRole.user,
          );
          _currentUser = created;
          await _upsertLocalAndFirestoreUser(created);
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
      (u) => u['email'].toString().toLowerCase() == cleanEmail,
    );

    if (exists) {
      return const AuthResult(
        success: false,
        message: 'Email sudah terdaftar. Gunakan email lain.',
      );
    }

    final newUser = User(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: cleanEmail,
      phone: phone.trim(),
      role: UserRole.user,
    );
    await _upsertLocalAndFirestoreUser(newUser, password: password);
    _currentUser = newUser;

    return AuthResult(
      success: true,
      message: 'Akun berhasil dibuat. Silakan masuk.',
      user: _currentUser,
    );
  }

  // ─── Masuk dengan Google (Google Sign-In SDK 7.x) ──────────────────────────
  Future<AuthResult> signInWithGoogle() async {
    try {
      if (serverClientId.isEmpty && !_isFirebaseReady) {
        await Future.delayed(const Duration(milliseconds: 700));
        _currentUser = const User(
          id: 'google-demo-user',
          name: 'Pengguna Google Demo',
          email: 'google.demo@apotekkita.com',
          phone: '08123456789',
        );
        notifyListeners();
        return AuthResult(
          success: true,
          message: 'Berhasil masuk dengan Google (Mode Demo).',
          user: _currentUser,
        );
      }

      await _ensureGoogleSignInInitialized();

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

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
          _currentUser = await _resolveAndPersistFirebaseUser(
            uid: fbUser.uid,
            name: fbUser.displayName ??
                googleUser.displayName ??
                'Pengguna Google',
            email: fbUser.email ?? googleUser.email,
            phone: fbUser.phoneNumber ?? '',
            photoUrl: fbUser.photoURL ?? googleUser.photoUrl,
          );
          notifyListeners();

          return AuthResult(
            success: true,
            message: 'Berhasil masuk dengan akun Google.',
            user: _currentUser,
          );
        }
      }

      _currentUser = await _resolveAndPersistFirebaseUser(
        uid: googleUser.id,
        name: googleUser.displayName ?? 'Pengguna Google',
        email: googleUser.email,
        phone: '',
        photoUrl: googleUser.photoUrl,
      );
      notifyListeners();

      return AuthResult(
        success: true,
        message: 'Berhasil masuk dengan akun Google.',
        user: _currentUser,
      );
    } on GoogleSignInException catch (e) {
      debugPrint(
          'GoogleSignInException: code=${e.code}, description=${e.description}');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const AuthResult(
          success: false,
          message: 'Masuk dengan Google dibatalkan.',
        );
      }
      if (e.description?.contains('serverClientId') == true) {
        await Future.delayed(const Duration(milliseconds: 600));
        _currentUser = const User(
          id: 'google-demo-user',
          name: 'Pengguna Google Demo',
          email: 'google.demo@apotekkita.com',
          phone: '08123456789',
        );
        notifyListeners();
        return AuthResult(
          success: true,
          message:
              'Berhasil masuk (Mode Demo - isi serverClientId untuk akun Google asli).',
          user: _currentUser,
        );
      }
      return AuthResult(
        success: false,
        message: 'Google Sign-In gagal: ${e.description ?? e.code.name}',
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      debugPrint(
          'FirebaseAuthException (Google): code=${e.code}, message=${e.message}');
      return AuthResult(
        success: false,
        message: _mapFirebaseAuthError(e.code, e.message),
      );
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      if (kDebugMode &&
          (e.toString().contains('PlatformException') ||
              e.toString().contains('UnsupportedError'))) {
        await Future.delayed(const Duration(milliseconds: 600));
        _currentUser = const User(
          id: 'google-demo-user',
          name: 'Pengguna Google Demo',
          email: 'google.user@example.com',
          phone: '081298765432',
        );
        notifyListeners();
        return AuthResult(
          success: true,
          message: 'Berhasil masuk dengan akun Google (Demo Mode).',
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
          verificationCompleted:
              (fb_auth.PhoneAuthCredential credential) async {
            try {
              final userCredential =
                  await auth.signInWithCredential(credential);
              final fbUser = userCredential.user;
              if (fbUser != null) {
                final user = await _resolveAndPersistFirebaseUser(
                  uid: fbUser.uid,
                  name: fbUser.displayName ?? 'Pengguna Telepon',
                  email: fbUser.email ?? '',
                  phone: fbUser.phoneNumber ?? phoneNumber,
                );
                _currentUser = user;
                notifyListeners();
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
          _currentUser = await _resolveAndPersistFirebaseUser(
            uid: fbUser.uid,
            name: fbUser.displayName ?? 'Pengguna Telepon',
            email: fbUser.email ?? '',
            phone: fbUser.phoneNumber ?? phoneNumber ?? '',
          );
          notifyListeners();
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

    await Future.delayed(const Duration(milliseconds: 600));
    if (smsCode.trim().length == 6) {
      _currentUser = User(
        id: 'phone-user-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Pengguna ApoteKita',
        email: '',
        phone: phoneNumber ?? '081234567890',
      );
      notifyListeners();
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
          u['email'].toString().toLowerCase() ==
              _currentUser!.email.toLowerCase() &&
          u['password'] == oldPassword,
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
  void syncFromFirebaseUser(fb_auth.User fbUser) {
    final localMatch = _findLocalUserMapByIdOrEmail(
      id: fbUser.uid,
      email: fbUser.email,
    );
    final role = localMatch != null
        ? UserRoleExtension.fromString(localMatch['role']?.toString())
        : UserRole.user;
    final allergies = (localMatch != null && localMatch['allergies'] is List)
        ? List<String>.from(localMatch['allergies'])
        : const <String>[];

    _currentUser = User(
      id: fbUser.uid,
      name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'Pengguna',
      email: fbUser.email ?? '',
      phone: fbUser.phoneNumber ?? '',
      photoUrl: fbUser.photoURL,
      role: role,
      allergies: allergies,
    );

    // Sinkronkan role dari Firestore di latar belakang jika ada pembaruan Admin
    _resolveAndPersistFirebaseUser(
      uid: fbUser.uid,
      name: _currentUser!.name,
      email: _currentUser!.email,
      phone: _currentUser!.phone,
      photoUrl: _currentUser!.photoUrl,
    ).then((resolved) {
      if (_currentUser?.id == resolved.id &&
          _currentUser?.role != resolved.role) {
        _currentUser = resolved;
        notifyListeners();
      }
    });
  }

  // ─── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    try {
      await _firebaseAuth?.signOut();
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
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
