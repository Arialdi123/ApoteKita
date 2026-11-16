import 'medicine.dart';

/// Model untuk item di dalam keranjang belanja
class CartItem {
  final String medicineId;
  final String medicineName;
  final String genericName;
  final int price;
  final String imageIcon;
  final String unit;
  final int stock;
  int quantity;

  CartItem({
    required this.medicineId,
    required this.medicineName,
    required this.genericName,
    required this.price,
    required this.imageIcon,
    required this.unit,
    required this.stock,
    this.quantity = 1,
  });

  /// Total harga untuk item ini (harga x quantity)
  int get subtotal => price * quantity;

  /// Factory untuk membuat CartItem dari Medicine
  factory CartItem.fromMedicine(Medicine medicine, {int quantity = 1}) {
    return CartItem(
      medicineId: medicine.id,
      medicineName: medicine.name,
      genericName: medicine.genericName,
      price: medicine.price,
      imageIcon: medicine.imageIcon,
      unit: medicine.unit,
      stock: medicine.stock,
      quantity: quantity,
    );
  }

  /// Factory dari Map (simulasi persistence)
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      genericName: map['genericName'] ?? '',
      price: map['price'] ?? 0,
      imageIcon: map['imageIcon'] ?? 'pill',
      unit: map['unit'] ?? 'Strip',
      stock: map['stock'] ?? 0,
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'genericName': genericName,
      'price': price,
      'imageIcon': imageIcon,
      'unit': unit,
      'stock': stock,
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    String? medicineId,
    String? medicineName,
    String? genericName,
    int? price,
    String? imageIcon,
    String? unit,
    int? stock,
    int? quantity,
  }) {
    return CartItem(
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      genericName: genericName ?? this.genericName,
      price: price ?? this.price,
      imageIcon: imageIcon ?? this.imageIcon,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      quantity: quantity ?? this.quantity,
    );
  }
}
