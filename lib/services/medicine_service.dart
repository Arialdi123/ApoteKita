import '../models/medicine.dart';
import '../data/medicine_data.dart';

/// Service untuk mengakses data obat.
/// Menggunakan dummy data sekarang — mudah diganti dengan HTTP/API nanti.
class MedicineService {
  // ─── Singleton ───────────────────────────────────────────────────────────────
  static final MedicineService _instance = MedicineService._internal();
  factory MedicineService() => _instance;
  MedicineService._internal();

  // ─── Get All Medicines ────────────────────────────────────────────────────────
  /// Mengambil semua daftar obat.
  /// Kembalikan Future agar mudah diganti dengan HTTP call.
  Future<List<Medicine>> getMedicines() async {
    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(dummyMedicines);
  }

  // ─── Get Medicine by ID ───────────────────────────────────────────────────────
  Future<Medicine?> getMedicineById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return dummyMedicines.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Search Medicines ─────────────────────────────────────────────────────────
  /// Mencari obat berdasarkan nama atau keywords.
  Future<List<Medicine>> searchMedicines(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (query.trim().isEmpty) return List.from(dummyMedicines);

    final q = query.trim().toLowerCase();
    return dummyMedicines.where((m) {
      return m.name.toLowerCase().contains(q) ||
          m.keywords.any((kw) => kw.toLowerCase().contains(q)) ||
          m.category.toLowerCase().contains(q);
    }).toList();
  }

  // ─── Filter by Category ───────────────────────────────────────────────────────
  Future<List<Medicine>> filterByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (category == MedicineCategory.all) return List.from(dummyMedicines);
    return dummyMedicines.where((m) => m.category == category).toList();
  }

  // ─── Search + Filter Combined ─────────────────────────────────────────────────
  /// Gabungkan pencarian dan filter kategori.
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
  /// Mengambil beberapa obat "populer" untuk ditampilkan di Home.
  Future<List<Medicine>> getPopularMedicines({int limit = 4}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simulasi: ambil obat yang stoknya > 50 (populer = banyak dibeli)
    final popular = dummyMedicines.where((m) => m.stock > 50).take(limit).toList();
    return popular;
  }

  // ─── Get Medicines by Category ───────────────────────────────────────────────
  Future<List<Medicine>> getMedicinesByCategory(String category, {int limit = 4}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (category == MedicineCategory.all) {
      return dummyMedicines.take(limit).toList();
    }
    return dummyMedicines
        .where((m) => m.category == category)
        .take(limit)
        .toList();
  }
}
