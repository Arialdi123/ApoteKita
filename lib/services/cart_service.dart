import 'package:flutter/foundation.dart';
import '../models/medicine.dart';
import '../models/cart_item.dart';

/// Hasil operasi penambahan / modifikasi keranjang
class CartResult {
  final bool success;
  final String message;

  const CartResult({required this.success, required this.message});
}

/// Service pengelola Keranjang Belanja (in-memory state dengan ChangeNotifier)
class CartService extends ChangeNotifier {
  // Singleton pattern
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  /// Daftar item di keranjang (unmodifiable list view)
  List<CartItem> get items => List.unmodifiable(_items);

  /// Jumlah seluruh unit item di keranjang
  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal harga semua item
  int get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  /// Cek apakah keranjang kosong
  bool get isEmpty => _items.isEmpty;

  /// Cek apakah keranjang berisi obat
  bool get isNotEmpty => _items.isNotEmpty;

  /// Dapatkan quantity obat tertentu di keranjang saat ini
  int getItemQuantity(String medicineId) {
    try {
      final existing = _items.firstWhere((item) => item.medicineId == medicineId);
      return existing.quantity;
    } catch (_) {
      return 0;
    }
  }

  /// Tambah obat ke keranjang
  CartResult addToCart(Medicine medicine, {int quantity = 1}) {
    if (medicine.stock <= 0) {
      return const CartResult(
        success: false,
        message: 'Stok obat habis dan tidak dapat ditambahkan.',
      );
    }

    final existingIndex = _items.indexWhere((item) => item.medicineId == medicine.id);

    if (existingIndex != -1) {
      final existingItem = _items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      if (newQuantity > medicine.stock) {
        return const CartResult(
          success: false,
          message: 'Jumlah melebihi stok yang tersedia.',
        );
      }

      existingItem.quantity = newQuantity;
      notifyListeners();
      return const CartResult(
        success: true,
        message: 'Obat berhasil ditambahkan ke keranjang.',
      );
    } else {
      if (quantity > medicine.stock) {
        return const CartResult(
          success: false,
          message: 'Jumlah melebihi stok yang tersedia.',
        );
      }

      _items.add(CartItem.fromMedicine(medicine, quantity: quantity));
      notifyListeners();
      return const CartResult(
        success: true,
        message: 'Obat berhasil ditambahkan ke keranjang.',
      );
    }
  }

  /// Perbarui quantity item di keranjang
  CartResult updateQuantity(String medicineId, int newQuantity) {
    final index = _items.indexWhere((item) => item.medicineId == medicineId);
    if (index == -1) {
      return const CartResult(
        success: false,
        message: 'Obat tidak ditemukan di keranjang.',
      );
    }

    final item = _items[index];

    if (newQuantity <= 0) {
      return const CartResult(
        success: false,
        message: 'Jumlah minimal adalah 1. Gunakan tombol hapus untuk membuang.',
      );
    }

    if (newQuantity > item.stock) {
      return const CartResult(
        success: false,
        message: 'Jumlah melebihi stok yang tersedia.',
      );
    }

    item.quantity = newQuantity;
    notifyListeners();
    return const CartResult(
      success: true,
      message: 'Jumlah berhasil diperbarui.',
    );
  }

  /// Hapus satu item dari keranjang
  void removeFromCart(String medicineId) {
    _items.removeWhere((item) => item.medicineId == medicineId);
    notifyListeners();
  }

  /// Kosongkan seluruh keranjang
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
