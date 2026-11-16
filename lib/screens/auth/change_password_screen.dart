import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _oldFocus = FocusNode();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _oldFocus.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // ─── Save ─────────────────────────────────────────────────────────────────
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Password berhasil diubah.'),
            ],
          ),
          backgroundColor: AppColors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(result.message ?? 'Terjadi kesalahan.'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ─── Validators ───────────────────────────────────────────────────────────
  String? _validateOldPassword(String? val) {
    if (val == null || val.isEmpty) return 'Password lama tidak boleh kosong.';
    return null;
  }

  String? _validateNewPassword(String? val) {
    if (val == null || val.isEmpty) return 'Password baru tidak boleh kosong.';
    if (val.length < 6) return 'Password baru minimal 6 karakter.';
    if (val == _oldPasswordController.text) {
      return 'Password baru harus berbeda dari password lama.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? val) {
    if (val == null || val.isEmpty) return 'Konfirmasi password tidak boleh kosong.';
    if (val != _newPasswordController.text) return 'Password tidak sama.';
    return null;
  }

  // ─── Build ────────────────────────────────────────────────────────────────
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
          'Ubah Password',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Ilustrasi header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.green.withValues(alpha: 0.12),
                              AppColors.cyan.withValues(alpha: 0.12),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_person_outlined,
                          size: 48,
                          color: AppColors.green,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Buat Password Baru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Password baru minimal 6 karakter dan berbeda dari password lama.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Form Card ───────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Password Lama
                          AppTextField(
                            label: 'Password Lama',
                            hint: 'Masukkan password saat ini',
                            controller: _oldPasswordController,
                            obscureText: _obscureOld,
                            textInputAction: TextInputAction.next,
                            focusNode: _oldFocus,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_newFocus),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.cyan),
                            validator: _validateOldPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureOld
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscureOld = !_obscureOld),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Divider tipis
                          const Divider(color: AppColors.border),

                          const SizedBox(height: 14),

                          // Password Baru
                          AppTextField(
                            label: 'Password Baru',
                            hint: 'Minimal 6 karakter',
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            textInputAction: TextInputAction.next,
                            focusNode: _newFocus,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_confirmFocus),
                            prefixIcon: const Icon(Icons.lock_reset_rounded,
                                color: AppColors.cyan),
                            validator: _validateNewPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNew
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Konfirmasi Password Baru
                          AppTextField(
                            label: 'Konfirmasi Password Baru',
                            hint: 'Ulangi password baru',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            focusNode: _confirmFocus,
                            onFieldSubmitted: (_) => _handleSave(),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.cyan),
                            validator: _validateConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Tombol Simpan
                          GradientButton(
                            label: 'Simpan Password',
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _handleSave,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
