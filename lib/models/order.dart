import 'package:flutter/material.dart';
import '../app/theme.dart';
import 'cart_item.dart';

/// Metode pengambilan pesanan
enum PickupMethod {
  pickup, // Ambil di Apotek (Rp0)
  delivery, // Pengiriman ke Alamat (Rp10.000)
}

extension PickupMethodExtension on PickupMethod {
  String get label {
    switch (this) {
      case PickupMethod.pickup:
        return 'Ambil di Apotek';
      case PickupMethod.delivery:
        return 'Pengiriman ke Alamat';
    }
  }

  int get shippingCost {
    switch (this) {
      case PickupMethod.pickup:
        return 0;
      case PickupMethod.delivery:
        return 10000;
    }
  }

  String get description {
    switch (this) {
      case PickupMethod.pickup:
        return 'Pesanan dapat diambil di apotek setelah status pesanan siap diambil.';
      case PickupMethod.delivery:
        return 'Pesanan akan dikirim ke alamat pengguna oleh kurir ApoteKita.';
    }
  }

  IconData get icon {
    switch (this) {
      case PickupMethod.pickup:
        return Icons.storefront_rounded;
      case PickupMethod.delivery:
        return Icons.local_shipping_rounded;
    }
  }
}

/// Metode pembayaran
enum PaymentMethod {
  bankTransfer, // Transfer Bank (BCA)
  eWallet, // E-Wallet (GoPay / QRIS)
  payAtPharmacy, // Bayar di Apotek (Tunai/Kasir)
}

extension PaymentMethodExtension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.bankTransfer:
        return 'Transfer Bank';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
      case PaymentMethod.payAtPharmacy:
        return 'Bayar di Apotek';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.bankTransfer:
        return 'BCA (Virtual Account / Transfer)';
      case PaymentMethod.eWallet:
        return 'GoPay, OVO, DANA, ShopeePay';
      case PaymentMethod.payAtPharmacy:
        return 'Bayar tunai atau QRIS saat ambil pesanan';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_rounded;
      case PaymentMethod.eWallet:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethod.payAtPharmacy:
        return Icons.point_of_sale_rounded;
    }
  }
}

/// Status pembayaran
enum PaymentStatus {
  pending,
  paid,
  failed,
}

extension PaymentStatusExtension on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Menunggu Pembayaran';
      case PaymentStatus.paid:
        return 'Lunas';
      case PaymentStatus.failed:
        return 'Gagal';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return const Color(0xFFFF9800);
      case PaymentStatus.paid:
        return AppColors.green;
      case PaymentStatus.failed:
        return AppColors.error;
    }
  }
}

/// Status pesanan
enum OrderStatus {
  pending, // Menunggu pembayaran / konfirmasi
  processing, // Diproses oleh apotek
  ready, // Siap diambil (khusus pickup)
  shipping, // Sedang dikirim (khusus delivery)
  completed, // Pesanan selesai
  cancelled, // Pesanan dibatalkan
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Menunggu Pembayaran';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.ready:
        return 'Siap Diambil';
      case OrderStatus.shipping:
        return 'Sedang Dikirim';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFFF9800);
      case OrderStatus.processing:
        return AppColors.cyan;
      case OrderStatus.ready:
        return const Color(0xFF7B61FF);
      case OrderStatus.shipping:
        return const Color(0xFF2196F3);
      case OrderStatus.completed:
        return AppColors.green;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.pending_actions_rounded;
      case OrderStatus.processing:
        return Icons.autorenew_rounded;
      case OrderStatus.ready:
        return Icons.store_mall_directory_rounded;
      case OrderStatus.shipping:
        return Icons.local_shipping_rounded;
      case OrderStatus.completed:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}

/// Model Laporan Masalah Pesanan
class OrderProblemReport {
  final String category;
  final String description;
  final DateTime reportedAt;
  final String status;

  const OrderProblemReport({
    required this.category,
    required this.description,
    required this.reportedAt,
    this.status = 'Sedang Ditinjau',
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'description': description,
      'reportedAt': reportedAt.toIso8601String(),
      'status': status,
    };
  }

  factory OrderProblemReport.fromMap(Map<String, dynamic> map) {
    return OrderProblemReport(
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      reportedAt: map['reportedAt'] != null
          ? DateTime.tryParse(map['reportedAt']) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] ?? 'Sedang Ditinjau',
    );
  }
}

/// Model Pesanan (Order)
class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final int subtotal;
  final int shippingCost;
  final int total;
  final PickupMethod pickupMethod;
  final String? deliveryAddress;
  final PaymentMethod paymentMethod;
  PaymentStatus paymentStatus;
  OrderStatus orderStatus;
  final DateTime createdAt;
  OrderProblemReport? problemReport;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.pickupMethod,
    this.deliveryAddress,
    required this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.orderStatus = OrderStatus.pending,
    required this.createdAt,
    this.problemReport,
  });

  /// Total jumlah item obat
  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'total': total,
      'pickupMethod': pickupMethod.name,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'orderStatus': orderStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'problemReport': problemReport?.toMap(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      subtotal: (map['subtotal'] as num?)?.toInt() ?? 0,
      shippingCost: (map['shippingCost'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num?)?.toInt() ?? 0,
      pickupMethod: PickupMethod.values.firstWhere(
        (e) => e.name == map['pickupMethod'],
        orElse: () => PickupMethod.pickup,
      ),
      deliveryAddress: map['deliveryAddress'],
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.payAtPharmacy,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      orderStatus: OrderStatus.values.firstWhere(
        (e) => e.name == map['orderStatus'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      problemReport: map['problemReport'] != null
          ? OrderProblemReport.fromMap(
              Map<String, dynamic>.from(map['problemReport']))
          : null,
    );
  }

  Order copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    int? subtotal,
    int? shippingCost,
    int? total,
    PickupMethod? pickupMethod,
    String? deliveryAddress,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    OrderStatus? orderStatus,
    DateTime? createdAt,
    OrderProblemReport? problemReport,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      pickupMethod: pickupMethod ?? this.pickupMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt ?? this.createdAt,
      problemReport: problemReport ?? this.problemReport,
    );
  }
}
