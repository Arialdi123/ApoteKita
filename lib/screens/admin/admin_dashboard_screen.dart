import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../models/user.dart';
import '../../models/medicine.dart';
import '../../models/order.dart';
import '../../services/auth_service.dart';
import '../../services/medicine_service.dart';
import '../../services/order_service.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/order_widgets.dart';

/// Dashboard Khusus Role ADMIN
/// Mencakup seluruh fitur README Bab 8:
/// 1. Ringkasan Manajemen & Laporan Penjualan/Kinerja
/// 2. Manajemen Data Obat (CRUD lengkap: Tambah, Edit, Hapus, sinkron ke Katalog User)
/// 3. Manajemen Transaksi Apotek
/// 4. Manajemen Pengguna & Role (Pengguna, Pegawai, Apoteker, Admin)
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _AdminReportTab(
        onSwitchTab: (idx) => setState(() => _selectedIndex = idx),
      ),
      const _AdminMedicineCrudTab(),
      const _AdminTransactionsTab(),
      const _AdminUsersManagementTab(),
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
          selectedItemColor: AppColors.green,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics_rounded),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication_outlined),
              activeIcon: Icon(Icons.medication_rounded),
              label: 'Data Obat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts_outlined),
              activeIcon: Icon(Icons.manage_accounts_rounded),
              label: 'Pengguna',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 1: Ringkasan Manajemen & Laporan Penjualan/Kinerja ───────────────────
class _AdminReportTab extends StatelessWidget {
  final ValueChanged<int> onSwitchTab;

  const _AdminReportTab({required this.onSwitchTab});

  void _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final medService = MedicineService();
    final orderService = OrderService();

