import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';
import '../models/cart_item.dart';
import '../data/order_data.dart';

/// Service pengelola Pesanan dan Transaksi.
/// Terhubung langsung dengan Cloud Firestore (koleksi 'orders') dengan fallback in-memory state.
class OrderService extends ChangeNotifier {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;

  final List<Order> _orders = [];
  int _orderCounter = 4;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection('orders');

  OrderService._internal() {
    // Mulai dengan data awal sebagai fallback
    _orders.addAll(initialDummyOrders);
    // Sinkronkan data dari Firestore di latar belakang
    initFirestoreSync();
  }

  /// Sinkronkan pesanan dari Cloud Firestore
  Future<void> initFirestoreSync({String? userId}) async {
    try {
      Query<Map<String, dynamic>> query = _ordersRef;
      if (userId != null && userId.isNotEmpty) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        final firestoreOrders = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Order.fromMap(data);
        }).toList();

        // Gabungkan dan hindari duplikasi ID
        for (final remoteOrder in firestoreOrders) {
          final existingIndex =
              _orders.indexWhere((o) => o.id == remoteOrder.id);
          if (existingIndex != -1) {
            _orders[existingIndex] = remoteOrder;
          } else {
            _orders.add(remoteOrder);
          }
        }

        // Urutkan pesanan dari yang paling baru
        _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Firestore initFirestoreSync notice: $e');
    }
  }

  /// Daftar semua pesanan (unmodifiable list view)
  List<Order> get orders => List.unmodifiable(_orders);

  /// Dapatkan daftar pesanan dengan filter status opsional
  List<Order> getOrders({String? userId, OrderStatus? statusFilter}) {
    return _orders.where((order) {
      if (userId != null && order.userId != userId) return false;
      if (statusFilter != null && order.orderStatus != statusFilter) return false;
      return true;
    }).toList();
  }

  /// Dapatkan pesanan berdasarkan ID
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (_) {
      return null;
    }
  }

  /// Buat pesanan baru dan simpan ke Cloud Firestore
  Order createOrder({
    required String userId,
    required List<CartItem> items,
    required PickupMethod pickupMethod,
    required PaymentMethod paymentMethod,
    String? deliveryAddress,
  }) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final id = 'ORD-$dateStr-${_orderCounter.toString().padLeft(3, '0')}';
    _orderCounter++;

    final subtotal = items.fold(0, (totalSum, item) => totalSum + item.subtotal);
    final shippingCost = pickupMethod.shippingCost;
    final total = subtotal + shippingCost;

    final PaymentStatus initialPaymentStatus = PaymentStatus.pending;

    final newOrder = Order(
      id: id,
      userId: userId,
      items: items.map((item) => item.copyWith()).toList(),
      subtotal: subtotal,
      shippingCost: shippingCost,
      total: total,
      pickupMethod: pickupMethod,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      paymentStatus: initialPaymentStatus,
      orderStatus: (paymentMethod == PaymentMethod.payAtPharmacy)
          ? OrderStatus.processing
          : OrderStatus.pending,
      createdAt: now,
    );

    // Insert di awal list agar pesanan terbaru ada di paling atas
    _orders.insert(0, newOrder);
    notifyListeners();

    // Simpan ke Cloud Firestore di latar belakang
    _saveOrderToFirestore(newOrder);

    return newOrder;
  }

  /// Menyimpan pesanan ke Cloud Firestore
  Future<void> _saveOrderToFirestore(Order order) async {
    try {
      await _ordersRef.doc(order.id).set(order.toMap(), SetOptions(merge: true));
      debugPrint('✅ Pesanan ${order.id} berhasil disimpan ke Cloud Firestore!');
    } catch (e) {
      debugPrint('⚠️ Gagal menyimpan pesanan ke Cloud Firestore: $e');
    }
  }

  /// Update status pembayaran
  bool updatePaymentStatus(String orderId, PaymentStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    final order = _orders[index];
    order.paymentStatus = status;

    // Jika pembayaran lunas dan status masih pending, ubah status pesanan ke processing
    if (status == PaymentStatus.paid && order.orderStatus == OrderStatus.pending) {
      order.orderStatus = OrderStatus.processing;
    }

    notifyListeners();

    // Perbarui ke Firestore
    _updateFirestore(orderId, {
      'paymentStatus': order.paymentStatus.name,
      'orderStatus': order.orderStatus.name,
    });

    return true;
  }

  /// Update status pesanan
  bool updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    _orders[index].orderStatus = status;
    notifyListeners();

    // Perbarui ke Firestore
    _updateFirestore(orderId, {
      'orderStatus': status.name,
    });

    return true;
  }

  /// Konfirmasi pesanan telah diterima pengguna
  bool confirmReceived(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    final order = _orders[index];
    order.orderStatus = OrderStatus.completed;
    if (order.paymentMethod == PaymentMethod.payAtPharmacy) {
      order.paymentStatus = PaymentStatus.paid;
    }

    notifyListeners();

    // Perbarui ke Firestore
    _updateFirestore(orderId, {
      'orderStatus': order.orderStatus.name,
      'paymentStatus': order.paymentStatus.name,
    });

    return true;
  }

  /// Batalkan pesanan
  bool cancelOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    final order = _orders[index];
    if (order.orderStatus == OrderStatus.completed) {
      return false; // Pesanan selesai tidak dapat dibatalkan
    }

    order.orderStatus = OrderStatus.cancelled;
    notifyListeners();

    // Perbarui ke Firestore
    _updateFirestore(orderId, {
      'orderStatus': OrderStatus.cancelled.name,
    });

    return true;
  }

  /// Laporkan masalah pesanan
  bool reportProblem(
    String orderId, {
    required String category,
    required String description,
  }) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    final report = OrderProblemReport(
      category: category,
      description: description,
      reportedAt: DateTime.now(),
    );

    _orders[index].problemReport = report;
    notifyListeners();

    // Perbarui ke Firestore
    _updateFirestore(orderId, {
      'problemReport': report.toMap(),
    });

    return true;
  }

  /// Helper untuk mengupdate dokumen di Cloud Firestore
  Future<void> _updateFirestore(String orderId, Map<String, dynamic> data) async {
    try {
      await _ordersRef.doc(orderId).update(data);
      debugPrint('✅ Dokumen $orderId berhasil diupdate di Firestore!');
    } catch (e) {
      debugPrint('⚠️ Gagal update Firestore untuk $orderId: $e');
    }
  }
}
