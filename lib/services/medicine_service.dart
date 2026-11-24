import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine.dart';
import '../data/medicine_data.dart';

/// Service untuk mengakses data obat dari Cloud Firestore.
/// Dilengkapi fallback ke dummy data jika offline atau koleksi di Firestore masih kosong.
class MedicineService {
  // ─── Singleton ───────────────────────────────────────────────────────────────
  static final MedicineService _instance = MedicineService._internal();
  factory MedicineService() => _instance;
  MedicineService._internal();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _medicinesRef =>
      _firestore.collection('medicines');

  // ─── Get All Medicines ────────────────────────────────────────────────────────
  /// Mengambil semua daftar obat dari Cloud Firestore.
  /// Jika koleksi kosong atau offline, otomatis menggunakan dummyMedicines.
  Future<List<Medicine>> getMedicines() async {
    try {
      final snapshot = await _medicinesRef.get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Medicine.fromMap(data);
        }).toList();
      }
    } catch (e) {
      debugPrint('Firestore getMedicines error (using fallback): $e');
    }
    return List.from(dummyMedicines);
  }

  // ─── Get Medicine Stream (Realtime) ──────────────────────────────────────────
  /// Mengambil stream daftar obat untuk update UI secara realtime.
  Stream<List<Medicine>> getMedicinesStream() {
    return _medicinesRef.snapshots().map<List<Medicine>>((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Medicine.fromMap(data);
        }).toList();
      }
      return List<Medicine>.from(dummyMedicines);
    }).handleError((error) {
      debugPrint('Firestore getMedicinesStream error: $error');
      return <Medicine>[];
    });
  }

  // ─── Get Medicine by ID ───────────────────────────────────────────────────────
  Future<Medicine?> getMedicineById(String id) async {
    try {
      final doc = await _medicinesRef.doc(id).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Medicine.fromMap(data);
      }
    } catch (e) {
      debugPrint('Firestore getMedicineById error: $e');
    }

    try {
      return dummyMedicines.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Search Medicines ─────────────────────────────────────────────────────────
  /// Mencari obat berdasarkan nama, kategori, atau keywords.
  Future<List<Medicine>> searchMedicines(String query) async {
    final all = await getMedicines();
    if (query.trim().isEmpty) return all;

    final q = query.trim().toLowerCase();
    return all.where((m) {
      return m.name.toLowerCase().contains(q) ||
          m.keywords.any((kw) => kw.toLowerCase().contains(q)) ||
          m.category.toLowerCase().contains(q);
    }).toList();
  }

  // ─── Filter by Category ───────────────────────────────────────────────────────
  Future<List<Medicine>> filterByCategory(String category) async {
    if (category == MedicineCategory.all) return getMedicines();

    try {
      final snapshot =
          await _medicinesRef.where('category', isEqualTo: category).get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Medicine.fromMap(data);
        }).toList();
      }
    } catch (e) {
      debugPrint('Firestore filterByCategory error: $e');
    }

    return dummyMedicines.where((m) => m.category == category).toList();
  }

  // ─── Search + Filter Combined ─────────────────────────────────────────────────
  /// Gabungkan pencarian dan filter kategori secara in-memory.
  List<Medicine> searchAndFilter({
    required List<Medicine> source,
    required String query,
    required String category,
  }) {
    var result = source;

    // Filter kategori
    if (category != MedicineCategory.all) {
      result = result.where((m) => m.category == category).toList();
    }

    // Filter pencarian
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((m) {
        return m.name.toLowerCase().contains(q) ||
            m.keywords.any((kw) => kw.toLowerCase().contains(q)) ||
            m.category.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  // ─── Get Popular Medicines ────────────────────────────────────────────────────
  /// Mengambil obat populer untuk ditampilkan di Home.
  Future<List<Medicine>> getPopularMedicines({int limit = 4}) async {
    try {
      final snapshot = await _medicinesRef
          .where('stock', isGreaterThan: 50)
          .limit(limit)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Medicine.fromMap(data);
        }).toList();
      }
    } catch (e) {
      debugPrint('Firestore getPopularMedicines error: $e');
    }

    final popular =
        dummyMedicines.where((m) => m.stock > 50).take(limit).toList();
    return popular;
  }

  // ─── Get Medicines by Category ───────────────────────────────────────────────
  Future<List<Medicine>> getMedicinesByCategory(String category,
      {int limit = 4}) async {
    if (category == MedicineCategory.all) {
      final all = await getMedicines();
      return all.take(limit).toList();
    }

    try {
      final snapshot = await _medicinesRef
          .where('category', isEqualTo: category)
          .limit(limit)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Medicine.fromMap(data);
        }).toList();
      }
    } catch (e) {
      debugPrint('Firestore getMedicinesByCategory error: $e');
    }

    return dummyMedicines
        .where((m) => m.category == category)
        .take(limit)
        .toList();
  }

  // ─── Database Seeder (Upload Data Dummy ke Firestore) ────────────────────────
  /// Mengunggah semua data dari dummyMedicines ke Cloud Firestore.
  /// Berguna agar database kelompok langsung terisi otomatis.
  Future<void> seedMedicinesToFirestore({bool overwrite = false}) async {
    try {
      final batch = _firestore.batch();
      for (final med in dummyMedicines) {
        final docRef = _medicinesRef.doc(med.id);
        if (overwrite) {
          batch.set(docRef, med.toMap());
        } else {
          batch.set(docRef, med.toMap(), SetOptions(merge: true));
        }
      }
      await batch.commit();
      debugPrint('✅ Berhasil seeding ${dummyMedicines.length} obat ke Firestore!');
    } catch (e) {
      debugPrint('❌ Gagal seeding obat ke Firestore: $e');
      rethrow;
    }
  }

  /// Cek apakah Firestore masih kosong, jika kosong otomatis seeding sekali.
  Future<void> seedIfEmpty() async {
    try {
      final snapshot = await _medicinesRef.limit(1).get();
      if (snapshot.docs.isEmpty) {
        debugPrint('Koleksi medicines kosong di Firestore, memulai seeding...');
        await seedMedicinesToFirestore();
      }
    } catch (e) {
      debugPrint('seedIfEmpty check skipped: $e');
    }
  }
}
