import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../models/consultation.dart';
import '../../models/medicine.dart';
import '../../services/auth_service.dart';
import '../../services/consultation_service.dart';
import '../../services/medicine_service.dart';
import '../../services/cart_service.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/order_widgets.dart';

/// Tab Konsultasi & Resep Obat untuk Pengguna (terhubung langsung ke Dashboard Apoteker)
class UserConsultationTab extends StatelessWidget {
  const UserConsultationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Resep & Konsultasi',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          automaticallyImplyLeading: false,
          actions: const [
            CartBadgeIcon(),
            SizedBox(width: 8),
          ],
          bottom: const TabBar(
            labelColor: AppColors.green,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.green,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: [
              Tab(text: 'Chat Apoteker'),
              Tab(text: 'Validasi Resep'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UserChatListSection(),
            _UserPrescriptionSection(),
          ],
        ),
      ),
    );
  }
}

// ─── Bagian 1: Daftar Chat Konsultasi dengan Apoteker ─────────────────────────
class _UserChatListSection extends StatelessWidget {
  const _UserChatListSection();

  void _showNewChatSheet(BuildContext context) {
    final topicCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Mulai Konsultasi Baru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tanyakan dosis, aturan pakai, atau keluhan Anda kepada Apoteker kami.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: topicCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Topik Konsultasi',
                    hintText: 'Misal: Dosis obat batuk anak',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Topik wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: msgCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Pertanyaan / Keluhan',
                    hintText: 'Tuliskan pertanyaan Anda untuk Apoteker...',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Pertanyaan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final user = AuthService().currentUser;
                      final thread = await ConsultationService().createThread(
                        userId: user?.id ?? 'dev-001',
                        userName: user?.name ?? 'Pengguna',
                        topic: topicCtrl.text,
                        firstMessage: msgCtrl.text,
                      );
                      if (!sheetCtx.mounted) return;
                      Navigator.of(sheetCtx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConsultationChatScreen(
                            threadId: thread.id,
                            senderRole: 'user',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Kirim & Buka Chat'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = ConsultationService();
    final user = AuthService().currentUser;

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final threads = service.getThreadsForUser(user?.id ?? 'dev-001');

        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_user_chat',
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            onPressed: () => _showNewChatSheet(context),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text(
              'Tanya Apoteker',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: threads.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Belum ada riwayat konsultasi.\nTekan "Tanya Apoteker" untuk memulai chat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: threads.length,
                  itemBuilder: (context, index) {
                    final t = threads[index];
                    final last = t.lastMessage;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.cyan.withValues(alpha: 0.12),
                          child: const Icon(
                            Icons.medical_information_rounded,
                            color: AppColors.cyan,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.topic,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: (t.isResolved
                                        ? AppColors.green
                                        : AppColors.cyan)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                t.isResolved ? 'Selesai' : 'Aktif',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: t.isResolved
                                      ? AppColors.green
                                      : AppColors.cyan,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            last != null
                                ? '${last.senderRole == 'apoteker' ? 'Apoteker: ' : 'Anda: '}${last.text}'
                                : 'Belum ada pesan',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ConsultationChatScreen(
                                threadId: t.id,
                                senderRole: 'user',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

// ─── Bagian 2: Pengajuan & Validasi Resep Obat ───────────────────────────────
class _UserPrescriptionSection extends StatelessWidget {
  const _UserPrescriptionSection();

  void _showSubmitPrescriptionSheet(BuildContext context) {
    final doctorCtrl = TextEditingController();
    final clinicCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final selectedMedIds = <String>{};
    final medicines = MedicineService().medicinesList;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
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
                      'Unggah / Ajukan Resep Obat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Resep akan diperiksa oleh Apoteker sebelum obat dapat di-checkout.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: doctorCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Dokter Penulis Resep',
                        hintText: 'Contoh: dr. Andi Pratama',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama dokter wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: clinicCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Asal RS / Klinik',
                        hintText: 'Contoh: Klinik Sehat Utama',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama klinik/RS wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Rincian Resep / Keluhan',
                        hintText: 'Tulis obat & dosis pada lembar resep...',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Rincian resep wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Pilih Obat yang Tertera di Resep:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: medicines.map((Medicine m) {
                        final selected = selectedMedIds.contains(m.id);
                        return FilterChip(
                          label: Text(
                            m.name,
                            style: TextStyle(
                              fontSize: 11,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          selected: selected,
                          selectedColor: AppColors.green,
                          checkmarkColor: Colors.white,
                          onSelected: (val) {
                            setModalState(() {
                              if (val) {
                                selectedMedIds.add(m.id);
                              } else {
                                selectedMedIds.remove(m.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          if (selectedMedIds.isEmpty) {
                            AppFeedback.showError(
                              context,
                              'Pilih minimal 1 obat yang diajukan pada resep.',
                            );
                            return;
                          }
                          final user = AuthService().currentUser;
                          await ConsultationService().submitPrescription(
                            userId: user?.id ?? 'dev-001',
                            userName: user?.name ?? 'Pengguna',
                            doctorName: doctorCtrl.text,
                            clinicName: clinicCtrl.text,
                            notes: notesCtrl.text,
                            requestedMedicineIds: selectedMedIds.toList(),
                          );
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).pop();
                          AppFeedback.showSuccess(
                            context,
                            'Resep berhasil dikirim! Menunggu validasi Apoteker.',
                          );
                        },
                        icon: const Icon(Icons.upload_file_rounded, size: 18),
                        label: const Text('Kirim Resep ke Apoteker'),
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

  void _orderApprovedPrescription(
    BuildContext context,
    PrescriptionRequest req,
  ) {
    final medService = MedicineService();
    final cart = CartService();
    int addedCount = 0;

    for (final medId in req.approvedMedicineIds) {
      final med = medService.getMedicineByIdSync(medId);
      if (med != null && med.stock > 0) {
        final res = cart.addToCart(med, quantity: 1);
        if (res.success) addedCount++;
      }
    }

    if (addedCount > 0) {
      ConsultationService().markPrescriptionOrdered(req.id);
      AppFeedback.showSuccess(
        context,
        '$addedCount obat resep ditambahkan ke keranjang!',
      );
      Navigator.of(context).pushNamed(AppRoutes.cart);
    } else {
      AppFeedback.showError(
        context,
        'Stok obat pada resep ini sedang kosong.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ConsultationService();
    final medService = MedicineService();
    final user = AuthService().currentUser;

    return ListenableBuilder(
      listenable: Listenable.merge([service, medService]),
      builder: (context, _) {
        final list = service.getPrescriptionsForUser(user?.id ?? 'dev-001');

        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_user_presc',
            backgroundColor: AppColors.cyan,
            foregroundColor: Colors.white,
            onPressed: () => _showSubmitPrescriptionSheet(context),
            icon: const Icon(Icons.assignment_add),
            label: const Text(
              'Unggah Resep',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: list.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada pengajuan resep obat.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final req = list[index];
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
                                  req.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: req.status.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      req.status.icon,
                                      size: 13,
                                      color: req.status.color,
                                    ),
                                    const SizedBox(width: 4),
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${req.doctorName} • ${req.clinicName}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
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
                          if (medNames.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Obat: $medNames',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cyan,
                              ),
                            ),
                          ],
                          if (req.pharmacistNote.isNotEmpty) ...[
                            const Divider(height: 18, color: AppColors.border),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Catatan Apoteker (${req.validatedBy ?? "Apoteker"}):\n${req.pharmacistNote}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                          if (req.status == PrescriptionStatus.approved) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: req.isOrdered
                                    ? null
                                    : () => _orderApprovedPrescription(
                                          context,
                                          req,
                                        ),
                                icon: Icon(
                                  req.isOrdered
                                      ? Icons.check_circle_rounded
                                      : Icons.add_shopping_cart_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  req.isOrdered
                                      ? 'Sudah Dimasukkan ke Keranjang'
                                      : 'Pesan Obat Resep Sekarang',
                                ),
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

// ─── Layar Ruang Chat Konsultasi (Dipakai Bersama oleh Pengguna & Apoteker) ───
class ConsultationChatScreen extends StatefulWidget {
  final String threadId;
  final String senderRole; // 'user' atau 'apoteker'

  const ConsultationChatScreen({
    super.key,
    required this.threadId,
    required this.senderRole,
  });

  @override
  State<ConsultationChatScreen> createState() => _ConsultationChatScreenState();
}

class _ConsultationChatScreenState extends State<ConsultationChatScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final user = AuthService().currentUser;
    _msgController.clear();

    await ConsultationService().sendMessage(
      threadId: widget.threadId,
      senderId: user?.id ?? widget.senderRole,
      senderName: user?.name ??
          (widget.senderRole == 'apoteker' ? 'Apoteker' : 'Pengguna'),
      senderRole: widget.senderRole,
      text: text,
    );

    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ConsultationService();

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final thread = service.getThreadById(widget.threadId);
        if (thread == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Konsultasi')),
            body: const Center(child: Text('Percakapan tidak ditemukan.')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.topic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.senderRole == 'apoteker'
                      ? 'Pasien: ${thread.userName}'
                      : 'Konsultasi dengan Apoteker ApoteKita',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              if (widget.senderRole == 'apoteker')
                TextButton(
                  onPressed: () {
                    service.toggleThreadResolved(
                      thread.id,
                      !thread.isResolved,
                    );
                  },
                  child: Text(
                    thread.isResolved ? 'Buka Lagi' : 'Tandai Selesai',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: thread.messages.length,
                  itemBuilder: (context, index) {
                    final m = thread.messages[index];
                    final isMe = m.senderRole == widget.senderRole;
                    final timeStr =
                        '${m.sentAt.hour.toString().padLeft(2, '0')}:${m.sentAt.minute.toString().padLeft(2, '0')}';

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.green : AppColors.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 16),
                          ),
                          border: isMe
                              ? null
                              : Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.senderName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isMe
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : AppColors.cyan,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              m.text,
                              style: TextStyle(
                                fontSize: 13,
                                color: isMe
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe
                                      ? Colors.white.withValues(alpha: 0.75)
                                      : AppColors.textHint,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: 'Tulis balasan...',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _send,
                        icon: const Icon(Icons.send_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
