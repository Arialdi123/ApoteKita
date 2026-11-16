import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../models/medicine.dart';
import '../../services/medicine_service.dart';
import '../../services/cart_service.dart';
import '../../widgets/order_widgets.dart';

/// Halaman detail informasi obat.
/// Menerima medicine ID via route arguments.
class MedicineDetailScreen extends StatefulWidget {
  final String? medicineId;

  const MedicineDetailScreen({
    super.key,
    this.medicineId,
  });

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  Medicine? _medicine;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_medicine == null && _isLoading) {
      _loadMedicine();
    }
  }

  Future<void> _loadMedicine() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    final id = widget.medicineId ?? (args is String ? args : null);

    if (id == null || id.isEmpty) {
      setState(() {
        _errorMessage = 'ID obat tidak valid.';
        _isLoading = false;
      });
      return;
    }

    final medicine = await MedicineService().getMedicineById(id);

    if (!mounted) return;

    setState(() {
      _medicine = medicine;
      _isLoading = false;
      if (medicine == null) {
        _errorMessage = 'Obat tidak ditemukan.';
      }
    });
  }

  void _handleAddToCart() {
    if (_medicine == null) return;

    final result = CartService().addToCart(_medicine!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              result.success
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                result.message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: result.success ? AppColors.green : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleBuyNow() {
    if (_medicine == null) return;

    if (_medicine!.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Stok obat habis.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Jika belum ada di keranjang, tambahkan
    if (CartService().getItemQuantity(_medicine!.id) == 0) {
      CartService().addToCart(_medicine!);
    }

    Navigator.of(context).pushNamed(AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.green),
        ),
      );
    }

    if (_errorMessage != null || _medicine == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(_errorMessage ?? 'Obat tidak ditemukan.'),
        ),
      );
    }

    final hasStock = _medicine!.stock > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar dengan gambar/icon ────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 16, color: AppColors.textPrimary),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const CartBadgeIcon(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _resolveIcon(_medicine!.imageIcon),
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header info ──────────────────────────────────────────
                  _buildHeader(),

                  const SizedBox(height: 20),

                  // ── Deskripsi ────────────────────────────────────────────
                  _buildInfoCard(
                    icon: Icons.info_outline_rounded,
                    title: 'Deskripsi',
                    content: _medicine!.description,
                    color: AppColors.cyan,
                  ),

                  const SizedBox(height: 12),

                  // ── Indikasi ─────────────────────────────────────────────
                  _buildInfoCard(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Indikasi',
                    content: _medicine!.indication,
                    color: AppColors.green,
                  ),

                  const SizedBox(height: 12),

                  // ── Kandungan ────────────────────────────────────────────
                  _buildInfoCard(
                    icon: Icons.science_outlined,
                    title: 'Kandungan',
                    content: _medicine!.ingredients,
                    color: const Color(0xFF7B61FF),
                  ),

                  const SizedBox(height: 12),

                  // ── Aturan Pakai ─────────────────────────────────────────
                  _buildInfoCard(
                    icon: Icons.schedule_rounded,
                    title: 'Aturan Penggunaan',
                    content: _medicine!.dosage,
                    color: AppColors.cyan,
                  ),

                  const SizedBox(height: 12),

                  // ── Efek Samping ─────────────────────────────────────────
                  _buildInfoCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Efek Samping',
                    content: _medicine!.sideEffects,
                    color: const Color(0xFFFF9800),
                  ),

                  const SizedBox(height: 12),

                  // ── Peringatan ───────────────────────────────────────────
                  _buildWarningCard(),

                  const SizedBox(height: 24),

                  // ── Disclaimer ────────────────────────────────────────────
                  _buildDisclaimer(),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Action Bar: Tambah ke Keranjang & Beli Sekarang ───────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: hasStock
            ? Row(
                children: [
                  // Tombol Tambah ke Keranjang
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: _handleAddToCart,
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                      label: const Text('Keranjang'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.green,
                        side: const BorderSide(color: AppColors.green, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tombol Beli Sekarang
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _handleBuyNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Beli Sekarang'),
                    ),
                  ),
                ],
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text(
                      'Stok Obat Habis',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    final med = _medicine!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.green.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            med.category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.green,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Nama obat
        Text(
          med.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),

        // Nama generik
        Text(
          med.genericName,
          style: const TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Harga + Stok
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harga',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  med.formattedPrice,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
                Text(
                  'per ${med.unit}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: med.stock > 0
                    ? AppColors.green.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    med.stock > 0 ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: med.stock > 0 ? AppColors.green : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    med.stock > 0 ? 'Stok: ${med.stock}' : 'Stok Habis',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: med.stock > 0 ? AppColors.green : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 18),
              SizedBox(width: 8),
              Text(
                'Peringatan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _medicine!.warning,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.error.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.textHint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.textHint),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Informasi ini disediakan untuk tujuan edukasi. Selalu konsultasikan dengan dokter atau apoteker sebelum menggunakan obat.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _resolveIcon(String icon) {
    switch (icon) {
      case 'pill':
        return Icons.medication_rounded;
      case 'capsule':
        return Icons.vaccines_rounded;
      case 'syrup':
        return Icons.liquor_rounded;
      case 'tablet':
        return Icons.circle_outlined;
      case 'cream':
        return Icons.clean_hands_rounded;
      default:
        return Icons.medication_liquid_rounded;
    }
  }
}
