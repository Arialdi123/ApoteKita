import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/auth_widgets.dart';
import '../user/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _emailKey = GlobalKey();
  final GlobalKey _phoneKey = GlobalKey();
  final GlobalKey _passwordKey = GlobalKey();
  final GlobalKey _confirmKey = GlobalKey();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String _loadingMessage = 'Mendaftarkan akun...';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    // Auto-scroll saat input aktif/mendapat fokus agar keyboard tidak menutupi field
    _nameFocus.addListener(() {
      if (_nameFocus.hasFocus) _scrollToActiveField(_nameKey);
    });
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) _scrollToActiveField(_emailKey);
    });
    _phoneFocus.addListener(() {
      if (_phoneFocus.hasFocus) _scrollToActiveField(_phoneKey);
    });
    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) _scrollToActiveField(_passwordKey);
    });
    _confirmFocus.addListener(() {
      if (_confirmFocus.hasFocus) _scrollToActiveField(_confirmKey);
    });
  }

  void _scrollToActiveField(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.35,
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // ─── Register Form ────────────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Membuat akun Anda...';
    });

    final result = await _authService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _showSuccessDialog();
    } else {
      AppFeedback.showError(
        context,
        result.message ?? 'Pendaftaran gagal. Silakan coba lagi.',
      );
    }
  }

  // ─── Register / Sign In dengan Google ──────────────────────────────────────
  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Menghubungkan ke Google...';
    });

    final result = await _authService.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      AppFeedback.showSuccess(
        context,
        'Selamat datang, ${result.user?.name ?? "Pengguna"}!',
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      if (result.message != null && !result.message!.contains('dibatalkan')) {
        AppFeedback.showError(context, result.message!);
      }
    }
  }

  // ─── Register dengan Nomor HP ─────────────────────────────────────────────
  void _openPhoneAuthSheet() {
    FocusScope.of(context).unfocus();
    PhoneAuthBottomSheet.show(
      context,
      onSuccess: (user) {
        AppFeedback.showSuccess(
          context,
          'Selamat datang! Akun nomor HP berhasil diverifikasi.',
        );
        Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pendaftaran Berhasil!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Akun ApoteKita Anda telah siap digunakan. Silakan masuk untuk menikmati layanan kesehatan terbaik.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Masuk Sekarang',
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Validators ───────────────────────────────────────────────────────────
  String? _validateName(String? val) {
    if (val == null || val.trim().isEmpty) return 'Nama lengkap tidak boleh kosong.';
    if (val.trim().length < 2) return 'Nama minimal 2 karakter.';
    return null;
  }

  String? _validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) return 'Email tidak boleh kosong.';
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(val.trim())) return 'Format email tidak valid.';
    return null;
  }

  String? _validatePhone(String? val) {
    if (val == null || val.trim().isEmpty) return 'Nomor HP tidak boleh kosong.';
    final cleaned = val.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.length < 9 || cleaned.length > 15) {
      return 'Nomor HP tidak valid (9-15 digit).';
    }
    return null;
  }

  String? _validatePassword(String? val) {
    if (val == null || val.isEmpty) return 'Password tidak boleh kosong.';
    if (val.length < 6) return 'Password minimal 6 karakter.';
    return null;
  }

  String? _validateConfirmPassword(String? val) {
    if (val == null || val.isEmpty) return 'Konfirmasi password tidak boleh kosong.';
    if (val != _passwordController.text) return 'Konfirmasi password tidak cocok.';
    return null;
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AuthLoadingOverlay(
      isLoading: _isLoading,
      message: _loadingMessage,
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Daftar Akun',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ApoteKitaLogo(size: 64, showText: false),
                        const SizedBox(height: 8),
                        const Text(
                          'Daftar di ApoteKita',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Lengkapi data untuk mendapatkan kemudahan berbelanja obat',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Form Card ───────────────────────────────────────
                        _buildFormCard(),

                        const SizedBox(height: 20),

                        // ── Divider ─────────────────────────────────────────
                        _buildDivider(),

                        const SizedBox(height: 18),

                        // ── Tombol Google Sign-In ───────────────────────────
                        GoogleSignInButton(
                          onPressed: _handleGoogleSignIn,
                          label: 'Daftar dengan Google',
                        ),

                        const SizedBox(height: 12),

                        // ── Tombol Phone Auth ───────────────────────────────
                        PhoneSignInButton(
                          onPressed: _openPhoneAuthSheet,
                        ),

                        const SizedBox(height: 24),

                        // ── Link Login ──────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah punya akun? ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(4),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                child: Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: AppColors.cyan,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nama Lengkap
          Container(
            key: _nameKey,
            child: AppTextField(
              label: 'Nama Lengkap',
              hint: 'Contoh: Budi Santoso',
              controller: _nameController,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              focusNode: _nameFocus,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_emailFocus),
              prefixIcon:
                  const Icon(Icons.person_outline, color: AppColors.cyan),
              validator: _validateName,
            ),
          ),

          const SizedBox(height: 14),

          // Email
          Container(
            key: _emailKey,
            child: AppTextField(
              label: 'Email',
              hint: 'nama@email.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              focusNode: _emailFocus,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_phoneFocus),
              prefixIcon:
                  const Icon(Icons.email_outlined, color: AppColors.cyan),
              validator: _validateEmail,
            ),
          ),

          const SizedBox(height: 14),

          // Nomor HP
          Container(
            key: _phoneKey,
            child: AppTextField(
              label: 'Nomor HP',
              hint: '08123456789',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              focusNode: _phoneFocus,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_passwordFocus),
              prefixIcon:
                  const Icon(Icons.phone_outlined, color: AppColors.cyan),
              validator: _validatePhone,
            ),
          ),

          const SizedBox(height: 14),

          // Password
          Container(
            key: _passwordKey,
            child: AppTextField(
              label: 'Password',
              hint: 'Minimal 6 karakter',
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              focusNode: _passwordFocus,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_confirmFocus),
              prefixIcon:
                  const Icon(Icons.lock_outline, color: AppColors.cyan),
              validator: _validatePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Konfirmasi Password
          Container(
            key: _confirmKey,
            child: AppTextField(
              label: 'Konfirmasi Password',
              hint: 'Ulangi password Anda',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              focusNode: _confirmFocus,
              onFieldSubmitted: (_) => _handleRegister(),
              prefixIcon:
                  const Icon(Icons.lock_outline, color: AppColors.cyan),
              validator: _validateConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Tombol Daftar
          GradientButton(
            label: 'Daftar Akun',
            isLoading: false,
            onPressed: _handleRegister,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: Color(0xFFE2E8F0),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'atau daftar dengan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Color(0xFFE2E8F0),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
