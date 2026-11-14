import 'package:flutter/material.dart';

import '../../models/informasi.dart';
import '../../services/informasi_service.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';

class InformasiDetailScreen extends StatefulWidget {
  const InformasiDetailScreen({
    super.key,
    required this.article,
    required this.informationService,
  });

  final Informasi article;
  final InformasiService informationService;

  @override
  State<InformasiDetailScreen> createState() => _InformasiDetailScreenState();
}

class _InformasiDetailScreenState extends State<InformasiDetailScreen> {
  late Informasi _article;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final article = await widget.informationService.fetchArticle(
        widget.article.id,
      );
      if (!mounted) return;
      setState(() {
        _article = article;
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Artikel Edukasi')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        if (_article.thumbnailUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                _article.thumbnailUrl!,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                errorBuilder: (_, _, _) => const _ArticleImagePlaceholder(),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const _ArticleImagePlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _article.kategori.toUpperCase(),
                style: const TextStyle(
                  color: SG.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _article.judul,
                style: const TextStyle(
                  color: SG.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              if (_article.createdAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  _formatArticleDate(_article.createdAt!),
                  style: const TextStyle(color: SG.muted, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_loading)
          const LinearProgressIndicator()
        else if (_error != null)
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Isi artikel gagal dimuat: $_error',
                  style: const TextStyle(color: SG.muted, height: 1.5),
                ),
                TextButton.icon(
                  onPressed: _loadArticle,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        SurfaceCard(
          child: Text(
            _article.content?.trim().isNotEmpty == true
                ? _article.content!
                : _article.ringkasan,
            style: const TextStyle(color: SG.ink, fontSize: 14, height: 1.65),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Informasi ini bersifat edukatif dan bukan pengganti konsultasi tenaga kesehatan.',
          style: TextStyle(color: SG.muted, fontSize: 12, height: 1.5),
        ),
      ],
    ),
  );
}

class _ArticleImagePlaceholder extends StatelessWidget {
  const _ArticleImagePlaceholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: SG.pale,
    child: Center(
      child: Icon(Icons.menu_book_outlined, color: SG.primary, size: 40),
    ),
  );
}

String _formatArticleDate(DateTime date) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
