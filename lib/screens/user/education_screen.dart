import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../data/education_data.dart';
import '../../widgets/catalog_widgets.dart';

/// Halaman daftar artikel edukasi obat.
class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final _searchController = TextEditingController();
  List<EducationArticle> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = List.from(dummyArticles);
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = dummyArticles
          .where((a) =>
              q.isEmpty ||
              a.title.toLowerCase().contains(q) ||
              a.category.toLowerCase().contains(q) ||
              a.summary.toLowerCase().contains(q))
          .toList();
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
          'Edukasi Obat',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // ── Search ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari artikel edukasi...',
                hintStyle: const TextStyle(
                    color: AppColors.textHint, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppColors.cyan),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textSecondary, size: 18),
                        onPressed: _searchController.clear,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
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

          // ── Article List ──────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.article_outlined,
                    title: 'Artikel tidak ditemukan',
                    subtitle: 'Coba kata kunci yang berbeda.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final article = _filtered[i];
                      return EducationCard(
                        id: article.id,
                        title: article.title,
                        category: article.category,
                        summary: article.summary,
                        datePublished: article.datePublished,
                        iconName: article.iconName,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.articleDetail,
                          arguments: article.id,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
