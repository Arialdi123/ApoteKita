import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../data/education_data.dart';

/// Halaman detail artikel edukasi.
/// Menerima article ID via route arguments.
class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  static IconData _resolveIcon(String name) {
    const map = {
      'medication': Icons.medication_rounded,
      'local_pharmacy': Icons.local_pharmacy_rounded,
      'home': Icons.home_rounded,
      'health_and_safety': Icons.health_and_safety_rounded,
      'warning': Icons.warning_rounded,
      'biotech': Icons.biotech_rounded,
      'compare_arrows': Icons.compare_arrows_rounded,
      'support_agent': Icons.support_agent_rounded,
    };
    return map[name] ?? Icons.article_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    EducationArticle? article;
    if (id != null) {
      try {
        article = dummyArticles.firstWhere((a) => a.id == id);
      } catch (_) {
        article = null;
      }
    }

    if (article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Artikel tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 16, color: AppColors.textPrimary),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0CA9BA), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _resolveIcon(article.iconName),
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      article.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Judul
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tanggal
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppColors.textHint),
                      const SizedBox(width: 5),
                      Text(
                        article.datePublished,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),

                  // Ringkasan
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      article.summary,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Konten artikel (render markdown sederhana)
                  _buildArticleContent(article.content),

                  const SizedBox(height: 28),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.textHint.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppColors.textHint),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Konten ini disediakan untuk tujuan edukasi. Selalu konsultasikan dengan dokter atau apoteker untuk saran medis yang personal.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Render konten artikel dengan format markdown sederhana.
  /// Bold (**text**) dan heading (**1. Judul**) ditampilkan berbeda.
  Widget _buildArticleContent(String content) {
    final lines = content.trim().split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 10));
        continue;
      }

      // Heading (baris yang dimulai dengan **)
      if (trimmed.startsWith('**') && trimmed.endsWith('**') && trimmed.length > 4) {
        final headingText = trimmed.substring(2, trimmed.length - 2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            headingText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ));
        continue;
      }

      // List item (baris yang dimulai dengan -)
      if (trimmed.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ',
                  style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
              Expanded(
                child: _buildRichText(trimmed.substring(2)),
              ),
            ],
          ),
        ));
        continue;
      }

      // Paragraf biasa
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: _buildRichText(trimmed),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Build rich text dengan bold support (**text**)
  Widget _buildRichText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.7,
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.7,
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.7,
        ),
      ));
    }

    if (spans.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.7,
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}
