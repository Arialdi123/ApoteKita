import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app/theme.dart';

// ─── Logo ApoteKita (reusable) ────────────────────────────────────────────────
/// Widget logo ApoteKita yang konsisten dengan Splash Screen.
/// [size] mengontrol tinggi huruf K, [showText] menampilkan teks di bawah logo.
class ApoteKitaLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const ApoteKitaLogo({
    super.key,
    this.size = 80,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final logoHeight = size;
    final logoWidth = size * (210 / 150); // Pertahankan rasio dari splash

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: logoWidth,
          height: logoHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // K di kanan
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: SvgPicture.asset(
                  'assets/logo/K.svg',
                  height: logoHeight,
                  fit: BoxFit.contain,
                ),
              ),
              // Plus di tengah (sedikit ke kiri seperti di splash)
              Positioned.fill(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(-(logoWidth * 0.07), 0),
                    child: SvgPicture.asset(
                      'assets/logo/Plus.svg',
                      width: logoHeight * 0.83,
                      height: logoHeight * 0.83,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Apote',
                  style: TextStyle(
                    fontSize: size * 0.28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                    letterSpacing: 0.5,
                  ),
                ),
                TextSpan(
                  text: 'Kita',
                  style: TextStyle(
                    fontSize: size * 0.28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cyan,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Gradient Button ─────────────────────────────────────────────────────────
/// Tombol dengan gradient brand ApoteKita.
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.height = 52,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.reverse();
  void _onTapUp(_) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: widget.onPressed == null || widget.isLoading
                ? const LinearGradient(
                    colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)],
                  )
                : AppColors.brandGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (widget.onPressed != null && !widget.isLoading)
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Custom Text Field ────────────────────────────────────────────────────────
/// TextField yang konsisten dengan design system ApoteKita.
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          focusNode: focusNode,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}
