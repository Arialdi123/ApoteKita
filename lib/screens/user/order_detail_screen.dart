import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/order_widgets.dart';

/// Halaman Detail Pesanan & Tracking
class OrderDetailScreen extends StatefulWidget {
  final String? orderId;

  const OrderDetailScreen({super.key, this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String? _resolvedId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolvedId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      _resolvedId = widget.orderId ?? (args is String ? args : null);
    }
  }

  void _handlePayTransfer(Order order) {
    OrderService().updatePaymentStatus(order.id, PaymentStatus.paid);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Pembayaran transfer berhasil diverifikasi!'),
          ],
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handlePayEWallet(Order order) {
    OrderService().updatePaymentStatus(order.id, PaymentStatus.paid);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Pembayaran E-Wallet berhasil!'),
          ],
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleConfirmReceived(Order order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Penerimaan'),
        content: const Text(
          'Apakah Anda sudah menerima seluruh obat dalam pesanan ini dengan baik?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Belum',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              OrderService().confirmReceived(order.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Terima kasih! Pesanan telah selesai.'),
                    ],
                  ),
                  backgroundColor: AppColors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Ya, Pesanan Diterima'),
          ),
        ],
      ),
    );
  }

  void _showReportProblemSheet(Order order) {
    final categories = [
      'Barang tidak sesuai',
      'Barang kurang',
      'Barang rusak',
      'Pesanan belum diterima',
      'Masalah pembayaran',
      'Lainnya',
    ];

    String selectedCategory = categories.first;
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
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
                  const SizedBox(height: 16),
                  const Text(
                    'Laporkan Masalah Pesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pilih kategori masalah dan berikan rincian kendala yang dialami.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  const Text(
                    'Kategori Masalah',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat,
                                style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() => selectedCategory = val);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Description input
                  const Text(
                    'Deskripsi Masalah',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: textController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Tuliskan rincian masalah yang terjadi...',
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Button Kirim
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final desc = textController.text.trim();
                        if (desc.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Silakan masukkan deskripsi masalah.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }

                        OrderService().reportProblem(
                          order.id,
                          category: selectedCategory,
                          description: desc,
                        );

                        Navigator.of(sheetContext).pop();

                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: AppColors.green),
                                SizedBox(width: 8),
                                Text('Laporan Diterima'),
                              ],
                            ),
                            content: const Text(
                              'Laporan berhasil dikirim. Tim ApotekKita akan menindaklanjuti laporan Anda secepatnya.',
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.of(c).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Tutup'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Kirim Laporan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return ListenableBuilder(
      listenable: orderService,
      builder: (context, _) {
        final order = _resolvedId != null
            ? orderService.getOrderById(_resolvedId!)
            : null;

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Pesanan')),
            body: const Center(child: Text('Pesanan tidak ditemukan.')),
          );
        }

        final isPendingPayment =
            order.paymentStatus == PaymentStatus.pending &&
                order.paymentMethod != PaymentMethod.payAtPharmacy;

        final canConfirmReceived =
            (order.orderStatus == OrderStatus.ready ||
                order.orderStatus == OrderStatus.shipping);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Detail Pesanan'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Card (Nomor Pesanan & Status) ────────────────────
                _buildHeaderCard(order),

                const SizedBox(height: 16),

                // ── Report Problem Notice if reported ───────────────────────
                if (order.problemReport != null) ...[
                  _buildProblemReportedNotice(order.problemReport!),
                  const SizedBox(height: 16),
                ],

                // ── Section 1: Timeline Tracking ────────────────────────────
                _buildCard(
                  title: 'Status Pesanan',
                  icon: Icons.timeline_rounded,
                  child: OrderStatusTimeline(order: order),
                ),

                const SizedBox(height: 16),

                // ── Section 2: Simulasi Pembayaran (Jika Pending) ────────────
                if (isPendingPayment) ...[
                  _buildPaymentSimulationBox(order),
                  const SizedBox(height: 16),
                ],

                // ── Section 3: Rincian Produk ────────────────────────────────
                _buildCard(
                  title: 'Produk yang Dibeli (${order.totalItemCount})',
                  icon: Icons.medication_rounded,
                  child: Column(
                    children: [
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Icon(
                                    resolveMedicineIcon(item.imageIcon),
                                    color: AppColors.green,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.medicineName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.quantity} x ${formatRupiah(item.price)} (${item.unit})',
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

                // ── Section 4: Pengambilan & Alamat ─────────────────────────
                _buildCard(
                  title: 'Informasi Pengambilan',
                  icon: order.pickupMethod.icon,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              order.pickupMethod.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cyan,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.pickupMethod.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (order.pickupMethod == PickupMethod.delivery &&
                          order.deliveryAddress != null) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Alamat Tujuan:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.deliveryAddress!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Section 5: Rincian Pembayaran ───────────────────────────
                _buildCard(
                  title: 'Rincian Pembayaran',
                  icon: Icons.receipt_rounded,
                  child: Column(
                    children: [
                      _buildRow('Metode Pembayaran', order.paymentMethod.label),
                      const SizedBox(height: 8),
                      _buildRow(
                        'Status Pembayaran',
                        order.paymentStatus.label,
                        color: order.paymentStatus.color,
                      ),
                      const Divider(height: 20, color: AppColors.border),
                      _buildRow('Subtotal Produk', formatRupiah(order.subtotal)),
                      const SizedBox(height: 8),
                      _buildRow(
                        'Biaya Pengiriman/Ambil',
                        order.shippingCost == 0
                            ? 'Rp0 (Gratis)'
                            : formatRupiah(order.shippingCost),
                      ),
                      const Divider(height: 20, color: AppColors.border),
                      _buildRow(
                        'Total Pembayaran',
                        formatRupiah(order.total),
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Section 6: Laporkan Masalah ─────────────────────────────
                if (order.problemReport == null)
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _showReportProblemSheet(order),
                      icon: const Icon(Icons.report_problem_outlined,
                          size: 18, color: AppColors.error),
                      label: const Text(
                        'Laporkan Masalah Pesanan',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Bottom Sticky Bar (Jika can confirm received) ─────────────────
          bottomNavigationBar: canConfirmReceived
              ? Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleConfirmReceived(order),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('Konfirmasi Pesanan Diterima'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
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
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildHeaderCard(Order order) {
    final date = order.createdAt;
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: order.orderStatus.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: order.orderStatus.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  order.orderStatus.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: order.orderStatus.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Dibuat pada: $formattedDate',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSimulationBox(Order order) {
    if (order.paymentMethod == PaymentMethod.bankTransfer) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE082)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFF57C00), size: 18),
                SizedBox(width: 8),
                Text(
                  'Instruksi Pembayaran (Simulasi)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE65100),
                  ),
                ),
              ],
            ),
            const Divider(height: 16, color: Color(0xFFFFE082)),
            const Text(
              'Bank: BCA',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'No. Rekening: 1234567890',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  onPressed: () {
                    Clipboard.setData(
                        const ClipboardData(text: '1234567890'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nomor rekening disalin!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Text(
              'Atas Nama: ApotekKita',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handlePayTransfer(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Saya Sudah Membayar'),
              ),
            ),
          ],
        ),
      );
    } else if (order.paymentMethod == PaymentMethod.eWallet) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.qr_code_2_rounded,
                    color: AppColors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  'Simulasi Pembayaran E-Wallet (QRIS)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Tekan tombol di bawah untuk menyelesaikan simulasi pembayaran instan via E-Wallet.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handlePayEWallet(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Bayar Sekarang'),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProblemReportedNotice(OrderProblemReport report) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.report_problem_rounded,
                  color: AppColors.error, size: 18),
              const SizedBox(width: 8),
              Text(
                'Laporan Masalah (${report.category})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            report.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
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

  Widget _buildRow(String label, String value,
      {bool isTotal = false, Color? color}) {
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
            color: color ??
                (isTotal ? AppColors.green : AppColors.textPrimary),
            fontWeight: (isTotal || color != null)
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
