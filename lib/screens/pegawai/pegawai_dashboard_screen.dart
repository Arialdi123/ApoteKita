import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../models/order.dart';
import '../../models/medicine.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/medicine_service.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/order_widgets.dart';

/// Dashboard Khusus Role PEGAWAI
/// Fokus pada operasional harian apotek: kasir, verifikasi pembayaran,
/// pengemasan/pengiriman pesanan pelanggan, penanganan komplain, dan restock gudang.
class PegawaiDashboardScreen extends StatefulWidget {
  const PegawaiDashboardScreen({super.key});

  @override
  State<PegawaiDashboardScreen> createState() => _PegawaiDashboardScreenState();
}

class _PegawaiDashboardScreenState extends State<PegawaiDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _PegawaiOverviewTab(
        onSwitchTab: (idx) => setState(() => _selectedIndex = idx),
      ),
      const _PegawaiOrdersTab(),
      const _PegawaiInventoryTab(),
      const _PegawaiProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
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
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF7B61FF),
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront_rounded),
              label: 'Operasional',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping_rounded),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: 'Stok Gudang',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 1: Ringkasan Operasional Pegawai ────────────────────────────────────
class _PegawaiOverviewTab extends StatelessWidget {
  final ValueChanged<int> onSwitchTab;

