import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../models/medicine.dart';
import '../../services/medicine_service.dart';
import '../../widgets/catalog_widgets.dart';
import '../../widgets/order_widgets.dart';

/// Halaman Katalog Obat — tab ke-2 di Bottom Navigation.
/// Mendukung realtime search + filter kategori.
class CatalogScreen extends StatefulWidget {
  /// Jika diberikan, filter kategori ini akan aktif saat halaman dibuka.
  final String? initialCategory;

  const CatalogScreen({super.key, this.initialCategory});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _medicineService = MedicineService();

  List<Medicine> _allMedicines = [];
  List<Medicine> _filteredMedicines = [];
  String _selectedCategory = MedicineCategory.all;
  bool _isLoading = true;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    // Set kategori awal jika diberikan dari luar (misal dari Home)
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    _loadMedicines();

    _searchFocus.addListener(() {
      setState(() => _isSearchFocused = _searchFocus.hasFocus);
    });

    _searchController.addListener(_onSearchChanged);
    _medicineService.addListener(_onRemoteMedicineUpdated);
  }

  @override
  void dispose() {
    _medicineService.removeListener(_onRemoteMedicineUpdated);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onRemoteMedicineUpdated() {
    if (!mounted) return;
    setState(() {
      _allMedicines = List<Medicine>.from(_medicineService.medicinesList);
    });
    _applyFilter();
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    final medicines = await _medicineService.getMedicines();
    if (!mounted) return;
    setState(() {
      _allMedicines = medicines;
      _isLoading = false;
    });
    _applyFilter();
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    _applyFilter();
  }

  void _applyFilter() {
    final result = _medicineService.searchAndFilter(
      source: _allMedicines,
      query: _searchController.text,
      category: _selectedCategory,
    );
    setState(() => _filteredMedicines = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── Search Bar ────────────────────────────────────────────────────
          _buildSearchBar(),

          // ── Category Chips ────────────────────────────────────────────────
          _buildCategoryFilter(),

          // ── Divider ───────────────────────────────────────────────────────
          const Divider(height: 1, color: AppColors.border),

          // ── Medicine Grid ─────────────────────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Katalog Obat',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
      ),
      actions: [
        // Tombol cek interaksi obat
        IconButton(
          tooltip: 'Cek Interaksi Obat',
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.compare_arrows_rounded,
                color: Colors.white, size: 18),
          ),
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.drugInteraction),
        ),
        const CartBadgeIcon(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _isSearchFocused
                  ? AppColors.cyan.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: _isSearchFocused ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: _isSearchFocused ? AppColors.cyan : AppColors.border,
            width: _isSearchFocused ? 1.5 : 1.0,
          ),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Cari nama obat...',
            hintStyle: const TextStyle(
              color: AppColors.textHint,
              fontSize: 14,
            ),
            prefixIcon:
                const Icon(Icons.search_rounded, color: AppColors.cyan),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        color: AppColors.textSecondary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _searchFocus.unfocus();
                    },
                  )
                : null,
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: MedicineCategory.allCategories.length,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = MedicineCategory.allCategories[i];
          return CategoryChip(
            label: cat,
            isSelected: _selectedCategory == cat,
            onTap: () => _onCategorySelected(cat),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      );
    }

    if (_filteredMedicines.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'Obat tidak ditemukan',
        subtitle:
            'Coba gunakan nama atau kata kunci lain.\nPastikan penulisan sudah benar.',
      );
    }

    return Column(
      children: [
        // Info jumlah hasil
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              Text(
                '${_filteredMedicines.length} obat ditemukan',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _filteredMedicines.length,
            itemBuilder: (context, i) {
              final med = _filteredMedicines[i];
              return MedicineCard(
                medicine: med,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.medicineDetail,
                  arguments: med.id,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