    return ListenableBuilder(
      listenable: Listenable.merge([authService, medService, orderService]),
      builder: (context, _) {
        final orders = orderService.orders;
        final meds = medService.medicinesList;
        final users = authService.allUsers;

        final validOrders = orders
            .where((o) => o.orderStatus != OrderStatus.cancelled)
            .toList();
        final paidRevenue = validOrders
            .where((o) => o.paymentStatus == PaymentStatus.paid)
            .fold<int>(0, (s, o) => s + o.total);
        final unpaidRevenue = validOrders
            .where((o) => o.paymentStatus == PaymentStatus.pending)
            .fold<int>(0, (s, o) => s + o.total);
        final completedCount =
            orders.where((o) => o.orderStatus == OrderStatus.completed).length;

        final transferCount = orders
            .where((o) => o.paymentMethod == PaymentMethod.bankTransfer)
            .length;
        final ewalletCount =
            orders.where((o) => o.paymentMethod == PaymentMethod.eWallet).length;
        final cashCount = orders
            .where((o) => o.paymentMethod == PaymentMethod.payAtPharmacy)
            .length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Dashboard Admin'),
            actions: [
              IconButton(
                tooltip: 'Sinkronkan Firestore',
                onPressed: () {
                  authService.syncUsersFromFirestore();
                  medService.initFirestoreSync();
                  orderService.initFirestoreSync();
                  AppFeedback.showInfo(context, 'Seluruh data sistem disinkronkan.');
                },
                icon: const Icon(Icons.sync_rounded),
              ),
              IconButton(
                tooltip: 'Keluar Admin',
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A2E), Color(0xFF0CA9BA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL PENDAPATAN LUNAS APOTEK',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatRupiah(paidRevenue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Piutang / Menunggu Bayar: ${formatRupiah(unpaidRevenue)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            '$completedCount Selesai',
                            style: const TextStyle(
                              color: AppColors.greenLight,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4 KPI Cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    _AdminMetricCard(
                      label: 'Produk Obat',
                      value: '${meds.length} Item',
                      icon: Icons.medication_rounded,
                      color: AppColors.green,
                      onTap: () => onSwitchTab(1),
                    ),
                    _AdminMetricCard(
                      label: 'Total Transaksi',
                      value: '${orders.length} Order',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.cyan,
                      onTap: () => onSwitchTab(2),
                    ),
                    _AdminMetricCard(
                      label: 'Total Akun & Staf',
                      value: '${users.length} Akun',
                      icon: Icons.people_alt_rounded,
                      color: const Color(0xFF7B61FF),
                      onTap: () => onSwitchTab(3),
                    ),
                    _AdminMetricCard(
                      label: 'Stok Menipis',
                      value: '${medService.lowStockMedicines.length} Obat',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.error,
                      onTap: () => onSwitchTab(1),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Laporan Kinerja Metode Pembayaran
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Laporan Metode Pembayaran & Kinerja',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Divider(height: 20, color: AppColors.border),
                      _ReportRow(
                        label: 'Transfer Bank (BCA)',
                        value: '$transferCount transaksi',
                      ),
                      const SizedBox(height: 8),
                      _ReportRow(
                        label: 'E-Wallet / QRIS',
                        value: '$ewalletCount transaksi',
                      ),
                      const SizedBox(height: 8),
                      _ReportRow(
                        label: 'Bayar di Apotek (Kasir)',
                        value: '$cashCount transaksi',
                      ),
                      const Divider(height: 20, color: AppColors.border),
                      _ReportRow(
                        label: 'Tingkat Penyelesaian Pesanan',
                        value: orders.isEmpty
                            ? '0%'
                            : '${((completedCount / orders.length) * 100).toStringAsFixed(0)}%',
                        highlight: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Peringatan Stok Kritis
                const Text(
                  'Pemantauan Stok Obat Terendah',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ...(List<Medicine>.from(meds)
                      ..sort((a, b) => a.stock.compareTo(b.stock)))
                    .take(4)
                    .map(
                      (m) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListTile(
                          dense: true,
                          title: Text(
                            m.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text('${m.category} • ${m.formattedPrice}'),
                          trailing: Text(
                            'Stok: ${m.stock}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color:
                                  m.stock <= 20 ? AppColors.error : AppColors.green,
                            ),
                          ),
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

// ─── Tab 2: Manajemen Data Obat (CRUD Lengkap) ───────────────────────────────
class _AdminMedicineCrudTab extends StatefulWidget {
  const _AdminMedicineCrudTab();

  @override
  State<_AdminMedicineCrudTab> createState() => _AdminMedicineCrudTabState();
}

class _AdminMedicineCrudTabState extends State<_AdminMedicineCrudTab> {
  String _query = '';
  String _selectedCat = MedicineCategory.all;

  void _openMedicineForm(BuildContext context, {Medicine? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final genericCtrl = TextEditingController(
      text: existing?.genericName.isNotEmpty == true
          ? existing!.genericName
          : (existing?.ingredients ?? ''),
    );
    final priceCtrl =
        TextEditingController(text: existing != null ? '${existing.price}' : '');
    final stockCtrl =
        TextEditingController(text: existing != null ? '${existing.stock}' : '50');
    final unitCtrl =
        TextEditingController(text: existing?.unit ?? 'Strip @10 Tablet');
    final descCtrl = TextEditingController(
      text: existing?.description ??
          'Obat berkualitas terjamin di ApoteKita.',
    );
    final indicationCtrl = TextEditingController(
      text: existing?.indication ?? 'Sesuai indikasi medis.',
    );
    final dosageCtrl = TextEditingController(
      text: existing?.dosage ?? 'Dewasa: 3x sehari 1 tablet sesudah makan.',
    );
    final sideEffectsCtrl = TextEditingController(
      text: existing?.sideEffects ?? 'Jarang terjadi efek samping ringan.',
    );
    final warningCtrl = TextEditingController(
      text: existing?.warning ?? 'Simpan di tempat sejuk dan kering.',
    );

    final categories = MedicineCategory.allCategories
        .where((c) => c != MedicineCategory.all)
        .toList();
    String selectedCategory =
        (existing != null && categories.contains(existing.category))
            ? existing.category
            : categories.first;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
            ),
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      existing == null ? 'Tambah Obat Baru' : 'Edit Data Obat',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nama Obat'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama obat wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration:
                          const InputDecoration(labelText: 'Kategori Obat'),
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() => selectedCategory = v);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga (Rp)',
                            ),
                            validator: (v) =>
                                (int.tryParse(v ?? '') ?? 0) <= 0
                                    ? 'Harga tidak valid'
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stok',
                            ),
                            validator: (v) => int.tryParse(v ?? '') == null
                                ? 'Stok wajib angka'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kemasan / Satuan',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: genericCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Komposisi / Kandungan Aktif',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Obat',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: indicationCtrl,
                      decoration: const InputDecoration(labelText: 'Indikasi'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: dosageCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Dosis & Aturan Pakai'),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final med = Medicine(
                            id: existing?.id ?? '',
                            name: nameCtrl.text.trim(),
                            category: selectedCategory,
                            price: int.parse(priceCtrl.text.trim()),
                            stock: int.parse(stockCtrl.text.trim()),
                            imageIcon: existing?.imageIcon ?? 'pill',
                            description: descCtrl.text.trim(),
                            indication: indicationCtrl.text.trim(),
                            ingredients: genericCtrl.text.trim(),
                            dosage: dosageCtrl.text.trim(),
                            sideEffects: sideEffectsCtrl.text.trim(),
                            warning: warningCtrl.text.trim(),
                            genericName: genericCtrl.text.trim(),
                            unit: unitCtrl.text.trim(),
                            keywords: nameCtrl.text
                                .trim()
                                .toLowerCase()
                                .split(' '),
                          );

                          if (existing == null) {
                            await MedicineService().addMedicine(med);
                          } else {
                            await MedicineService().updateMedicine(med);
                          }

                          if (!modalCtx.mounted) return;
                          Navigator.of(modalCtx).pop();
                          if (!context.mounted) return;
                          AppFeedback.showSuccess(
                            context,
                            existing == null
                                ? 'Obat baru berhasil ditambahkan ke Katalog!'
                                : 'Data obat berhasil diperbarui!',
                          );
                        },
                        child: Text(
                          existing == null ? 'Tambah Obat' : 'Simpan Perubahan',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Medicine m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Obat?'),
        content: Text(
          'Hapus "${m.name}" dari katalog ApoteKita?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await MedicineService().deleteMedicine(m.id);
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              if (!context.mounted) return;
              AppFeedback.showInfo(context, '${m.name} telah dihapus.');
            },
            child: const Text('Hapus'),
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
        final filtered = medService.searchAndFilter(
          source: medService.medicinesList,
          query: _query,
          category: _selectedCat,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Manajemen Data Obat'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_admin_add_med',
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            onPressed: () => _openMedicineForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Tambah Obat',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Cari nama atau kategori obat...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: MedicineCategory.allCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = MedicineCategory.allCategories[i];
                    final selected = _selectedCat == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: AppColors.green,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                      onSelected: (_) => setState(() => _selectedCat = cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final m = filtered[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              resolveMedicineIcon(m.imageIcon),
                              color: AppColors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${m.category} • ${m.formattedPrice} • Stok: ${m.stock}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () =>
                                _openMedicineForm(context, existing: m),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.cyan,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Hapus',
                            onPressed: () => _confirmDelete(context, m),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    );
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

// ─── Tab 3: Manajemen Transaksi Sistem ───────────────────────────────────────
class _AdminTransactionsTab extends StatelessWidget {
  const _AdminTransactionsTab();

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return ListenableBuilder(
      listenable: orderService,
      builder: (context, _) {
        final orders = orderService.orders;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Manajemen Transaksi'),
          ),
          body: orders.isEmpty
              ? const Center(child: Text('Belum ada data transaksi.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final o = orders[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                                  '${o.id} (${formatRupiah(o.total)})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              PopupMenuButton<OrderStatus>(
                                tooltip: 'Ubah Status Pesanan',
                                onSelected: (st) {
                                  orderService.updateOrderStatus(o.id, st);
                                  AppFeedback.showSuccess(
                                    context,
                                    'Status ${o.id} diubah ke ${st.label}.',
                                  );
                                },
                                itemBuilder: (_) => OrderStatus.values
                                    .map(
                                      (s) => PopupMenuItem(
                                        value: s,
                                        child: Text(s.label),
                                      ),
                                    )
                                    .toList(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: o.orderStatus.color
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        o.orderStatus.label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: o.orderStatus.color,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        size: 16,
                                        color: o.orderStatus.color,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'User: ${o.userId} • ${o.pickupMethod.label} • ${o.paymentMethod.label} (${o.paymentStatus.label})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            o.items
                                .map((e) => '${e.quantity}x ${e.medicineName}')
                                .join(', '),
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (o.paymentStatus != PaymentStatus.paid &&
                              o.orderStatus != OrderStatus.cancelled) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  orderService.updatePaymentStatus(
                                    o.id,
                                    PaymentStatus.paid,
                                  );
                                  AppFeedback.showSuccess(
                                    context,
                                    'Transaksi ${o.id} ditandai Lunas.',
                                  );
                                },
                                icon: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 16,
                                ),
                                label: const Text('Konfirmasi Pembayaran Lunas'),
                              ),
                            ),
                          ],
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

// ─── Tab 4: Manajemen Pengguna & Role (Pengguna, Apoteker, Pegawai, Admin) ───
class _AdminUsersManagementTab extends StatefulWidget {
  const _AdminUsersManagementTab();

  @override
  State<_AdminUsersManagementTab> createState() =>
      _AdminUsersManagementTabState();
}

class _AdminUsersManagementTabState extends State<_AdminUsersManagementTab> {
  UserRole? _roleFilter;

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF1A1A2E);
      case UserRole.apoteker:
        return AppColors.cyan;
      case UserRole.pegawai:
        return const Color(0xFF7B61FF);
      case UserRole.user:
        return AppColors.green;
    }
  }

  void _showAddUserSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: '123456');
    UserRole selectedRole = UserRole.pegawai;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tambah Akun Pengguna / Staf',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Nama Lengkap'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email Login'),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Email tidak valid'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration:
                          const InputDecoration(labelText: 'Nomor Telepon'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Password Awal'),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Minimal 6 karakter'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<UserRole>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(labelText: 'Role Akun'),
                      items: UserRole.values
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text('${r.label} — ${r.subtitle}'),
                              ))
                          .toList(),
                      onChanged: (r) {
                        if (r != null) setModalState(() => selectedRole = r);
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final res = await AuthService().addManagedUser(
                            name: nameCtrl.text,
                            email: emailCtrl.text,
                            phone: phoneCtrl.text,
                            password: passCtrl.text,
                            role: selectedRole,
                          );
                          if (!modalCtx.mounted) return;
                          if (res.success) {
                            Navigator.of(modalCtx).pop();
                            if (context.mounted) {
                              AppFeedback.showSuccess(
                                context,
                                res.message ?? 'Akun ditambahkan.',
                              );
                            }
                          } else {
                            AppFeedback.showError(
                              context,
                              res.message ?? 'Gagal menambah akun.',
                            );
                          }
                        },
                        child: const Text('Simpan Akun'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return ListenableBuilder(
      listenable: authService,
      builder: (context, _) {
        final current = authService.currentUser;
        final users = authService.allUsers.where((u) {
          if (_roleFilter == null) return true;
          return u.role == _roleFilter;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Manajemen Pengguna & Role'),
            actions: [
              IconButton(
                tooltip: 'Ubah Password Admin',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.changePassword),
                icon: const Icon(Icons.lock_outline),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_admin_add_user',
            backgroundColor: const Color(0xFF1A1A2E),
            foregroundColor: Colors.white,
            onPressed: () => _showAddUserSheet(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text(
              'Tambah Akun',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  scrollDirection: Axis.horizontal,
                  children: [
                    ChoiceChip(
                      label: const Text('Semua'),
                      selected: _roleFilter == null,
                      onSelected: (_) => setState(() => _roleFilter = null),
                    ),
                    const SizedBox(width: 8),
                    ...UserRole.values.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(r.label),
                          selected: _roleFilter == r,
                          onSelected: (_) => setState(() => _roleFilter = r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];
                    final color = _roleColor(u.role);
                    final isSelf = current?.id == u.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.12),
                            child: Text(
                              u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${u.name}${isSelf ? " (Anda)" : ""}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  u.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<UserRole>(
                            tooltip: 'Ubah Role',
                            onSelected: (newRole) async {
                              await authService.updateUserRole(u.id, newRole);
                              if (!context.mounted) return;
                              AppFeedback.showSuccess(
                                context,
                                'Role ${u.name} diubah ke ${newRole.label}.',
                              );
                            },
                            itemBuilder: (_) => UserRole.values
                                .map(
                                  (r) => PopupMenuItem(
                                    value: r,
                                    child: Text('Set sebagai ${r.label}'),
                                  ),
                                )
                                .toList(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    u.role.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 16,
                                    color: color,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!isSelf)
                            IconButton(
                              tooltip: 'Hapus Akun',
                              onPressed: () async {
                                await authService.deleteManagedUser(u.id);
                                if (!context.mounted) return;
                                AppFeedback.showInfo(
                                  context,
                                  'Akun ${u.name} dihapus.',
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: AppColors.error,
                              ),
                            ),
                        ],
                      ),
                    );
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

class _AdminMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminMetricCard({
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

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ReportRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: highlight ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: highlight ? AppColors.green : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