  const _PegawaiOverviewTab({required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();
    final medService = MedicineService();
    final user = AuthService().currentUser;

    return ListenableBuilder(
      listenable: Listenable.merge([orderService, medService]),
      builder: (context, _) {
        final orders = orderService.orders;
        final waitingPay = orders
            .where((o) =>
                o.paymentStatus == PaymentStatus.pending &&
                o.orderStatus != OrderStatus.cancelled)
            .length;
        final needPack = orders
            .where((o) => o.orderStatus == OrderStatus.processing)
            .length;
        final readyOrShip = orders
            .where((o) =>
                o.orderStatus == OrderStatus.ready ||
                o.orderStatus == OrderStatus.shipping)
            .length;
        final activeComplaints = orders
            .where((o) =>
                o.problemReport != null &&
                o.problemReport!.status != 'Selesai Ditangani')
            .length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Operasional Pegawai'),
            actions: [
              IconButton(
                tooltip: 'Sinkronkan Data',
                onPressed: () {
                  orderService.initFirestoreSync();
                  medService.initFirestoreSync();
                  AppFeedback.showInfo(context, 'Data pesanan & stok diperbarui.');
                },
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B61FF), Color(0xFF0CA9BA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'STAF OPERASIONAL & KASIR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Halo, ${user?.name ?? "Pegawai"}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Kelola pembayaran kasir, pengemasan, pengiriman kurir, dan stok gudang apotek.',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    _PegawaiKpiCard(
                      label: 'Belum Lunas',
                      value: '$waitingPay Pesanan',
                      icon: Icons.payments_outlined,
                      color: const Color(0xFFFF9800),
                      onTap: () => onSwitchTab(1),
                    ),
                    _PegawaiKpiCard(
                      label: 'Perlu Dikemas',
                      value: '$needPack Pesanan',
                      icon: Icons.inventory_rounded,
                      color: AppColors.cyan,
                      onTap: () => onSwitchTab(1),
                    ),
                    _PegawaiKpiCard(
                      label: 'Siap / Dikirim',
                      value: '$readyOrShip Pesanan',
                      icon: Icons.moped_rounded,
                      color: const Color(0xFF7B61FF),
                      onTap: () => onSwitchTab(1),
                    ),
                    _PegawaiKpiCard(
                      label: 'Komplain Aktif',
                      value: '$activeComplaints Laporan',
                      icon: Icons.report_problem_outlined,
                      color: AppColors.error,
                      onTap: () => onSwitchTab(1),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                const Text(
                  'Tugas Prioritas Kasir & Pengiriman',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                ...orders
                    .where((o) =>
                        o.orderStatus != OrderStatus.completed &&
                        o.orderStatus != OrderStatus.cancelled)
                    .take(5)
                    .map(
                      (o) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                o.orderStatus.color.withValues(alpha: 0.12),
                            child: Icon(
                              o.pickupMethod.icon,
                              color: o.orderStatus.color,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            '${o.id} • ${formatRupiah(o.total)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            '${o.pickupMethod.label} • ${o.orderStatus.label}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => onSwitchTab(1),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Tab 2: Kelola Pesanan Pelanggan (Kasir, Pengemasan, Kurir, Komplain) ────
class _PegawaiOrdersTab extends StatefulWidget {
  const _PegawaiOrdersTab();

  @override
  State<_PegawaiOrdersTab> createState() => _PegawaiOrdersTabState();
}

class _PegawaiOrdersTabState extends State<_PegawaiOrdersTab> {
  int _filterIdx = 0;

  static const _filters = [
    'Semua',
    'Menunggu Bayar',
    'Diproses',
    'Siap / Dikirim',
    'Selesai',
    'Komplain',
  ];

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return ListenableBuilder(
      listenable: orderService,
      builder: (context, _) {
        final filtered = orderService.orders.where((o) {
          switch (_filterIdx) {
            case 1:
              return o.paymentStatus == PaymentStatus.pending &&
                  o.orderStatus != OrderStatus.cancelled;
            case 2:
              return o.orderStatus == OrderStatus.processing;
            case 3:
              return o.orderStatus == OrderStatus.ready ||
                  o.orderStatus == OrderStatus.shipping;
            case 4:
              return o.orderStatus == OrderStatus.completed;
            case 5:
              return o.problemReport != null;
            default:
              return true;
          }
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Kelola Pesanan Pelanggan'),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final selected = _filterIdx == i;
                    return ChoiceChip(
                      label: Text(_filters[i]),
                      selected: selected,
                      selectedColor: const Color(0xFF7B61FF),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                      onSelected: (_) => setState(() => _filterIdx = i),
                    );
                  },
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada pesanan pada kategori ini.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final o = filtered[index];
                          return _StaffOrderActionCard(order: o);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StaffOrderActionCard extends StatelessWidget {
  final Order order;

  const _StaffOrderActionCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              Expanded(
                child: Text(
                  order.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: order.orderStatus.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
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
            'Pelanggan ID: ${order.userId} • ${order.paymentMethod.label} (${order.paymentStatus.label})',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Metode: ${order.pickupMethod.label}${order.deliveryAddress != null ? "\nAlamat: ${order.deliveryAddress}" : ""}',
            style: const TextStyle(fontSize: 12),
          ),
          const Divider(height: 18, color: AppColors.border),
          ...order.items.map(
            (it) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${it.quantity}x ${it.medicineName}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    formatRupiah(it.subtotal),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Tagihan',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              Text(
                formatRupiah(order.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.green,
                ),
              ),
            ],
          ),

          // Laporan komplain jika ada
          if (order.problemReport != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Komplain (${order.problemReport!.status}): ${order.problemReport!.category}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                  Text(
                    order.problemReport!.description,
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (order.problemReport!.status != 'Selesai Ditangani') ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          orderService.resolveProblemReport(order.id);
                          AppFeedback.showSuccess(
                            context,
                            'Laporan masalah ditandai selesai ditangani.',
                          );
                        },
                        child: const Text('Tandai Komplain Selesai'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Tombol aksi operasional bertahap
          if (order.orderStatus != OrderStatus.completed &&
              order.orderStatus != OrderStatus.cancelled) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (order.paymentStatus == PaymentStatus.pending)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () {
                      orderService.updatePaymentStatus(
                        order.id,
                        PaymentStatus.paid,
                      );
                      AppFeedback.showSuccess(
                        context,
                        'Pembayaran ${order.id} diverifikasi Lunas!',
                      );
                    },
                    icon: const Icon(Icons.verified_rounded, size: 16),
                    label: const Text('Verifikasi Lunas'),
                  ),
                if (order.orderStatus == OrderStatus.processing)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () {
                      final next = order.pickupMethod == PickupMethod.pickup
                          ? OrderStatus.ready
                          : OrderStatus.shipping;
                      orderService.updateOrderStatus(order.id, next);
                      AppFeedback.showSuccess(
                        context,
                        'Status pesanan diubah ke ${next.label}.',
                      );
                    },
                    icon: Icon(order.pickupMethod.icon, size: 16),
                    label: Text(
                      order.pickupMethod == PickupMethod.pickup
                          ? 'Siap Diambil'
                          : 'Kirim Kurir',
                    ),
                  ),
                if (order.orderStatus == OrderStatus.ready ||
                    order.orderStatus == OrderStatus.shipping)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () {
                      orderService.confirmReceived(order.id);
                      AppFeedback.showSuccess(
                        context,
                        'Pesanan ${order.id} telah diselesaikan!',
                      );
                    },
                    icon: const Icon(Icons.task_alt_rounded, size: 16),
                    label: const Text('Selesaikan Pesanan'),
                  ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: () {
                    orderService.cancelOrder(order.id);
                    AppFeedback.showInfo(
                      context,
                      'Pesanan ${order.id} dibatalkan.',
                    );
                  },
                  child: const Text('Batalkan'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tab 3: Stok Gudang & Restock Cepat ──────────────────────────────────────
class _PegawaiInventoryTab extends StatefulWidget {
  const _PegawaiInventoryTab();

  @override
  State<_PegawaiInventoryTab> createState() => _PegawaiInventoryTabState();
}

class _PegawaiInventoryTabState extends State<_PegawaiInventoryTab> {
  bool _onlyLowStock = false;

  void _showRestockDialog(BuildContext context, Medicine med) {
    final ctrl = TextEditingController(text: med.stock.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Stok — ${med.name}'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Jumlah Stok Baru',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(ctrl.text.trim()) ?? med.stock;
              MedicineService().updateStock(med.id, val);
              Navigator.of(ctx).pop();
              AppFeedback.showSuccess(
                context,
                'Stok ${med.name} diperbarui menjadi $val.',
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medService = MedicineService();

    return ListenableBuilder(
      listenable: medService,
      builder: (context, _) {
        final list = _onlyLowStock
            ? medService.lowStockMedicines
            : medService.medicinesList;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Stok Gudang Obat'),
            actions: [
              FilterChip(
                label: const Text(
                  'Stok Menipis',
                  style: TextStyle(fontSize: 12),
                ),
                selected: _onlyLowStock,
                onSelected: (v) => setState(() => _onlyLowStock = v),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final m = list[index];
              final low = m.stock <= 20;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: low ? AppColors.error : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${m.unit} • Stok saat ini: ${m.stock}',
                            style: TextStyle(
                              fontSize: 12,
                              color: low
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              fontWeight:
                                  low ? FontWeight.w700 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: () {
                        medService.updateStock(m.id, m.stock + 25);
                        AppFeedback.showSuccess(
                          context,
                          'Restock +25 untuk ${m.name} berhasil!',
                        );
                      },
                      child: const Text('+25', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Ubah Manual',
                      onPressed: () => _showRestockDialog(context, m),
                      icon: const Icon(Icons.edit_outlined, size: 20),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Tab 4: Profil Pegawai ───────────────────────────────────────────────────
class _PegawaiProfileTab extends StatelessWidget {
  const _PegawaiProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profil Pegawai'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFF7B61FF).withValues(alpha: 0.15),
              child: const Icon(
                Icons.badge_rounded,
                size: 44,
                color: Color(0xFF7B61FF),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.name ?? 'Pegawai',
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7B61FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Role: Pegawai Apotek',
                style: TextStyle(
                  color: Color(0xFF7B61FF),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 28),
            ListTile(
              tileColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: const Icon(Icons.lock_outline, color: Color(0xFF7B61FF)),
              title: const Text('Ubah Password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.changePassword),
            ),
            const SizedBox(height: 12),
            ListTile(
              tileColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Keluar Akun',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () async {
                await AuthService().logout();
                if (!context.mounted) return;
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PegawaiKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PegawaiKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
