import 'package:flutter/material.dart';

import '../../models/informasi.dart';
import '../../services/informasi_service.dart';
import '../../theme/sg_theme.dart';
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
  // 0 = Semua container, 1 = Balita, 2 = T1, 3 = T2, 4 = T3, 5 = Tersimpan
  int _selectedCategory = 0;
  int _selectedPhaseGuide = 0;

  List<Informasi> _articles = const [];
  String? _error;
  bool _loading = true;
  final Set<String> _bookmarkedIds = {};
  final Map<int, int> _containerPageMap = {1: 1, 2: 1, 3: 1, 4: 1};

  /// Jumlah artikel pendamping (di luar artikel utama) per halaman.
  static const int _pageSize = 4;

  /// Jumlah artikel pendamping yang tampil di mode "Semua".
  static const int _previewCount = 2;

  static const List<_PhaseMeta> _phaseMetas = [
    _PhaseMeta(
      categoryIndex: 1,
      shortLabel: 'Balita',
      pillLabel: 'Gizi Balita',
      title: 'Gizi & Pertumbuhan Balita',
      subtitle: 'ASI Eksklusif, MPASI Protein Hewani & Kurva KMS',
      ageTag: '0–59 Bulan',
      icon: Icons.child_care_rounded,
      assetPath: 'assets/images/education/phase_balita.jpg',
      accent: Color(0xFF0F766E),
      badgeBg: Color(0xFFCCFBF1),
      gradientStart: Color(0xFFE6FAF3),
      gradientEnd: Color(0xFFF4FCF9),
      borderColor: Color(0xFFA7F3D0),
    ),
    _PhaseMeta(
      categoryIndex: 2,
      shortLabel: 'Trim 1',
      pillLabel: 'Trimester 1',
      title: 'Ibu Hamil Trimester 1',
      subtitle: 'Organogenesis, Asam Folat 600 mcg & Anti-Mual',
      ageTag: 'Minggu 1–12',
      icon: Icons.spa_rounded,
      assetPath: 'assets/images/education/phase_trim1.jpg',
      accent: Color(0xFFB45309),
      badgeBg: Color(0xFFFEF3C7),
      gradientStart: Color(0xFFFEF6DC),
      gradientEnd: Color(0xFFFFFBF0),
      borderColor: Color(0xFFFDE68A),
    ),
    _PhaseMeta(
      categoryIndex: 3,
      shortLabel: 'Trim 2',
      pillLabel: 'Trimester 2',
      title: 'Ibu Hamil Trimester 2',
      subtitle: 'Cegah Anemia (TTD), Kalsium Tulang & Kalori +300',
      ageTag: 'Minggu 13–27',
      icon: Icons.favorite_rounded,
      assetPath: 'assets/images/education/phase_trim2.jpg',
      accent: Color(0xFF0369A1),
      badgeBg: Color(0xFFE0F2FE),
      gradientStart: Color(0xFFE5F4FD),
      gradientEnd: Color(0xFFF5FAFF),
      borderColor: Color(0xFFBAE6FD),
    ),
    _PhaseMeta(
      categoryIndex: 4,
      shortLabel: 'Trim 3',
      pillLabel: 'Trimester 3',
      title: 'Ibu Hamil Trimester 3',
      subtitle: 'Pematangan Otak (DHA), Protein +30g & Persiapan ASI',
      ageTag: 'Minggu 28–40',
      icon: Icons.psychology_rounded,
      assetPath: 'assets/images/education/phase_trim3.jpg',
      accent: SG.primary,
      badgeBg: SG.pale,
      gradientStart: Color(0xFFFCE8EE),
      gradientEnd: Color(0xFFFFF6F8),
      borderColor: Color(0xFFF4C6D4),
    ),
  ];

  static const List<_NutritionGuide> _guides = [
    _NutritionGuide(
      id: 'balita',
      title: 'Gizi Balita (0–59 Bulan)',
      badge: 'Fokus 1.000 HPK',
      metrics: [
        _GuideMetric(
          label: 'Energi',
          value: '800–1350',
          unit: 'kkal',
          icon: Icons.local_fire_department_rounded,
          bg: Color(0xFFFEF3C7),
          color: Color(0xFFB45309),
        ),
        _GuideMetric(
          label: 'Protein',
          value: '15–25',
          unit: 'g/hr',
          icon: Icons.egg_alt_rounded,
          bg: Color(0xFFE6FAF3),
          color: Color(0xFF0F766E),
        ),
        _GuideMetric(
          label: 'Pola Makan',
          value: '3–4x',
          unit: '+ ASI',
          icon: Icons.restaurant_rounded,
          bg: SG.pale,
          color: SG.primary,
        ),
      ],
      tip: 'Prioritaskan lauk protein hewani (telur, ikan, hati ayam, daging) di setiap jadwal makan utama untuk mencegah stunting.',
    ),
    _NutritionGuide(
      id: 'trimester1',
      title: 'Ibu Hamil Trimester 1',
      badge: 'Minggu 1–12',
      metrics: [
        _GuideMetric(
          label: 'Ekstra Kalori',
          value: '+180',
          unit: 'kkal',
          icon: Icons.bolt_rounded,
          bg: Color(0xFFFEF3C7),
          color: Color(0xFFB45309),
        ),
        _GuideMetric(
          label: 'Asam Folat',
          value: '600',
          unit: 'mcg',
          icon: Icons.spa_rounded,
          bg: Color(0xFFE6FAF3),
          color: Color(0xFF0F766E),
        ),
        _GuideMetric(
          label: 'Zat Besi',
          value: '27',
          unit: 'mg/hr',
          icon: Icons.favorite_rounded,
          bg: SG.pale,
          color: SG.primary,
        ),
      ],
      tip: 'Penuhi asam folat & vitamin B6. Bila mual di pagi hari, ubah jadwal makan menjadi 5–6 porsi kecil tapi sering.',
    ),
    _NutritionGuide(
      id: 'trimester2',
      title: 'Ibu Hamil Trimester 2',
      badge: 'Minggu 13–27',
      metrics: [
        _GuideMetric(
          label: 'Ekstra Kalori',
          value: '+300',
          unit: 'kkal',
          icon: Icons.bolt_rounded,
          bg: Color(0xFFFEF3C7),
          color: Color(0xFFB45309),
        ),
        _GuideMetric(
          label: 'Kalsium',
          value: '1.000',
          unit: 'mg/hr',
          icon: Icons.shield_rounded,
          bg: Color(0xFFE0F2FE),
          color: Color(0xFF0369A1),
        ),
        _GuideMetric(
          label: 'Protein',
          value: '+10',
          unit: 'g/hr',
          icon: Icons.set_meal_rounded,
          bg: Color(0xFFE6FAF3),
          color: Color(0xFF0F766E),
        ),
      ],
      tip: 'Minum 1 Tablet Tambah Darah (TTD) setiap malam bersama air putih atau buah kaya vitamin C (jeda 2 jam dari susu/teh).',
    ),
    _NutritionGuide(
      id: 'trimester3',
      title: 'Ibu Hamil Trimester 3',
      badge: 'Minggu 28–40',
      metrics: [
        _GuideMetric(
          label: 'Ekstra Kalori',
          value: '+300',
          unit: 'kkal',
          icon: Icons.bolt_rounded,
          bg: Color(0xFFFEF3C7),
          color: Color(0xFFB45309),
        ),
        _GuideMetric(
          label: 'Protein',
          value: '+30',
          unit: 'g/hr',
          icon: Icons.egg_rounded,
          bg: SG.pale,
          color: SG.primary,
        ),
        _GuideMetric(
          label: 'Omega-3 DHA',
          value: '200+',
          unit: 'mg/hr',
          icon: Icons.psychology_rounded,
          bg: Color(0xFFE0F2FE),
          color: Color(0xFF0369A1),
        ),
      ],
      tip: 'Tingkatkan konsumsi ikan kembung, telur, dan protein hewani untuk pematangan otak janin serta mencegah BBLR.',
    ),
  ];

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

  /// Menentukan container untuk sebuah artikel berdasarkan kategori & judul.
  /// 1 = Balita, 2 = Trimester 1, 3 = Trimester 2, 4 = Trimester 3.
  /// Mengembalikan null bila artikel bukan untuk balita / ibu hamil
  /// trimester 1–3, sehingga tidak ditampilkan di halaman edukasi ini.
  int? _resolvePhaseIndex(Informasi article) {
    final combined = '${article.kategori} ${article.judul}'.toLowerCase();

    if (RegExp(r'trimester[\s_-]*(3|iii)\b|trim[\s_-]*3\b')
        .hasMatch(combined)) {
      return 4;
    }
    if (RegExp(r'trimester[\s_-]*(2|ii)\b|trim[\s_-]*2\b').hasMatch(combined)) {
      return 3;
    }
    if (RegExp(r'trimester[\s_-]*(1|i)\b|trim[\s_-]*1\b').hasMatch(combined) ||
        combined.contains('awal kehamilan')) {
      return 2;
    }
    if (RegExp(r'balita|bayi|anak|mpasi|stunting|tumbuh kembang|\basi\b')
        .hasMatch(combined)) {
      return 1;
    }
    return null;
  }

  /// Jumlah artikel database yang termasuk 4 kategori edukasi.
  int get _visibleArticleCount =>
      _articles.where((a) => _resolvePhaseIndex(a) != null).length;

  /// Artikel nyata dari database untuk satu fase.
  List<Informasi> _realArticles(int phaseIndex) =>
      _articles.where((a) => _resolvePhaseIndex(a) == phaseIndex).toList();

  _PhaseMeta _metaFor(int phaseIndex) => _phaseMetas.firstWhere(
    (m) => m.categoryIndex == phaseIndex,
    orElse: () => _phaseMetas.first,
  );

  void _selectStoryPhase(int phaseIdx) {
    setState(() {
      _selectedPhaseGuide = phaseIdx - 1;
      _selectedCategory = _selectedCategory == phaseIdx ? 0 : phaseIdx;
    });
  }

  void _selectCategory(int index) {
    setState(() {
      _selectedCategory = index;
      if (index >= 1 && index <= 4) {
        _selectedPhaseGuide = index - 1;
      }
    });
  }

  void _toggleBookmark(String id) {
    setState(() {
      if (!_bookmarkedIds.remove(id)) _bookmarkedIds.add(id);
    });
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
  Widget build(BuildContext context) {
    final activeGuide = _guides[_selectedPhaseGuide];
    final savedArticles = _articles.where((a) {
      return _bookmarkedIds.contains(a.id) && _resolvePhaseIndex(a) != null;
    }).toList();

    return RefreshIndicator(
      color: SG.primary,
      onRefresh: _loadArticles,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _buildCurvedEditorialHero(),
          Transform.translate(
            offset: const Offset(0, -26),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildDailySummaryCard(activeGuide),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEditorialSectionHeader(),
                const SizedBox(height: 12),
                _buildContainerPillSwitcher(),
                const SizedBox(height: 14),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        color: SG.primary,
                        backgroundColor: SG.pale,
                      ),
                    ),
                  ),
                if (_error != null && !_loading) _buildErrorBanner(),
                if (_selectedCategory == 5)
                  _buildSavedContainer(savedArticles)
                else if (_selectedCategory == 0)
                  for (var i = 0; i < _phaseMetas.length; i++) ...[
                    _buildArticleContainer(
                      _phaseMetas[i],
                      isFocusedMode: false,
                    ),
                    if (i != _phaseMetas.length - 1) const SizedBox(height: 16),
                  ]
                else
                  _buildArticleContainer(
                    _metaFor(_selectedCategory),
                    isFocusedMode: true,
                  ),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'Artikel baru dari admin akan otomatis muncul di container fase yang sesuai.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: SG.muted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurvedEditorialHero() {
    final isSavedSelected = _selectedCategory == 5;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C1E3A), SG.primary, Color(0xFFC8103D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -46,
            top: -46,
            child: Container(
              width: 185,
              height: 185,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .10),
                  width: 1.4,
                ),
              ),
            ),
          ),
          Positioned(
            left: -38,
            bottom: 0,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 46),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Action Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .22),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 3.5,
                            backgroundColor: Color(0xFFFFD84D),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'PUSAT EDUKASI 1.000 HPK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              letterSpacing: .5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: _loading ? null : _loadArticles,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .26),
                          ),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _selectCategory(isSavedSelected ? 0 : 5),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSavedSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .26),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bookmarks_rounded,
                              size: 16,
                              color: isSavedSelected
                                  ? SG.primary
                                  : const Color(0xFFFFD84D),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${_bookmarkedIds.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isSavedSelected
                                    ? SG.primary
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Panduan Gizi Keluarga',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih fase di bawah untuk menjelajahi kebutuhan & artikel terverifikasi.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .86),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 18),
                // 4 Interactive Phase Journey Story Bubbles
                Row(
                  children: [
                    for (final meta in _phaseMetas)
                      Expanded(child: _buildStoryBubble(meta)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryBubble(_PhaseMeta meta) {
    final isActive = _selectedPhaseGuide == (meta.categoryIndex - 1);

    return GestureDetector(
      onTap: () => _selectStoryPhase(meta.categoryIndex),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD84D), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isActive ? null : Colors.white.withValues(alpha: .35),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .22),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: SG.primary, width: 2),
                    color: Colors.white,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    meta.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Icon(meta.icon, color: meta.accent, size: 26),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            meta.shortLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive
                  ? const Color(0xFFFFD84D)
                  : Colors.white.withValues(alpha: .92),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorialSectionHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Artikel',
                style: TextStyle(
                  color: SG.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Khusus balita & ibu hamil trimester 1, 2, dan 3',
                style: TextStyle(color: SG.muted, fontSize: 11.5),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: SG.pale,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$_visibleArticleCount Artikel',
            style: const TextStyle(
              color: SG.primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContainerPillSwitcher() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterPill(
            label: 'Semua (4)',
            isSelected: _selectedCategory == 0,
            activeColor: SG.ink,
            onTap: () => _selectCategory(0),
          ),
          const SizedBox(width: 8),
          for (final meta in _phaseMetas) ...[
            _buildFilterPill(
              label: meta.pillLabel,
              icon: meta.icon,
              isSelected: _selectedCategory == meta.categoryIndex,
              activeColor: meta.accent,
              onTap: () => _selectCategory(meta.categoryIndex),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    IconData? icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? activeColor : SG.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : activeColor,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : SG.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RINGKASAN KEBUTUHAN HARIAN
  // ---------------------------------------------------------------------------
  Widget _buildDailySummaryCard(_NutritionGuide guide) {
    final meta = _phaseMetas[_selectedPhaseGuide];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Color.lerp(Colors.white, meta.gradientStart, .55)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: SG.primary.withValues(alpha: .12),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: meta.accent.withValues(alpha: .06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(guide.id),
            child: _buildSummaryContent(guide, meta),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryContent(_NutritionGuide guide, _PhaseMeta meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 11,
                        decoration: BoxDecoration(
                          color: SG.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Flexible(
                        child: Text(
                          'RINGKASAN KEBUTUHAN HARIAN',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: SG.primary,
                            fontSize: 9.5,
                            letterSpacing: .7,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    guide.title,
                    style: const TextStyle(
                      color: SG.ink,
                      fontSize: 17,
                      height: 1.2,
                      letterSpacing: -.3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(9, 6, 11, 6),
              decoration: BoxDecoration(
                color: meta.badgeBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: meta.accent.withValues(alpha: .18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: meta.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    guide.badge,
                    style: TextStyle(
                      color: meta.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < guide.metrics.length; i++) ...[
              Expanded(child: _buildTintedMetricTile(guide.metrics[i])),
              if (i != guide.metrics.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [SG.soft, Colors.white],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SG.line.withValues(alpha: .6)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: SG.pale,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tips_and_updates_rounded,
                  color: SG.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tips Gizi',
                      style: TextStyle(
                        color: SG.primary,
                        fontSize: 10,
                        letterSpacing: .3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      guide.tip,
                      style: const TextStyle(
                        color: SG.ink,
                        fontSize: 11,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTintedMetricTile(_GuideMetric m) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [m.bg, Color.lerp(m.bg, Colors.white, .55)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: .9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: m.color.withValues(alpha: .14),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: m.color.withValues(alpha: .18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(m.icon, size: 17, color: m.color),
          ),
          const SizedBox(height: 10),
          Text(
            m.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SG.muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              m.value,
              style: const TextStyle(
                color: SG.ink,
                fontSize: 17,
                height: 1.2,
                letterSpacing: -.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 7),
          if (m.unit.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: m.color.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                m.unit,
                maxLines: 1,
                style: TextStyle(
                  color: m.color,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            Container(
              width: 20,
              height: 3.5,
              decoration: BoxDecoration(
                color: m.color.withValues(alpha: .55),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTAINER ARTIKEL
  // ---------------------------------------------------------------------------
  Widget _buildArticleContainer(
    _PhaseMeta meta, {
    required bool isFocusedMode,
  }) {
    final realCount = _realArticles(meta.categoryIndex).length;
    final items = _realArticles(meta.categoryIndex);

    final featured = items.isEmpty ? null : items.first;
    final rest = items.length > 1 ? items.sublist(1) : const <Informasi>[];

    final totalPages = rest.isEmpty ? 1 : (rest.length / _pageSize).ceil();
    final safePage = (_containerPageMap[meta.categoryIndex] ?? 1).clamp(
      1,
      totalPages,
    );
    final visibleRest = isFocusedMode
        ? rest.skip((safePage - 1) * _pageSize).take(_pageSize).toList()
        : rest.take(_previewCount).toList();
    final hiddenCount = rest.length - _previewCount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [meta.gradientStart, meta.gradientEnd, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: meta.borderColor),
        boxShadow: [
          BoxShadow(
            color: meta.accent.withValues(alpha: .07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  meta.assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: Colors.white,
                    child: Icon(meta.icon, color: meta.accent, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: meta.badgeBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            meta.ageTag,
                            style: TextStyle(
                              color: meta.accent,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• $realCount Artikel',
                          style: const TextStyle(
                            color: SG.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meta.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SG.ink,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      meta.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: SG.muted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              if (isFocusedMode) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _selectCategory(0),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_fullscreen_rounded,
                      size: 15,
                      color: SG.ink,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (featured != null) _buildFeaturedCard(featured, meta),
          if (featured == null && !_loading && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Belum ada artikel dari database untuk ${meta.title}.',
                style: const TextStyle(
                  color: SG.muted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          for (final a in visibleRest) ...[
            const SizedBox(height: 10),
            _buildCompactRow(a, meta),
          ],
          if (!isFocusedMode && hiddenCount > 0) ...[
            const SizedBox(height: 12),
            _buildSeeAllButton(meta, hiddenCount),
          ],
          if (isFocusedMode && totalPages > 1) ...[
            const SizedBox(height: 14),
            _buildPager(meta, safePage, totalPages, rest.length + 1),
          ],
        ],
      ),
    );
  }

  Widget _buildSeeAllButton(_PhaseMeta meta, int hiddenCount) {
    return InkWell(
      onTap: () => _selectCategory(meta.categoryIndex),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: meta.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lihat $hiddenCount artikel lainnya',
              style: TextStyle(
                color: meta.accent,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 5),
            Icon(Icons.arrow_forward_rounded, size: 14, color: meta.accent),
          ],
        ),
      ),
    );
  }

  Widget _buildPager(_PhaseMeta meta, int page, int totalPages, int total) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Hal. $page / $totalPages ($total artikel)',
            style: const TextStyle(
              color: SG.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _pagerButton(
          meta,
          Icons.chevron_left_rounded,
          page > 1
              ? () => setState(
                  () => _containerPageMap[meta.categoryIndex] = page - 1,
                )
              : null,
        ),
        const SizedBox(width: 8),
        _pagerButton(
          meta,
          Icons.chevron_right_rounded,
          page < totalPages
              ? () => setState(
                  () => _containerPageMap[meta.categoryIndex] = page + 1,
                )
              : null,
        ),
      ],
    );
  }

  Widget _pagerButton(_PhaseMeta meta, IconData icon, VoidCallback? onTap) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? meta.accent : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: enabled ? meta.accent : SG.line),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? Colors.white : SG.muted.withValues(alpha: .5),
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(Informasi article, {double size = 30}) {
    final isBookmarked = _bookmarkedIds.contains(article.id);
    return InkWell(
      onTap: () => _toggleBookmark(article.id),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .92),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          size: size * .57,
          color: isBookmarked ? SG.primary : SG.muted,
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(Informasi article, _PhaseMeta meta) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      elevation: 1.5,
      shadowColor: SG.ink.withValues(alpha: .10),
      child: InkWell(
        onTap: () => _openArticle(article),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ArticleCoverImage(
                    thumbnailUrl: article.thumbnailUrl,
                    meta: meta,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: .38),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      children: [
                        Flexible(
                          child: _coverChip(article.kategori, meta.accent),
                        ),
                        const Spacer(),
                        _buildBookmarkButton(article),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SG.ink,
                      fontSize: 14.5,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    article.ringkasan,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SG.muted,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.createdAt != null
                              ? _formatArticleDate(article.createdAt!)
                              : 'Panduan Gizi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SG.muted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: meta.badgeBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Baca',
                              style: TextStyle(
                                color: meta.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: meta.accent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildCompactRow(Informasi article, _PhaseMeta meta) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openArticle(article),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 78,
                  height: 78,
                  child: _ArticleCoverImage(
                    thumbnailUrl: article.thumbnailUrl,
                    meta: meta,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: meta.badgeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              article.kategori,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: meta.accent,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => _toggleBookmark(article.id),
                          child: Icon(
                            _bookmarkedIds.contains(article.id)
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 18,
                            color: _bookmarkedIds.contains(article.id)
                                ? SG.primary
                                : SG.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      article.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SG.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            article.createdAt != null
                                ? _formatArticleDate(article.createdAt!)
                                : 'Panduan Gizi',
                            style: const TextStyle(
                              color: SG.muted,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                        Text(
                          'Baca →',
                          style: TextStyle(
                            color: meta.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedContainer(List<Informasi> savedArticles) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF4C6D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmarks_rounded, color: SG.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bacaan Tersimpan (${savedArticles.length})',
                  style: const TextStyle(
                    color: SG.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _selectCategory(0),
                child: const Text('Kembali'),
              ),
            ],
          ),
          if (savedArticles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'Belum ada artikel yang disimpan.\nTekan ikon penanda pada artikel untuk menyimpannya.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SG.muted, fontSize: 12, height: 1.4),
                ),
              ),
            )
          else
            for (final a in savedArticles) ...[
              const SizedBox(height: 10),
              _buildCompactRow(a, _metaFor(_resolvePhaseIndex(a) ?? 1)),
            ],
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: SG.pale,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF4C6D4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: SG.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Artikel terbaru belum bisa dimuat. ${_error ?? ''}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: SG.ink, fontSize: 11, height: 1.35),
            ),
          ),
          TextButton(onPressed: _loadArticles, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}

/// Menampilkan foto asli artikel dari database (`thumbnailUrl`),
/// dan otomatis jatuh ke ilustrasi fase bawaan jika kosong atau gagal dimuat.
class _ArticleCoverImage extends StatelessWidget {
  const _ArticleCoverImage({required this.thumbnailUrl, required this.meta});

  final String? thumbnailUrl;
  final _PhaseMeta meta;

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage =
        thumbnailUrl != null && thumbnailUrl!.trim().isNotEmpty;

    if (!hasNetworkImage) return _buildFallbackAsset();

    return Image.network(
      thumbnailUrl!,
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      errorBuilder: (_, _, _) => _buildFallbackAsset(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _buildFallbackAsset(),
    );
  }

  Widget _buildFallbackAsset() {
    return Image.asset(
      meta.assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => ColoredBox(
        color: meta.badgeBg,
        child: Center(child: Icon(meta.icon, color: meta.accent, size: 34)),
      ),
    );
  }
}

class _PhaseMeta {
  final int categoryIndex;
  final String shortLabel;
  final String pillLabel;
  final String title;
  final String subtitle;
  final String ageTag;
  final IconData icon;
  final String assetPath;
  final Color accent;
  final Color badgeBg;
  final Color gradientStart;
  final Color gradientEnd;
  final Color borderColor;

  const _PhaseMeta({
    required this.categoryIndex,
    required this.shortLabel,
    required this.pillLabel,
    required this.title,
    required this.subtitle,
    required this.ageTag,
    required this.icon,
    required this.assetPath,
    required this.accent,
    required this.badgeBg,
    required this.gradientStart,
    required this.gradientEnd,
    required this.borderColor,
  });
}

class _GuideMetric {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color bg;
  final Color color;

  const _GuideMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.bg,
    required this.color,
  });
}

class _NutritionGuide {
  final String id;
  final String title;
  final String badge;
  final List<_GuideMetric> metrics;
  final String tip;

  const _NutritionGuide({
    required this.id,
    required this.title,
    required this.badge,
    required this.metrics,
    required this.tip,
  });
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
