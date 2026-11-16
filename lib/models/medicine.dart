/// Model obat ApoteKita.
/// Semua field disesuaikan agar mudah dimap dari REST API response.
class Medicine {
  final String id;
  final String name;
  final String category;
  final int price; // dalam Rupiah
  final int stock;
  final String imageIcon; // nama icon Material (gunakan IconData key)
  final String description;
  final String indication;
  final String ingredients;
  final String dosage;
  final String sideEffects;
  final String warning;
  final List<String> keywords; // untuk search
  final String genericName;
  final String unit;

  const Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageIcon,
    required this.description,
    required this.indication,
    required this.ingredients,
    required this.dosage,
    required this.sideEffects,
    required this.warning,
    this.keywords = const [],
    this.genericName = '',
    this.unit = 'Strip / Botol',
  });

  String get displayGenericName =>
      genericName.isNotEmpty ? genericName : ingredients;

  bool get isAvailable => stock > 0;

  String get formattedPrice {
    // Format harga ke "Rp X.XXX"
    final s = price.toString();
    final buffer = StringBuffer('Rp ');
    final len = s.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  /// Factory dari Map — untuk nanti koneksi REST API
  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      imageIcon: map['imageIcon'] ?? 'medication',
      description: map['description'] ?? '',
      indication: map['indication'] ?? '',
      ingredients: map['ingredients'] ?? '',
      dosage: map['dosage'] ?? '',
      sideEffects: map['sideEffects'] ?? '',
      warning: map['warning'] ?? '',
      keywords: List<String>.from(map['keywords'] ?? []),
      genericName: map['genericName'] ?? '',
      unit: map['unit'] ?? 'Strip / Botol',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'imageIcon': imageIcon,
      'description': description,
      'indication': indication,
      'ingredients': ingredients,
      'dosage': dosage,
      'sideEffects': sideEffects,
      'warning': warning,
      'keywords': keywords,
      'genericName': genericName,
      'unit': unit,
    };
  }
}

// ─── Kategori obat yang tersedia ──────────────────────────────────────────────
class MedicineCategory {
  static const String all = 'Semua';
  static const String obatBebas = 'Obat Bebas';
  static const String obatBebasTerbatas = 'Obat Bebas Terbatas';
  static const String vitamin = 'Vitamin';
  static const String suplemen = 'Suplemen';
  static const String obatBatuk = 'Obat Batuk';
  static const String obatFlu = 'Obat Flu';
  static const String obatDemam = 'Obat Demam';
  static const String obatPencernaan = 'Obat Pencernaan';
  static const String perawatanKulit = 'Perawatan Kulit';

  static const List<String> allCategories = [
    all,
    obatBebas,
    obatBebasTerbatas,
    vitamin,
    suplemen,
    obatBatuk,
    obatFlu,
    obatDemam,
    obatPencernaan,
    perawatanKulit,
  ];
}
