/// Konstanta nama rute untuk navigasi terpusat.
/// Tambahkan rute baru di sini saat fitur baru dibuat.
class AppRoutes {
  AppRoutes._();

  // ─── Phase 1: Authentication ──────────────────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';
  static const String home = '/home';
  static const String profile = '/profile';

  // ─── Phase 2: Katalog & Informasi Obat ────────────────────────────────────
  static const String catalog = '/catalog';
  static const String medicineDetail = '/medicine-detail';
  static const String drugInteraction = '/drug-interaction';
  static const String education = '/education';
  static const String articleDetail = '/article-detail';

  // ─── Phase 3: Pembelian & Pesanan ────────────────────────────────────────
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String orders = '/orders';
  static const String orderDetail = '/order-detail';
}
