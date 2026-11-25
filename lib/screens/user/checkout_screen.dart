import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../models/order.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';
import '../../services/medicine_service.dart';
import '../../widgets/order_widgets.dart';

/// Halaman Checkout Pesanan
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PickupMethod _selectedPickup = PickupMethod.pickup;
  PaymentMethod _selectedPayment = PaymentMethod.bankTransfer;
  final TextEditingController _addressController = TextEditingController(
    text: 'Jl. Merdeka No. 45, RT 03/RW 02, Jakarta Selatan, 12110',
  );

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _showConfirmationBottomSheet() {
    final cart = CartService();
    final subtotal = cart.subtotal;
    final shipping = _selectedPickup.shippingCost;
    final total = subtotal + shipping;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Konfirmasi Pesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pastikan rincian pesanan Anda sudah sesuai sebelum melanjutkan.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Detail Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildConfirmRow(
                      'Jumlah Item',
                      '${cart.totalItemCount} item obat',
                    ),
                    const SizedBox(height: 10),
                    _buildConfirmRow(
                      'Pengambilan',
                      _selectedPickup.label,
                    ),
                    const SizedBox(height: 10),
                    _buildConfirmRow(
                      'Pembayaran',
                      _selectedPayment.label,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _buildConfirmRow(
                      'Total Pembayaran',
                      formatRupiah(total),
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _processCheckout();
                      },
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
                      child: const Text('Konfirmasi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processCheckout() {
    final cart = CartService();
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang belanja kosong.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = AuthService().currentUser;
    final userId = user?.id ?? 'guest_01';

    final order = OrderService().createOrder(
      userId: userId,
      items: cart.items,
      pickupMethod: _selectedPickup,
      paymentMethod: _selectedPayment,
      deliveryAddress: _selectedPickup == PickupMethod.delivery
          ? _addressController.text.trim()
          : null,
    );

    // Kurangi stok obat sesuai item pesanan & kosongkan keranjang belanja
    MedicineService().reduceStockForOrder(cart.items);
    cart.clearCart();

    // Pindah ke halaman Order Success
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.orderSuccess,
      arguments: order.id,
    );
  }

  Widget _buildConfirmRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            color: isTotal ? AppColors.green : AppColors.textPrimary,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService();

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  size: 64, color: AppColors.textHint),
              const SizedBox(height: 16),
              const Text(
                'Tidak ada item untuk di-checkout.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali ke Keranjang'),
              ),
            ],
          ),
        ),
      );
    }

    final subtotal = cart.subtotal;
    final shipping = _selectedPickup.shippingCost;
    final total = subtotal + shipping;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout Pesanan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Ringkasan Pesanan ────────────────────────────────
            _buildSectionCard(
              title: 'Ringkasan Item (${cart.totalItemCount})',
              icon: Icons.receipt_long_rounded,
              child: Column(
                children: [
                  ...cart.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                resolveMedicineIcon(item.imageIcon),
                                color: AppColors.green,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.medicineName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity} x ${formatRupiah(item.price)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatRupiah(item.subtotal),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Section 2: Metode Pengambilan ──────────────────────────────
            _buildSectionCard(
              title: 'Metode Pengambilan',
              icon: Icons.local_shipping_rounded,
              child: Column(
                children: [
                  _buildPickupOption(
                    method: PickupMethod.pickup,
                    title: 'Ambil di Apotek',
                    price: 'Gratis (Rp0)',
                    description:
                        'Pesanan dapat diambil di apotek setelah status siap diambil.',
                    icon: Icons.storefront_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildPickupOption(
                    method: PickupMethod.delivery,
                    title: 'Pengiriman ke Alamat',
                    price: formatRupiah(10000),
                    description:
                        'Pesanan akan dikirim langsung ke alamat tujuan oleh kurir.',
                    icon: Icons.moped_rounded,
                  ),
                  if (_selectedPickup == PickupMethod.delivery) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 16, color: AppColors.green),
                              SizedBox(width: 6),
                              Text(
                                'Alamat Pengiriman',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _addressController,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Masukkan alamat lengkap...',
                              filled: true,
                              fillColor: AppColors.surface,
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Section 3: Metode Pembayaran ───────────────────────────────
            _buildSectionCard(
              title: 'Metode Pembayaran',
              icon: Icons.account_balance_wallet_rounded,
              child: Column(
                children: [
                  _buildPaymentOption(
                    method: PaymentMethod.bankTransfer,
                    title: 'Transfer Bank',
                    subtitle: 'BCA (Virtual Account / Transfer)',
                    icon: Icons.account_balance_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOption(
                    method: PaymentMethod.eWallet,
                    title: 'E-Wallet',
                    subtitle: 'GoPay, OVO, DANA, ShopeePay (QRIS)',
                    icon: Icons.qr_code_scanner_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOption(
                    method: PaymentMethod.payAtPharmacy,
                    title: 'Bayar di Apotek',
                    subtitle: 'Bayar tunai / QRIS langsung di kasir apotek',
                    icon: Icons.point_of_sale_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Section 4: Ringkasan Biaya ─────────────────────────────────
            _buildSectionCard(
              title: 'Rincian Pembayaran',
              icon: Icons.monetization_on_rounded,
              child: Column(
                children: [
                  _buildSummaryRow(
                      'Subtotal Produk', formatRupiah(subtotal)),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Biaya Pengambilan/Kirim',
                    shipping == 0 ? 'Rp0 (Gratis)' : formatRupiah(shipping),
                  ),
                  const Divider(height: 20, color: AppColors.border),
                  _buildSummaryRow(
                    'Total Pembayaran',
                    formatRupiah(total),
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Action Bar ───────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Total Info
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      formatRupiah(total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Button Konfirmasi
              ElevatedButton(
                onPressed: _showConfirmationBottomSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Konfirmasi Pesanan'),
                    SizedBox(width: 6),
                    Icon(Icons.check_circle_outline_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.cyan),
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
          const Divider(height: 20, color: AppColors.border),
          child,
        ],
      ),
    );
  }

  Widget _buildPickupOption({
    required PickupMethod method,
    required String title,
    required String price,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedPickup == method;

    return InkWell(
      onTap: () => setState(() => _selectedPickup = method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.green.withValues(alpha: 0.05)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.green : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.green : AppColors.textHint,
                  width: 2,
                ),
                color: isSelected ? AppColors.green : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.green
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPayment == method;

    return InkWell(
      onTap: () => setState(() => _selectedPayment = method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.cyan.withValues(alpha: 0.05)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.cyan : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.cyan : AppColors.textHint,
                  width: 2,
                ),
                color: isSelected ? AppColors.cyan : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Icon(icon,
                size: 22,
                color: isSelected ? AppColors.cyan : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            color: isTotal ? AppColors.green : AppColors.textPrimary,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
