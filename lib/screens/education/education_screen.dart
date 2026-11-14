import 'package:flutter/material.dart';

import '../../models/informasi.dart';
import '../../services/informasi_service.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';
import 'informasi_detail_screen.dart';

class EducationScreen extends StatefulWidget {
  EducationScreen({
    super.key,
    required this.isActive,
    InformasiService? informationService,
  }) : informationService = informationService ?? InformasiService();

  final bool isActive;
  final InformasiService informationService;

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final _searchController = TextEditingController();
  List<Informasi> _articles = const [];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  @override
  void didUpdateWidget(covariant EducationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadArticles();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final articles = await widget.informationService.fetchArticles();
      if (!mounted) return;
      setState(() {
        _articles = articles;
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = 'Semua';
        }
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  List<String> get _categories {
    final categories =
        _articles
            .map((article) => article.kategori.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['Semua', ...categories];
  }

  List<Informasi> get _filteredArticles {
    final query = _searchQuery.trim().toLowerCase();
    return _articles.where((article) {
      final matchesCategory =
          _selectedCategory == 'Semua' || article.kategori == _selectedCategory;
      final searchable =
          '${article.judul} ${article.ringkasan} ${article.kategori}'
              .toLowerCase();
      return matchesCategory && (query.isEmpty || searchable.contains(query));
    }).toList();
  }

  void _openArticle(Informasi article) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InformasiDetailScreen(
          article: article,
          informationService: widget.informationService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ScreenContent(
    title: 'Edukasi',
    subtitle: 'Artikel pertumbuhan, gizi, dan kesehatan anak.',
    children: [
      TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          hintText: 'Cari artikel edukasi',
          suffixIcon: IconButton(
            tooltip: 'Muat ulang artikel',
            onPressed: _loading ? null : _loadArticles,
            icon: const Icon(Icons.refresh_rounded),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      const SizedBox(height: 16),
      if (_loading)
        const SurfaceCard(
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Expanded(child: Text('Memuat artikel edukasi...')),
            ],
          ),
        )
      else if (_error != null)
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Artikel gagal dimuat: $_error',
                style: const TextStyle(color: SG.muted, height: 1.5),
              ),
              TextButton.icon(
                onPressed: _loadArticles,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        )
      else if (_articles.isEmpty)
        const SurfaceCard(
          child: Row(
            children: [
              Icon(Icons.menu_book_outlined, color: SG.primary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Belum ada artikel edukasi. Artikel yang ditambahkan admin akan muncul di sini.',
                  style: TextStyle(color: SG.muted, height: 1.5),
                ),
              ),
            ],
          ),
        )
      else ...[
        const Text(
          'Kategori',
          style: TextStyle(
            color: SG.ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final category in _categories)
              FilterChip(
                label: Text(category),
                selected: category == _selectedCategory,
                onSelected: (_) => setState(() => _selectedCategory = category),
                selectedColor: SG.pale,
                checkmarkColor: SG.primary,
                side: const BorderSide(color: SG.line),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${_filteredArticles.length} artikel',
          style: const TextStyle(color: SG.muted, fontSize: 13),
        ),
        const SizedBox(height: 10),
        if (_filteredArticles.isEmpty)
          const SurfaceCard(
            child: Text(
              'Tidak ada artikel yang cocok. Coba kata kunci atau kategori lain.',
              style: TextStyle(color: SG.muted, height: 1.5),
            ),
          )
        else
          for (final article in _filteredArticles) ...[
            _ArticleCard(article: article, onTap: () => _openArticle(article)),
            const SizedBox(height: 12),
          ],
      ],
    ],
  );
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article, required this.onTap});

  final Informasi article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: SG.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ArticleThumbnail(url: article.thumbnailUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.kategori.toUpperCase(),
                    style: const TextStyle(
                      color: SG.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SG.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.ringkasan,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SG.muted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  if (article.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatArticleDate(article.createdAt!),
                      style: const TextStyle(color: SG.muted, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: SG.muted),
          ],
        ),
      ),
    ),
  );
}

class _ArticleThumbnail extends StatelessWidget {
  const _ArticleThumbnail({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: SizedBox(
      width: 76,
      height: 76,
      child: url == null
          ? const _ArticlePlaceholder()
          : Image.network(
              url!,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
              errorBuilder: (_, _, _) => const _ArticlePlaceholder(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const _ArticlePlaceholder(),
            ),
    ),
  );
}

class _ArticlePlaceholder extends StatelessWidget {
  const _ArticlePlaceholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: SG.pale,
    child: Center(
      child: Icon(Icons.menu_book_outlined, color: SG.primary, size: 28),
    ),
  );
}

String _formatArticleDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
