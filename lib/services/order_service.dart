import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../data/order_data.dart';

/// Service pengelola Pesanan dan Transaksi (in-memory state dengan ChangeNotifier)
class OrderService extends ChangeNotifier {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;

  final List<Order> _orders = [];
  int _orderCounter = 4;

  OrderService._internal() {
    _orders.addAll(initialDummyOrders);
  }

  /// Daftar semua pesanan
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

  /// Buat pesanan baru
  Order createOrder({
    required String userId,
    required List<CartItem> items,
    required PickupMethod pickupMethod,
    required PaymentMethod paymentMethod,
    String? deliveryAddress,
  }) {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final id = 'ORD-$dateStr-${_orderCounter.toString().padLeft(3, '0')}';
    _orderCounter++;

    final subtotal = items.fold(0, (sum, item) => sum + item.subtotal);
    final shippingCost = pickupMethod.shippingCost;
    final total = subtotal + shippingCost;

    // Default payment status
    final PaymentStatus initialPaymentStatus = (paymentMethod == PaymentMethod.payAtPharmacy)
        ? PaymentStatus.pending
        : PaymentStatus.pending;

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
    return newOrder;
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
    return true;
  }

  /// Update status pesanan
  bool updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    _orders[index].orderStatus = status;
    notifyListeners();
    return true;
  }

  /// Konfirmasi pesanan telah diterima pengguna
  bool confirmReceived(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    _orders[index].orderStatus = OrderStatus.completed;
    // Jika bayar di apotek, saat selesai tandai juga sebagai lunas
    if (_orders[index].paymentMethod == PaymentMethod.payAtPharmacy) {
      _orders[index].paymentStatus = PaymentStatus.paid;
    }

    notifyListeners();
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
    return true;
  }

  /// Laporkan masalah pesanan
  bool reportProblem(String orderId, {
    required String category,
    required String description,
  }) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    _orders[index].problemReport = OrderProblemReport(
      category: category,
      description: description,
      reportedAt: DateTime.now(),
    );

    notifyListeners();
    return true;
  }
}
