import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ─── Controllers ────────────────────────────────────────────────────────────
  late AnimationController _kController;      // FASE 1 : K muncul
  late AnimationController _plusController;   // FASE 2 : Plus masuk dari kiri
  late AnimationController _bounceController; // FASE 3 : logo bounce
  late AnimationController _textController;   // FASE 4 : teks ApoteKita

  // ─── Fase 1 : K fade + scale ─────────────────────────────────────────────
  late Animation<double> _kFade;
  late Animation<double> _kScale;

  // ─── Fase 2 : Plus slide dari kiri + fade ────────────────────────────────
  late Animation<double> _plusSlide;
  late Animation<double> _plusFade;

  // ─── Fase 3 : Bounce keseluruhan logo ────────────────────────────────────
  late Animation<double> _logoScale;

  // ─── Fase 4 : Teks ApoteKita fade + slide dari bawah ─────────────────────
  late Animation<double> _textFade;
  late Animation<double> _textSlide;

  @override
  void initState() {
    super.initState();

    // ── FASE 1: K muncul (700 ms) ──────────────────────────────────────────
    _kController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _kFade = CurvedAnimation(
      parent: _kController,
      curve: Curves.easeOut,
    );

    _kScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _kController, curve: Curves.easeOutBack),
    );

    // ── FASE 2: Plus masuk dari kiri (600 ms) ──────────────────────────────
    _plusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Stack width=210 → center x=105.
    // K (w≈88) di Positioned(right:0) → K center x = 210-44 = 166
    // Plus (w=125) → Plus center final di x≈90 (overlap sepertiga kanan Plus dengan K)
    // Offset dari Stack center: dx = 90 - 105 = -15
    // Tween: begin=-300 (jauh kiri layar) → end=-15 (posisi overlap tepat)
    _plusSlide = Tween<double>(begin: -300.0, end: -15.0).animate(
      CurvedAnimation(parent: _plusController, curve: Curves.easeOutCubic),
    );

    _plusFade = CurvedAnimation(
      parent: _plusController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    // ── FASE 3: Bounce logo (400 ms) ───────────────────────────────────────
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 0.96)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.96, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_bounceController);

    // ── FASE 4: Teks muncul (600 ms) ───────────────────────────────────────
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textFade = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );

    _textSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // ── Jalankan rangkaian animasi secara berurutan ─────────────────────────
    _runAnimationSequence();
  }

  /// Menjalankan semua fase animasi secara berurutan dengan jeda di antara fase.
  Future<void> _runAnimationSequence() async {
    // Jeda singkat agar Flutter selesai render frame pertama
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    // FASE 1 – K muncul
    await _kController.forward();
    if (!mounted) return;

    // Jeda kecil sebelum Plus masuk
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // FASE 2 – Plus masuk dari kiri
    await _plusController.forward();
    if (!mounted) return;

    // Jeda kecil sebelum bounce
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    // FASE 3 – Bounce logo
    await _bounceController.forward();
    if (!mounted) return;

    // Jeda sebelum teks muncul
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // FASE 4 – Teks ApoteKita muncul
    await _textController.forward();
    if (!mounted) return;

    // TAHAN – logo + teks terlihat selama ~1.5 detik
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // ── Navigasi ke HomePage ────────────────────────────────────────────────
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _kController.dispose();
    _plusController.dispose();
    _bounceController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _kController,
            _plusController,
            _bounceController,
            _textController,
          ]),
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ─────────────────────────────────────────────────────────
                // LOGO: K + Plus
                //
                // Analisis target logo:
                //   K   : h=150, w≈88  (K.svg 144×245, center geser kanan)
                //   Plus: 125×125      (besar, hampir setinggi K)
                //   Overlap: Plus di depan K, menutupi bagian kiri-tengah K
                //
                // Stack 220×170, center=(110, 85):
                //   K center: Alignment.centerRight → x≈175, y=85
                //   Plus center final offset(-50, 0) dari Stack center:
                //     → Plus center di (60, 85)
                //     → Plus spans x=(-2.5)–122.5, y=22.5–147.5 (clip.none)
                //     → K spans x≈131–219 (Alignment.centerRight di 220px)
                //       overlap di x=131–122.5 ... hm
                //
                // Pakai pendekatan: K diposisikan Align.centerRight di dalam
                // Positioned.fill, Plus pakai Transform.translate dari center.
                // ─────────────────────────────────────────────────────────
                Transform.scale(
                  scale: _logoScale.value,
                  child: SizedBox(
                    width: 210,
                    height: 170,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ── K.svg — di sisi kanan Stack ──────────────────
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Opacity(
                            opacity: _kFade.value.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: _kScale.value,
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'assets/logo/K.svg',
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        // ── Plus.svg — besar, slide dari kiri ─────────────
                        // Final: center Plus di (62, 85) dari Stack top-left
                        // K width≈88 → K left edge ≈ 210-88=122
                        // Plus (125×125): spans x=0–125 → overlap x=0–125 ∩ x=122: ~3px
                        // Perlu Plus lebih ke kanan: center di ~x=95
                        // Offset dari Stack center (105, 85): dx = 95-105 = -10
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Transform.translate(
                              offset: Offset(_plusSlide.value, 0),
                              child: Opacity(
                                opacity: _plusFade.value.clamp(0.0, 1.0),
                                child: SvgPicture.asset(
                                  'assets/logo/Plus.svg',
                                  width: 125,
                                  height: 125,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ─────────────────────────────────────────────────────────
                // TEKS: ApoteKita
                // ─────────────────────────────────────────────────────────
                Opacity(
                  opacity: _textFade.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, _textSlide.value),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Apote',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4CAF50), // Hijau
                              letterSpacing: 0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Kita',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0CA9BA), // Biru/Cyan
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
