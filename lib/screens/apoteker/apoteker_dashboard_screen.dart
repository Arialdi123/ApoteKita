import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../models/order.dart';
import '../../models/medicine.dart';
import '../../models/consultation.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/medicine_service.dart';
import '../../services/consultation_service.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/order_widgets.dart';
import '../user/consultation_tab.dart';

/// Dashboard Khusus Role APOTEKER
/// Mencakup: Ringkasan Operasional & Keuangan, Validasi Resep, Chat Konsultasi,
/// Manajemen Pesanan Masuk, dan Pemantauan Stok Obat.
class ApotekerDashboardScreen extends StatefulWidget {
  const ApotekerDashboardScreen({super.key});

  @override
  State<ApotekerDashboardScreen> createState() =>
      _ApotekerDashboardScreenState();
}

class _ApotekerDashboardScreenState extends State<ApotekerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _ApotekerHomeTab(onSwitchTab: (idx) => setState(() => _selectedIndex = idx)),
      const _ApotekerResepChatTab(),
      const _ApotekerOrdersStockTab(),
      const _ApotekerProfileTab(),
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
          selectedItemColor: AppColors.cyan,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_ind_outlined),
              activeIcon: Icon(Icons.assignment_ind_rounded),
              label: 'Resep & Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medication_outlined),
              activeIcon: Icon(Icons.medication_rounded),
              label: 'Pesanan & Stok',
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

// ─── Tab 1: Ringkasan Operasional & Keuangan Apoteker ─────────────────────────
class _ApotekerHomeTab extends StatelessWidget {
  final ValueChanged<int> onSwitchTab;

