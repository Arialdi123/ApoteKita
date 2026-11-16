import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../services/medicine_service.dart';
import '../../models/medicine.dart';
import '../../data/education_data.dart';
import '../../widgets/catalog_widgets.dart';
import '../../widgets/order_widgets.dart';
import 'catalog_screen.dart';
import 'orders_screen.dart';

// ─── Home User Screen (dengan Bottom Navigation) ──────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Halaman-halaman bottom nav
  // Catatan: CatalogScreen tidak dapat const karena stateful
  final List<Widget> _pages = [
    const _BerandaTab(),
    const CatalogScreen(),
    const OrdersScreen(isTab: true),
    const _PlaceholderTab(
      icon: Icons.support_agent_outlined,
      title: 'Konsultasi',
      subtitle: 'Fitur konsultasi apoteker sedang dalam pengembangan.',
    ),
    const _ProfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Beranda',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.medical_services_outlined),
        activeIcon: Icon(Icons.medical_services_rounded),
        label: 'Katalog',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        activeIcon: Icon(Icons.receipt_long_rounded),
        label: 'Pesanan',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.support_agent_outlined),
        activeIcon: Icon(Icons.support_agent_rounded),
        label: 'Konsultasi',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person_rounded),
        label: 'Profil',
      ),
    ];

    return Container(
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
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: items,
      ),
    );
  }
}

// ─── Tab Beranda ──────────────────────────────────────────────────────────────
class _BerandaTab extends StatefulWidget {
  const _BerandaTab();

  @override
  State<_BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<_BerandaTab> {
  List<Medicine> _popularMeds = [];
  bool _loadingMeds = true;

  // Kategori shortcut di home
  static const _quickCategories = [
    {'label': 'Vitamin', 'icon': Icons.health_and_safety_rounded, 'color': 0xFF4CAF50, 'cat': 'Vitamin'},
    {'label': 'Obat Flu', 'icon': Icons.medical_services_rounded, 'color': 0xFF0CA9BA, 'cat': 'Obat Flu'},
    {'label': 'Obat Demam', 'icon': Icons.thermostat_rounded, 'color': 0xFFFF7043, 'cat': 'Obat Demam'},
    {'label': 'Suplemen', 'icon': Icons.spa_rounded, 'color': 0xFF66BB6A, 'cat': 'Suplemen'},
    {'label': 'Obat Batuk', 'icon': Icons.local_pharmacy_rounded, 'color': 0xFF7B61FF, 'cat': 'Obat Batuk'},
    {'label': 'Pencernaan', 'icon': Icons.medication_rounded, 'color': 0xFFFF9800, 'cat': 'Obat Pencernaan'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPopular();
  }

  Future<void> _loadPopular() async {
    final meds = await MedicineService().getPopularMedicines(limit: 4);
    if (!mounted) return;
    setState(() {
      _popularMeds = meds;
      _loadingMeds = false;
    });
  }

  void _goToCatalogWithFilter(String category) {
    Navigator.of(context).pushNamed(
      AppRoutes.catalog,
      arguments: category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final firstName = user?.name.split(' ').first ?? 'Pengguna';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            floating: true,
            snap: true,
            title: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Apote',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                    ),
                  ),
                  TextSpan(
                    text: 'Kita',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cyan,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary),
                onPressed: () {},
              ),
              const CartBadgeIcon(),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── Sapaan ────────────────────────────────────────────────
                  Text(
                    'Halo, $firstName 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Butuh obat hari ini?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Search Bar (tap → Katalog) ─────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.catalog),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search_rounded, color: AppColors.cyan, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Cari obat, suplemen, atau produk kesehatan...',
                            style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Banner Promo ──────────────────────────────────────────
                  _buildBanner(),

                  const SizedBox(height: 28),

                  // ── Kategori Cepat ────────────────────────────────────────
                  _buildSectionTitle(
                    'Kategori Obat',
                    onSeeAll: () =>
                        Navigator.of(context).pushNamed(AppRoutes.catalog),
                  ),
                  const SizedBox(height: 14),
                  _buildQuickCategories(),

                  const SizedBox(height: 28),

                  // ── Obat Populer ──────────────────────────────────────────
                  _buildSectionTitle(
                    'Obat Populer',
                    onSeeAll: () =>
                        Navigator.of(context).pushNamed(AppRoutes.catalog),
                  ),
                  const SizedBox(height: 14),
                  _buildPopularMeds(),

                  const SizedBox(height: 28),

                  // ── Edukasi ───────────────────────────────────────────────
                  _buildSectionTitle(
                    'Edukasi Obat',
                    onSeeAll: () =>
                        Navigator.of(context).pushNamed(AppRoutes.education),
                  ),
                  const SizedBox(height: 14),
                  _buildEducationSection(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.catalog),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF0CA9BA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Solusi Kesehatan\nAnda di Sini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Temukan obat yang Anda butuhkan dengan mudah.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Jelajahi Katalog →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_pharmacy_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.cyan,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickCategories() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _quickCategories.length,
      itemBuilder: (context, i) {
        final cat = _quickCategories[i];
        final color = Color(cat['color'] as int);
        return GestureDetector(
          onTap: () => _goToCatalogWithFilter(cat['cat'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat['icon'] as IconData,
                      color: color, size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['label'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularMeds() {
    if (_loadingMeds) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.green,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return SizedBox(
      height: 185,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _popularMeds.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final med = _popularMeds[i];
          return MedicineCard(
            medicine: med,
            compact: true,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.medicineDetail,
              arguments: med.id,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEducationSection() {
    // Ambil 3 artikel terbaru
    final articles = dummyArticles.take(3).toList();

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: articles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final art = articles[i];
              return EducationCard(
                id: art.id,
                title: art.title,
                category: art.category,
                summary: art.summary,
                datePublished: art.datePublished,
                iconName: art.iconName,
                compact: true,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.articleDetail,
                  arguments: art.id,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Tab Profil ───────────────────────────────────────────────────────────────
class _ProfilTab extends StatelessWidget {
  const _ProfilTab();

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // ── Avatar ─────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 52,
                  color: AppColors.green,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              user?.name ?? 'Pengguna',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 28),

            // ── Menu Card ──────────────────────────────────────────────────
            _buildMenuCard(context),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.lock_outline,
            label: 'Ubah Password',
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.changePassword),
          ),
          const Divider(height: 1, color: AppColors.border, indent: 56),
          _buildMenuItem(
            icon: Icons.info_outline,
            label: 'Tentang ApoteKita',
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.border, indent: 56),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            label: 'Keluar',
            color: AppColors.error,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: itemColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: itemColor, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: itemColor,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: color != null ? itemColor : AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari ApoteKita?',
          style: TextStyle(color: AppColors.textSecondary),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              await AuthService().logout();
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Placeholder ──────────────────────────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.green.withValues(alpha: 0.1),
                      AppColors.cyan.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 60, color: AppColors.cyan),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '🔧 Fitur sedang dalam pengembangan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
