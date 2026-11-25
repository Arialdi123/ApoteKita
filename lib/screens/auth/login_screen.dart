import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final GlobalKey _emailFieldKey = GlobalKey();
  final GlobalKey _passwordFieldKey = GlobalKey();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _loadingMessage = 'Sedang masuk...';

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

    // Auto-scroll saat input aktif/mendapat fokus agar tidak tertutup keyboard
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        _scrollToActiveField(_emailFieldKey);
      }
    });

    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) {
        _scrollToActiveField(_passwordFieldKey);
      }
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
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ─── Login Email & Password ───────────────────────────────────────────────
  Future<void> _handleEmailLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Memverifikasi akun...';
    });

    final result = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      final role = result.user?.role ?? UserRole.user;
      AppFeedback.showSuccess(
        context,
        'Selamat datang, ${result.user?.name ?? role.label} (${role.label})!',
      );
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.dashboardForRole(role),
          (route) => false,
        );
      }
    } else {
      AppFeedback.showError(
        context,
        result.message ?? 'Terjadi kesalahan saat masuk.',
      );
    }
  }

  void _fillDemoRole(String email) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = '123456';
    });
    _handleEmailLogin();
  }

  // ─── Login dengan Google ──────────────────────────────────────────────────
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
      final role = result.user?.role ?? UserRole.user;
      AppFeedback.showSuccess(
        context,
        'Berhasil masuk sebagai ${result.user?.name ?? "Pengguna"}',
      );
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.dashboardForRole(role),
          (route) => false,
        );
      }
    } else {
      if (result.message != null &&
          !result.message!.contains('dibatalkan')) {
        AppFeedback.showError(context, result.message!);
      }
    }
  }

  // ─── Login dengan Nomor HP (Phone Auth OTP) ──────────────────────────────
  void _openPhoneAuthSheet() {
    FocusScope.of(context).unfocus();
    PhoneAuthBottomSheet.show(
      context,
      onSuccess: (user) {
        AppFeedback.showSuccess(
          context,
          'Selamat datang! Masuk berhasil dengan nomor HP.',
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.dashboardForRole(user.role),
          (route) => false,
        );
      },
    );
  }

  // ─── Validators ───────────────────────────────────────────────────────────
  String? _validateEmail(String? val) {
    if (val == null || val.trim().isEmpty) return 'Email tidak boleh kosong.';
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(val.trim())) return 'Format email tidak valid.';
    return null;
  }

  String? _validatePassword(String? val) {
    if (val == null || val.isEmpty) return 'Password tidak boleh kosong.';
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 36),

                        // ── Logo ApoteKita ──────────────────────────────────
                        const ApoteKitaLogo(size: 85),

                        const SizedBox(height: 24),

                        // ── Judul & Subjudul ────────────────────────────────
                        const Text(
                          'Selamat Datang di ApoteKita',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Akses obat & layanan kesehatan terpercaya',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ── Card Form Utama ─────────────────────────────────
                        _buildFormCard(),

                        const SizedBox(height: 16),

                        // ── Akses Cepat 4 Role ──────────────────────────────
                        _buildQuickRoleSelector(),

                        const SizedBox(height: 20),

                        // ── Garis Pemisah (Divider) ─────────────────────────
                        _buildDivider(),

                        const SizedBox(height: 20),

                        // ── Tombol Google Sign-In ───────────────────────────
                        GoogleSignInButton(
                          onPressed: _handleGoogleSignIn,
                          isLoading: false,
                        ),

                        const SizedBox(height: 12),

                        // ── Tombol Masuk dengan Nomor HP ────────────────────
                        PhoneSignInButton(
                          onPressed: _openPhoneAuthSheet,
                        ),

                        const SizedBox(height: 28),

                        // ── Link Register ───────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Belum punya akun? ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.register),
                              borderRadius: BorderRadius.circular(4),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                child: Text(
                                  'Daftar Sekarang',
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
          // Input Email
          Container(
            key: _emailFieldKey,
            child: AppTextField(
              label: 'Email',
              hint: 'nama@email.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              focusNode: _emailFocus,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_passwordFocus),
              prefixIcon:
                  const Icon(Icons.email_outlined, color: AppColors.cyan),
              validator: _validateEmail,
            ),
          ),

          const SizedBox(height: 16),

          // Input Password
          Container(
            key: _passwordFieldKey,
            child: AppTextField(
              label: 'Password',
              hint: 'Masukkan password Anda',
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              focusNode: _passwordFocus,
              onFieldSubmitted: (_) => _handleEmailLogin(),
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

          const SizedBox(height: 10),

          // Lupa Password
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Navigator.of(context)
                  .pushNamed(AppRoutes.forgotPassword),
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Text(
                  'Lupa Password?',
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Tombol Login Email
          GradientButton(
            label: 'Masuk',
            isLoading: false,
            onPressed: _handleEmailLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRoleSelector() {
    final roles = [
      ('Pengguna', 'user@apotekkita.com', AppColors.green),
      ('Apoteker', 'apoteker@apotekkita.com', AppColors.cyan),
      ('Pegawai', 'pegawai@apotekkita.com', const Color(0xFF7B61FF)),
      ('Admin', 'admin@apotekkita.com', const Color(0xFF1A1A2E)),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masuk Cepat Sesuai Role (Password: 123456)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roles.map((r) {
              return ActionChip(
                backgroundColor: r.$3.withValues(alpha: 0.1),
                side: BorderSide(color: r.$3.withValues(alpha: 0.3)),
                label: Text(
                  r.$1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: r.$3,
                  ),
                ),
                onPressed: () => _fillDemoRole(r.$2),
              );
            }).toList(),
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
            'atau lanjutkan dengan',
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
