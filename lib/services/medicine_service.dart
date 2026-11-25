import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine.dart';
import '../models/cart_item.dart';
import '../data/medicine_data.dart';

/// Service untuk mengakses & mengelola data obat dari Cloud Firestore.
/// Mendukung CRUD real-time (Admin, Apoteker, Pegawai) dan otomatis sinkron ke Katalog Pengguna.
class MedicineService extends ChangeNotifier {
  // ─── Singleton ───────────────────────────────────────────────────────────────
  static final MedicineService _instance = MedicineService._internal();
  factory MedicineService() => _instance;

  final List<Medicine> _medicines = List<Medicine>.from(dummyMedicines);

  MedicineService._internal() {
    initFirestoreSync();
  }

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _medicinesRef =>
      _firestore.collection('medicines');

  /// Daftar obat di memori yang selalu sinkron untuk UI reaktif
  List<Medicine> get medicinesList => List.unmodifiable(_medicines);

  /// Obat dengan stok menipis (<= 20)
  List<Medicine> get lowStockMedicines =>
      _medicines.where((m) => m.stock <= 20).toList();

  Future<void> initFirestoreSync() async {
    try {
      final snapshot = await _medicinesRef.get();
      if (snapshot.docs.isNotEmpty) {
        final loaded = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Medicine.fromMap(data);
        }).toList();
        _medicines
          ..clear()
          ..addAll(loaded);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('MedicineService initFirestoreSync notice: $e');
    }
  }

  // ─── Get All Medicines ────────────────────────────────────────────────────────
  Future<List<Medicine>> getMedicines() async {
    try {
      final snapshot = await _medicinesRef.get();
      if (snapshot.docs.isNotEmpty) {
        final loaded = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Medicine.fromMap(data);
        }).toList();
        _medicines
          ..clear()
          ..addAll(loaded);
        return List.unmodifiable(_medicines);
      }
    } catch (e) {
      debugPrint('Firestore getMedicines error (using in-memory): $e');
    }
    return List.unmodifiable(_medicines);
  }

  // ─── Get Medicine Stream (Realtime) ──────────────────────────────────────────
  Stream<List<Medicine>> getMedicinesStream() {
    return _medicinesRef.snapshots().map<List<Medicine>>((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final loaded = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Medicine.fromMap(data);
        }).toList();
        _medicines
          ..clear()
          ..addAll(loaded);
        return List<Medicine>.from(_medicines);
      }
      return List<Medicine>.from(_medicines);
    }).handleError((error) {
      debugPrint('Firestore getMedicinesStream error: $error');
      return List<Medicine>.from(_medicines);
    });
  }

  // ─── Get Medicine by ID ───────────────────────────────────────────────────────
  Future<Medicine?> getMedicineById(String id) async {
    try {
      final local = _medicines.firstWhere((m) => m.id == id);
      return local;
    } catch (_) {}

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
    return null;
  }

  Medicine? getMedicineByIdSync(String id) {
    try {
      return _medicines.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── CRUD & Manajemen Stok (Admin / Apoteker / Pegawai / Checkout) ──────────
  Future<Medicine> addMedicine(Medicine medicine) async {
    final newId = medicine.id.isNotEmpty
        ? medicine.id
        : 'med-${DateTime.now().millisecondsSinceEpoch}';
    final toSave = Medicine.fromMap({
      ...medicine.toMap(),
      'id': newId,
    });

    _medicines.insert(0, toSave);
    notifyListeners();

    try {
      await _medicinesRef.doc(newId).set(toSave.toMap());
    } catch (e) {
      debugPrint('Firestore addMedicine error: $e');
    }
    return toSave;
  }

  Future<void> updateMedicine(Medicine updated) async {
    final idx = _medicines.indexWhere((m) => m.id == updated.id);
    if (idx != -1) {
      _medicines[idx] = updated;
    } else {
      _medicines.insert(0, updated);
    }
    notifyListeners();

    try {
      await _medicinesRef
          .doc(updated.id)
          .set(updated.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore updateMedicine error: $e');
    }
  }

  Future<void> updateStock(String medicineId, int newStock) async {
    final safeStock = newStock < 0 ? 0 : newStock;
    final idx = _medicines.indexWhere((m) => m.id == medicineId);
    if (idx == -1) return;

    final current = _medicines[idx];
    final updated = Medicine.fromMap({
      ...current.toMap(),
      'stock': safeStock,
    });
    _medicines[idx] = updated;
    notifyListeners();

    try {
      await _medicinesRef.doc(medicineId).update({'stock': safeStock});
    } catch (e) {
      debugPrint('Firestore updateStock error: $e');
    }
  }

  Future<void> reduceStockForOrder(List<CartItem> items) async {
    bool changed = false;
    for (final cartItem in items) {
      final idx = _medicines.indexWhere((m) => m.id == cartItem.medicineId);
      if (idx != -1) {
        final current = _medicines[idx];
        final newStock =
            (current.stock - cartItem.quantity).clamp(0, 999999);
        _medicines[idx] = Medicine.fromMap({
          ...current.toMap(),
          'stock': newStock,
        });
        changed = true;

        try {
          await _medicinesRef
              .doc(cartItem.medicineId)
              .update({'stock': newStock});
        } catch (e) {
          debugPrint('Firestore reduceStock error: $e');
        }
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  Future<void> deleteMedicine(String medicineId) async {
    _medicines.removeWhere((m) => m.id == medicineId);
    notifyListeners();

    try {
      await _medicinesRef.doc(medicineId).delete();
    } catch (e) {
      debugPrint('Firestore deleteMedicine error: $e');
    }
  }

  // ─── Search Medicines ─────────────────────────────────────────────────────────
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

    return _medicines.where((m) => m.category == category).toList();
  }

  // ─── Search + Filter Combined ─────────────────────────────────────────────────
  List<Medicine> searchAndFilter({
    required List<Medicine> source,
    required String query,
    required String category,
  }) {
    var result = source;

    if (category != MedicineCategory.all) {
      result = result.where((m) => m.category == category).toList();
    }

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
  Future<List<Medicine>> getPopularMedicines({int limit = 4}) async {
    if (_medicines.isEmpty) {
      await getMedicines();
    }
    final popular = _medicines.where((m) => m.stock > 0).take(limit).toList();
    return popular;
  }

  // ─── Get Medicines by Category ───────────────────────────────────────────────
  Future<List<Medicine>> getMedicinesByCategory(
    String category, {
    int limit = 4,
  }) async {
    if (category == MedicineCategory.all) {
      return _medicines.take(limit).toList();
    }
    return _medicines
        .where((m) => m.category == category)
        .take(limit)
        .toList();
  }

  // ─── Database Seeder (Upload Data Dummy ke Firestore) ────────────────────────
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
      debugPrint(
          '✅ Berhasil seeding ${dummyMedicines.length} obat ke Firestore!');
    } catch (e) {
      debugPrint('❌ Gagal seeding obat ke Firestore: $e');
      rethrow;
    }
  }

  Future<void> seedIfEmpty() async {
    try {
      final snapshot = await _medicinesRef.limit(1).get();
      if (snapshot.docs.isEmpty) {
        debugPrint(
            'Koleksi medicines kosong di Firestore, memulai seeding...');
        await seedMedicinesToFirestore();
      } else {
        await initFirestoreSync();
      }
    } catch (e) {
      debugPrint('seedIfEmpty check skipped: $e');
    }
  }
}