  const _ApotekerHomeTab({required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();
    final medService = MedicineService();
    final consultService = ConsultationService();
    final user = AuthService().currentUser;

    return ListenableBuilder(
      listenable: Listenable.merge([orderService, medService, consultService]),
      builder: (context, _) {
        final orders = orderService.orders;
        final processingCount = orders
            .where((o) => o.orderStatus == OrderStatus.processing)
            .length;
        final paidRevenue = orders
            .where((o) =>
                o.paymentStatus == PaymentStatus.paid &&
                o.orderStatus != OrderStatus.cancelled)
            .fold<int>(0, (sum, o) => sum + o.total);
        final pendingRevenue = orders
            .where((o) =>
                o.paymentStatus == PaymentStatus.pending &&
                o.orderStatus != OrderStatus.cancelled)
            .fold<int>(0, (sum, o) => sum + o.total);

        final pendingPrescriptions = consultService.pendingPrescriptionCount;
        final activeChats = consultService.activeThreadCount;
        final lowStockCount = medService.lowStockMedicines.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Dashboard Apoteker'),
            actions: [
              IconButton(
                tooltip: 'Sinkronkan Data',
                onPressed: () {
                  orderService.initFirestoreSync();
                  medService.initFirestoreSync();
                  consultService.initFirestoreSync();
                  AppFeedback.showInfo(context, 'Data disinkronkan dari server.');
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
                // Header Card Apoteker
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0CA9BA), Color(0xFF4CAF50)],
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
                          'TENAGA KEFARMASIAN',
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
                        'Selamat Bertugas,\n${user?.name ?? "Apoteker"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pastikan validasi resep, konsultasi pasien, dan penyiapan obat berjalan tepat dosis.',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Grid KPI
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    _StatCard(
                      label: 'Resep Menunggu',
                      value: '$pendingPrescriptions',
                      icon: Icons.assignment_late_rounded,
                      color: const Color(0xFFFF9800),
                      onTap: () => onSwitchTab(1),
                    ),
                    _StatCard(
                      label: 'Chat Konsultasi',
                      value: '$activeChats Aktif',
                      icon: Icons.forum_rounded,
                      color: AppColors.cyan,
                      onTap: () => onSwitchTab(1),
                    ),
                    _StatCard(
                      label: 'Perlu Disiapkan',
                      value: '$processingCount Pesanan',
                      icon: Icons.medication_liquid_rounded,
                      color: AppColors.green,
                      onTap: () => onSwitchTab(2),
                    ),
                    _StatCard(
                      label: 'Stok Menipis',
                      value: '$lowStockCount Obat',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.error,
                      onTap: () => onSwitchTab(2),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Ringkasan Keuangan Apotek (README 7.4)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Ringkasan Keuangan Apotek',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 22, color: AppColors.border),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pendapatan Lunas',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatRupiah(paidRevenue),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Menunggu Pembayaran',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatRupiah(pendingRevenue),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFFF9800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Antrean Resep Terbaru
                const Text(
                  'Antrean Validasi Resep Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                if (consultService.prescriptions.isEmpty)
                  const Text(
                    'Belum ada resep masuk.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  ...consultService.prescriptions.take(3).map(
                        (p) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ListTile(
                            title: Text(
                              '${p.userName} • ${p.doctorName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              p.notes,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              p.status.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: p.status.color,
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

// ─── Tab 2: Validasi Resep & Chat Konsultasi Pasien ──────────────────────────
class _ApotekerResepChatTab extends StatelessWidget {
  const _ApotekerResepChatTab();

  void _showValidateModal(BuildContext context, PrescriptionRequest req) {
    final noteCtrl = TextEditingController(
      text: req.pharmacistNote.isNotEmpty
          ? req.pharmacistNote
          : 'Konsumsi sesuai dosis tertera sesudah makan.',
    );
    final selectedMeds = Set<String>.from(req.approvedMedicineIds);
    final allMeds = MedicineService().medicinesList;

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
              maxHeight: MediaQuery.of(modalCtx).size.height * 0.85,
            ),
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Validasi Resep ${req.id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pasien: ${req.userName}\nDokter: ${req.doctorName} (${req.clinicName})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Isi Resep / Keluhan:\n${req.notes}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Konfirmasi Obat yang Disetujui:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: allMeds.map((Medicine m) {
                      final active = selectedMeds.contains(m.id);
                      return FilterChip(
                        label: Text(
                          '${m.name} (Stok: ${m.stock})',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                active ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        selected: active,
                        selectedColor: AppColors.cyan,
                        checkmarkColor: Colors.white,
                        onSelected: (v) {
                          setModalState(() {
                            if (v) {
                              selectedMeds.add(m.id);
                            } else {
                              selectedMeds.remove(m.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Catatan / Aturan Pakai dari Apoteker',
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          onPressed: () async {
                            final pharmacist =
                                AuthService().currentUser?.name ?? 'Apoteker';
                            await ConsultationService().validatePrescription(
                              id: req.id,
                              status: PrescriptionStatus.rejected,
                              approvedMedicineIds: selectedMeds.toList(),
                              pharmacistNote: noteCtrl.text,
                              pharmacistName: pharmacist,
                            );
                            if (!modalCtx.mounted) return;
                            Navigator.of(modalCtx).pop();
                            if (!context.mounted) return;
                            AppFeedback.showInfo(
                              context,
                              'Resep ${req.id} ditolak.',
                            );
                          },
                          child: const Text('Tolak Resep'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          onPressed: () async {
                            final pharmacist =
                                AuthService().currentUser?.name ?? 'Apoteker';
                            await ConsultationService().validatePrescription(
                              id: req.id,
                              status: PrescriptionStatus.approved,
                              approvedMedicineIds: selectedMeds.toList(),
                              pharmacistNote: noteCtrl.text,
                              pharmacistName: pharmacist,
                            );
                            if (!modalCtx.mounted) return;
                            Navigator.of(modalCtx).pop();
                            if (!context.mounted) return;
                            AppFeedback.showSuccess(
                              context,
                              'Resep ${req.id} disetujui! Pasien kini dapat memesan obat.',
                            );
                          },
                          child: const Text('Setujui Resep'),
                        ),
                      ),
                    ],
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
    final consultService = ConsultationService();
    final medService = MedicineService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Validasi Resep & Konsultasi'),
          bottom: const TabBar(
            labelColor: AppColors.cyan,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.cyan,
            tabs: [
              Tab(text: 'Validasi Resep'),
              Tab(text: 'Chat Pasien'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([consultService, medService]),
          builder: (context, _) {
            return TabBarView(
              children: [
                // Tab Validasi Resep
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: consultService.prescriptions.length,
                  itemBuilder: (context, index) {
                    final req = consultService.prescriptions[index];
                    final medNames = req.approvedMedicineIds
                        .map((id) =>
                            medService.getMedicineByIdSync(id)?.name ?? id)
                        .join(', ');
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
                                  '${req.id} • ${req.userName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                req.status.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: req.status.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${req.doctorName} (${req.clinicName})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            req.notes,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Obat: $medNames',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.cyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cyan,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => _showValidateModal(context, req),
                              icon: const Icon(Icons.verified_outlined, size: 18),
                              label: Text(
                                req.status == PrescriptionStatus.pending
                                    ? 'Periksa & Validasi Resep'
                                    : 'Ubah Hasil Validasi',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Tab Chat Pasien
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: consultService.threads.length,
                  itemBuilder: (context, index) {
                    final t = consultService.threads[index];
                    final last = t.lastMessage;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.green.withValues(alpha: 0.12),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.green,
                          ),
                        ),
                        title: Text(
                          '${t.userName} — ${t.topic}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          last?.text ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Icon(
                          t.isResolved
                              ? Icons.check_circle_rounded
                              : Icons.mark_chat_unread_rounded,
                          color:
                              t.isResolved ? AppColors.green : AppColors.cyan,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ConsultationChatScreen(
                                threadId: t.id,
                                senderRole: 'apoteker',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Tab 3: Manajemen Pesanan Masuk & Stok Obat ──────────────────────────────
class _ApotekerOrdersStockTab extends StatelessWidget {
  const _ApotekerOrdersStockTab();

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();
    final medService = MedicineService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Pesanan & Stok Obat'),
          bottom: const TabBar(
            labelColor: AppColors.cyan,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.cyan,
            tabs: [
              Tab(text: 'Penyiapan Pesanan'),
              Tab(text: 'Stok Obat'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([orderService, medService]),
          builder: (context, _) {
            final orders = orderService.orders;
            final meds = medService.medicinesList;

            return TabBarView(
              children: [
                // Sub-tab Pesanan
                ListView.builder(
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
                                  o.id,
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
                                  color:
                                      o.orderStatus.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  o.orderStatus.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: o.orderStatus.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...o.items.map(
                            (it) => Text(
                              '• ${it.medicineName} (${it.quantity}x ${it.unit})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${o.pickupMethod.label} • ${o.paymentStatus.label} (${formatRupiah(o.total)})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (o.orderStatus == OrderStatus.pending ||
                              o.orderStatus == OrderStatus.processing) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (o.orderStatus == OrderStatus.pending)
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.cyan,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        orderService.updatePaymentStatus(
                                          o.id,
                                          PaymentStatus.paid,
                                        );
                                        AppFeedback.showSuccess(
                                          context,
                                          'Pembayaran diverifikasi, pesanan mulai diproses.',
                                        );
                                      },
                                      child: const Text('Proses Racik/Obat'),
                                    ),
                                  ),
                                if (o.orderStatus == OrderStatus.processing)
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        final next = o.pickupMethod ==
                                                PickupMethod.pickup
                                            ? OrderStatus.ready
                                            : OrderStatus.shipping;
                                        orderService.updateOrderStatus(
                                          o.id,
                                          next,
                                        );
                                        AppFeedback.showSuccess(
                                          context,
                                          'Obat selesai disiapkan (${next.label}).',
                                        );
                                      },
                                      child: Text(
                                        o.pickupMethod == PickupMethod.pickup
                                            ? 'Tandai Siap Diambil'
                                            : 'Serahkan ke Kurir',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),

                // Sub-tab Stok Obat
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: meds.length,
                  itemBuilder: (context, index) {
                    final m = meds[index];
                    final isLow = m.stock <= 20;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isLow ? AppColors.error : AppColors.border,
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
                                  '${m.category} • ${m.formattedPrice}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Stok: ${m.stock}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isLow ? AppColors.error : AppColors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Tambah 10 Stok',
                            onPressed: () {
                              medService.updateStock(m.id, m.stock + 10);
                              AppFeedback.showSuccess(
                                context,
                                'Stok ${m.name} ditambah +10.',
                              );
                            },
                            icon: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.cyan,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Tab 4: Profil Apoteker ──────────────────────────────────────────────────
class _ApotekerProfileTab extends StatelessWidget {
  const _ApotekerProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profil Apoteker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.cyan.withValues(alpha: 0.15),
              child: const Icon(
                Icons.medical_services_rounded,
                size: 44,
                color: AppColors.cyan,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.name ?? 'Apoteker',
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
                color: AppColors.cyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Role: Apoteker',
                style: TextStyle(
                  color: AppColors.cyan,
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
              leading: const Icon(Icons.lock_outline, color: AppColors.cyan),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
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
