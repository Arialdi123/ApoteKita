import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/medicine.dart';
import '../../data/interaction_data.dart';
import '../../services/medicine_service.dart';
import '../../widgets/catalog_widgets.dart';
import '../../widgets/app_widgets.dart';

/// Halaman Simulasi Cek Interaksi Obat.
/// Hanya untuk edukasi — bukan pengganti konsultasi profesional.
class DrugInteractionScreen extends StatefulWidget {
  const DrugInteractionScreen({super.key});

  @override
  State<DrugInteractionScreen> createState() => _DrugInteractionScreenState();
}

class _DrugInteractionScreenState extends State<DrugInteractionScreen> {
  List<Medicine> _allMedicines = [];
  Medicine? _medicine1;
  Medicine? _medicine2;
  DrugInteraction? _interactionResult;
  bool _hasChecked = false;
  bool _isLoading = true;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    final medicines = await MedicineService().getMedicines();
    if (!mounted) return;
    setState(() {
      _allMedicines = medicines;
      _isLoading = false;
    });
  }

  Future<void> _checkInteraction() async {
    if (_medicine1 == null || _medicine2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih dua obat terlebih dahulu.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_medicine1!.id == _medicine2!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih dua obat yang berbeda.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isChecking = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final result = findInteraction(_medicine1!.id, _medicine2!.id);
    if (!mounted) return;
    setState(() {
      _interactionResult = result;
      _hasChecked = true;
      _isChecking = false;
    });
  }

  void _reset() {
    setState(() {
      _medicine1 = null;
      _medicine2 = null;
      _interactionResult = null;
      _hasChecked = false;
    });
  }

  Future<void> _showMedicinePicker({required bool isFirst}) async {
    final selected = await showModalBottomSheet<Medicine>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MedicinePickerSheet(
        medicines: _allMedicines,
        excluded: isFirst ? _medicine2 : _medicine1,
      ),
    );
    if (selected == null) return;
    setState(() {
      if (isFirst) {
        _medicine1 = selected;
      } else {
        _medicine2 = selected;
      }
      _hasChecked = false;
      _interactionResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Cek Interaksi Obat',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.green))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Intro ──────────────────────────────────────────────
                    _buildIntroCard(),

                    const SizedBox(height: 20),

                    // ── Pilih Obat 1 ───────────────────────────────────────
                    const Text(
                      'Pilih Obat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildMedicineSelector(
                      label: 'Obat Pertama',
                      medicine: _medicine1,
                      onTap: () => _showMedicinePicker(isFirst: true),
                    ),

                    const SizedBox(height: 12),

                    // Ikon swap di tengah
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.compare_arrows_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildMedicineSelector(
                      label: 'Obat Kedua',
                      medicine: _medicine2,
                      onTap: () => _showMedicinePicker(isFirst: false),
                    ),

                    const SizedBox(height: 24),

                    // ── Tombol Cek ─────────────────────────────────────────
                    GradientButton(
                      label: 'Cek Interaksi',
                      isLoading: _isChecking,
                      onPressed: (_medicine1 != null && _medicine2 != null)
                          ? _checkInteraction
                          : null,
                    ),

                    if (_hasChecked) ...[
                      const SizedBox(height: 24),

                      // ── Hasil Interaksi ────────────────────────────────
                      _buildInteractionResult(),
                    ],

                    const SizedBox(height: 24),

                    // ── Disclaimer ────────────────────────────────────────
                    _buildDisclaimer(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cyan.withValues(alpha: 0.08),
            AppColors.green.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.science_outlined, color: AppColors.cyan, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulasi Interaksi Obat',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyan,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Pilih dua obat untuk melihat potensi interaksi berdasarkan data simulasi edukasi.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineSelector({
    required String label,
    required Medicine? medicine,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: medicine != null ? AppColors.cyan : AppColors.border,
            width: medicine != null ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: medicine != null
                    ? AppColors.cyan.withValues(alpha: 0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                medicine != null
                    ? Icons.medication_rounded
                    : Icons.add_circle_outline_rounded,
                color: medicine != null
                    ? AppColors.cyan
                    : AppColors.textHint,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    medicine?.name ?? 'Ketuk untuk memilih obat',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: medicine != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                  if (medicine != null)
                    Text(
                      medicine.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionResult() {
    if (_interactionResult == null) {
      // Tidak ada dalam database simulasi
      return _buildResultCard(
        level: InteractionLevel.none,
        isNotInDatabase: true,
        medicine1: _medicine1!,
        medicine2: _medicine2!,
        description:
            'Tidak ditemukan data interaksi antara ${_medicine1!.name} dan ${_medicine2!.name} dalam database simulasi kami.',
        recommendation:
            'Meskipun tidak ada data interaksi dalam simulasi ini, selalu konsultasikan dengan apoteker atau dokter sebelum menggunakan obat bersamaan.',
      );
    }

    return _buildResultCard(
      level: _interactionResult!.level,
      medicine1: _medicine1!,
      medicine2: _medicine2!,
      description: _interactionResult!.description,
      recommendation: _interactionResult!.recommendation,
    );
  }

  Widget _buildResultCard({
    required InteractionLevel level,
    required Medicine medicine1,
    required Medicine medicine2,
    required String description,
    required String recommendation,
    bool isNotInDatabase = false,
  }) {
    Color color;
    IconData icon;
    String statusLabel;
    LinearGradient gradient;

    switch (level) {
      case InteractionLevel.none:
        color = AppColors.green;
        icon = Icons.check_circle_rounded;
        statusLabel = isNotInDatabase
            ? 'Tidak Ada Data Interaksi'
            : 'Tidak Ada Interaksi Signifikan';
        gradient = LinearGradient(colors: [
          AppColors.green.withValues(alpha: 0.08),
          AppColors.green.withValues(alpha: 0.03),
        ]);
      case InteractionLevel.caution:
        color = const Color(0xFFFF9800);
        icon = Icons.warning_rounded;
        statusLabel = 'Perlu Perhatian';
        gradient = LinearGradient(colors: [
          const Color(0xFFFF9800).withValues(alpha: 0.08),
          const Color(0xFFFF9800).withValues(alpha: 0.03),
        ]);
      case InteractionLevel.moderate:
        color = AppColors.error;
        icon = Icons.dangerous_rounded;
        statusLabel = 'Potensi Interaksi Berbahaya';
        gradient = LinearGradient(colors: [
          AppColors.error.withValues(alpha: 0.08),
          AppColors.error.withValues(alpha: 0.03),
        ]);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header hasil
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hasil Simulasi',
                        style: TextStyle(
                          fontSize: 11,
                          color: color.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama obat yang dicek
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          medicine1.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, size: 14, color: color),
                      ),
                      Expanded(
                        child: Text(
                          medicine2.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Deskripsi
                const Text(
                  'Keterangan:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 14),

                // Rekomendasi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rekomendasi',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              recommendation,
                              style: TextStyle(
                                fontSize: 12,
                                color: color.withValues(alpha: 0.85),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Reset button
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Cek Ulang'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.cyan,
                  ),
                ),
              ],
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
              'Informasi ini merupakan simulasi untuk tujuan edukasi dan bukan pengganti konsultasi dengan dokter atau apoteker. Selalu berkonsultasi dengan tenaga medis profesional sebelum memutuskan penggunaan obat.',
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
}

// ─── Bottom Sheet Picker Obat ─────────────────────────────────────────────────
class _MedicinePickerSheet extends StatefulWidget {
  final List<Medicine> medicines;
  final Medicine? excluded;

  const _MedicinePickerSheet({
    required this.medicines,
    this.excluded,
  });

  @override
  State<_MedicinePickerSheet> createState() => _MedicinePickerSheetState();
}

class _MedicinePickerSheetState extends State<_MedicinePickerSheet> {
  final _searchCtrl = TextEditingController();
  List<Medicine> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.medicines
        .where((m) => m.id != widget.excluded?.id)
        .toList();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = widget.medicines
          .where((m) => m.id != widget.excluded?.id)
          .where((m) =>
              q.isEmpty ||
              m.name.toLowerCase().contains(q) ||
              m.category.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pilih Obat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari obat...',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppColors.cyan),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.cyan, width: 1.5),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'Obat tidak ditemukan',
                    subtitle: 'Coba kata kunci lain',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, i) {
                      final med = _filtered[i];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                AppColors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.medication_rounded,
                              color: AppColors.green, size: 20),
                        ),
                        title: Text(
                          med.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          med.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppColors.textHint,
                        ),
                        onTap: () => Navigator.of(context).pop(med),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
