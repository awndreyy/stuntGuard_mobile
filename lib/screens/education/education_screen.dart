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
  // 0 = Semua Rak (4 Container Terpilah), 1=Balita, 2=T1, 3=T2, 4=T3, 5=Tersimpan
  int _selectedCategory = 0;
  int _selectedPhaseGuide = 0;

  List<Informasi> _articles = const [];
  String? _error;
  bool _loading = true;
  final Set<String> _bookmarkedIds = {};
  final Map<int, int> _containerPageMap = {1: 1, 2: 1, 3: 1, 4: 1};

  static const List<_PhaseContainerMeta> _containerMetas = [
    _PhaseContainerMeta(
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
    _PhaseContainerMeta(
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
    _PhaseContainerMeta(
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
    _PhaseContainerMeta(
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

  static const List<_NutritionPhaseGuide> _phaseGuides = [
    _NutritionPhaseGuide(
      id: 'balita',
      title: 'Gizi Balita (0–59 Bulan)',
      badge: 'Fokus 1.000 HPK',
      badgeColor: Color(0xFF0F766E),
      badgeBg: Color(0xFFCCFBF1),
      m1Label: 'Energi',
      m1Value: '800–1350',
      m1Unit: 'kkal',
      m1Icon: Icons.local_fire_department_rounded,
      m1Bg: Color(0xFFFEF3C7),
      m1Color: Color(0xFFB45309),
      m2Label: 'Protein',
      m2Value: '15–25',
      m2Unit: 'g/hr',
      m2Icon: Icons.egg_alt_rounded,
      m2Bg: Color(0xFFE6FAF3),
      m2Color: Color(0xFF0F766E),
      m3Label: 'Pola Makan',
      m3Value: '3–4x+ASI',
      m3Unit: '',
      m3Icon: Icons.restaurant_rounded,
      m3Bg: SG.pale,
      m3Color: SG.primary,
      tip: 'Prioritaskan lauk protein hewani (telur, ikan, hati ayam, daging) di setiap jadwal makan utama untuk mencegah stunting.',
    ),
    _NutritionPhaseGuide(
      id: 'trimester1',
      title: 'Ibu Hamil Trimester 1',
      badge: 'Minggu 1–12',
      badgeColor: Color(0xFFB45309),
      badgeBg: Color(0xFFFEF3C7),
      m1Label: 'Ekstra Kalori',
      m1Value: '+180',
      m1Unit: 'kkal',
      m1Icon: Icons.bolt_rounded,
      m1Bg: Color(0xFFFEF3C7),
      m1Color: Color(0xFFB45309),
      m2Label: 'Asam Folat',
      m2Value: '600',
      m2Unit: 'mcg',
      m2Icon: Icons.spa_rounded,
      m2Bg: Color(0xFFE6FAF3),
      m2Color: Color(0xFF0F766E),
      m3Label: 'Zat Besi',
      m3Value: '27',
      m3Unit: 'mg/hr',
      m3Icon: Icons.favorite_rounded,
      m3Bg: SG.pale,
      m3Color: SG.primary,
      tip: 'Penuhi asam folat & vitamin B6. Bila mual di pagi hari, ubah jadwal makan menjadi 5–6 porsi kecil tapi sering.',
    ),
    _NutritionPhaseGuide(
      id: 'trimester2',
      title: 'Ibu Hamil Trimester 2',
      badge: 'Minggu 13–27',
      badgeColor: Color(0xFF0369A1),
      badgeBg: Color(0xFFE0F2FE),
      m1Label: 'Ekstra Kalori',
      m1Value: '+300',
      m1Unit: 'kkal',
      m1Icon: Icons.bolt_rounded,
      m1Bg: Color(0xFFFEF3C7),
      m1Color: Color(0xFFB45309),
      m2Label: 'Kalsium',
      m2Value: '1.000',
      m2Unit: 'mg/hr',
      m2Icon: Icons.shield_rounded,
      m2Bg: Color(0xFFE0F2FE),
      m2Color: Color(0xFF0369A1),
      m3Label: 'Protein',
      m3Value: '+10',
      m3Unit: 'g/hr',
      m3Icon: Icons.set_meal_rounded,
      m3Bg: Color(0xFFE6FAF3),
      m3Color: Color(0xFF0F766E),
      tip: 'Minum 1 Tablet Tambah Darah (TTD) setiap malam bersama air putih atau buah kaya vitamin C (jeda 2 jam dari susu/teh).',
    ),
    _NutritionPhaseGuide(
      id: 'trimester3',
      title: 'Ibu Hamil Trimester 3',
      badge: 'Minggu 28–40',
      badgeColor: SG.primary,
      badgeBg: SG.pale,
      m1Label: 'Ekstra Kalori',
      m1Value: '+300',
      m1Unit: 'kkal',
      m1Icon: Icons.bolt_rounded,
      m1Bg: Color(0xFFFEF3C7),
      m1Color: Color(0xFFB45309),
      m2Label: 'Protein',
      m2Value: '+30',
      m2Unit: 'g/hr',
      m2Icon: Icons.egg_rounded,
      m2Bg: SG.pale,
      m2Color: SG.primary,
      m3Label: 'Omega-3 DHA',
      m3Value: '200+',
      m3Unit: 'mg/hr',
      m3Icon: Icons.psychology_rounded,
      m3Bg: Color(0xFFE0F2FE),
      m3Color: Color(0xFF0369A1),
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

  int _resolvePhaseIndex(Informasi article) {
    final combined = '${article.kategori} ${article.judul}'.toLowerCase();

    if (combined.contains('trimester 3') ||
        combined.contains('trimester_3') ||
        combined.contains('trim 3') ||
        combined.contains('trimester iii')) {
      return 4;
    }
    if (combined.contains('trimester 2') ||
        combined.contains('trimester_2') ||
        combined.contains('trim 2') ||
        combined.contains('trimester ii')) {
      return 3;
    }
    if (combined.contains('trimester 1') ||
        combined.contains('trimester_1') ||
        combined.contains('trim 1') ||
        combined.contains('trimester i') ||
        combined.contains('awal kehamilan')) {
      return 2;
    }
    return 1; // Default: Container Gizi & Pertumbuhan Balita
  }

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
      if (_bookmarkedIds.contains(id)) {
        _bookmarkedIds.remove(id);
      } else {
        _bookmarkedIds.add(id);
      }
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
    final activeGuide = _phaseGuides[_selectedPhaseGuide];
    final savedArticles = _articles
        .where((a) => _bookmarkedIds.contains(a.id))
        .toList();

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
              child: _buildFloatingGuideCard(activeGuide),
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
                const SizedBox(height: 16),
                if (_loading)
                  _buildLoadingState()
                else if (_error != null)
                  _buildErrorState()
                else if (_articles.isEmpty)
                  _buildEmptyDatabaseState()
                else if (_selectedCategory == 5)
                  _buildSavedContainer(savedArticles)
                else if (_selectedCategory == 0)
                  for (var i = 0; i < _containerMetas.length; i++) ...[
                    _buildPhaseShelf(_containerMetas[i], isFocusedMode: false),
                    if (i != _containerMetas.length - 1)
                      const SizedBox(height: 16),
                  ]
                else
                  for (final meta in _containerMetas.where(
                    (m) => m.categoryIndex == _selectedCategory,
                  ))
                    _buildPhaseShelf(meta, isFocusedMode: true),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'Seluruh artikel dimuat secara dinamis dari database server StuntGuard Jember.',
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
                    for (final meta in _containerMetas)
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

  Widget _buildStoryBubble(_PhaseContainerMeta meta) {
    final isActive = _selectedPhaseGuide == (meta.categoryIndex - 1);
    final count = _articles
        .where((a) => _resolvePhaseIndex(a) == meta.categoryIndex)
        .length;

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
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 21,
                  height: 21,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: SG.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
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

  Widget _buildFloatingGuideCard(_NutritionPhaseGuide guide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF3DCE3)),
        boxShadow: [
          BoxShadow(
            color: SG.primary.withValues(alpha: .13),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RINGKASAN KEBUTUHAN HARIAN',
                      style: TextStyle(
                        color: SG.primary,
                        fontSize: 9.5,
                        letterSpacing: .5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      guide.title,
                      style: const TextStyle(
                        color: SG.ink,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: guide.badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  guide.badge,
                  style: TextStyle(
                    color: guide.badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildTintedMetricTile(
                  icon: guide.m1Icon,
                  label: guide.m1Label,
                  value: guide.m1Value,
                  unit: guide.m1Unit,
                  bg: guide.m1Bg,
                  color: guide.m1Color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTintedMetricTile(
                  icon: guide.m2Icon,
                  label: guide.m2Label,
                  value: guide.m2Value,
                  unit: guide.m2Unit,
                  bg: guide.m2Bg,
                  color: guide.m2Color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTintedMetricTile(
                  icon: guide.m3Icon,
                  label: guide.m3Label,
                  value: guide.m3Value,
                  unit: guide.m3Unit,
                  bg: guide.m3Bg,
                  color: guide.m3Color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: SG.soft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SG.line.withValues(alpha: .7)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  color: SG.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    guide.tip,
                    style: const TextStyle(
                      color: SG.ink,
                      fontSize: 11,
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

  Widget _buildTintedMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color bg,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SG.muted,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: SG.ink,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (unit.isNotEmpty)
                    TextSpan(
                      text: ' $unit',
                      style: const TextStyle(color: SG.muted, fontSize: 9.5),
                    ),
                ],
              ),
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
                'Semua Artikel Informasi',
                style: TextStyle(
                  color: SG.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Panduan terverifikasi untuk orang tua & ibu hamil',
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
            '${_articles.length} Artikel',
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
            label: 'Semua Rak (4)',
            isSelected: _selectedCategory == 0,
            activeColor: SG.ink,
            onTap: () => _selectCategory(0),
          ),
          const SizedBox(width: 8),
          for (final meta in _containerMetas) ...[
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

  Widget _buildPhaseShelf(
    _PhaseContainerMeta meta, {
    required bool isFocusedMode,
  }) {
    final phaseArticles = _articles
        .where((a) => _resolvePhaseIndex(a) == meta.categoryIndex)
        .toList();
    const pageSize = 3;
    final currentPage = _containerPageMap[meta.categoryIndex] ?? 1;
    final totalPages = phaseArticles.isEmpty
        ? 1
        : (phaseArticles.length / pageSize).ceil();
    final safePage = currentPage.clamp(1, totalPages);
    final startIndex = (safePage - 1) * pageSize;
    final pagedArticles = phaseArticles
        .skip(startIndex)
        .take(pageSize)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  meta.assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: Colors.white,
                    child: Icon(meta.icon, color: meta.accent, size: 23),
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
                        Flexible(
                          child: Text(
                            '• ${phaseArticles.length} Bacaan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: SG.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      meta.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: SG.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (phaseArticles.isNotEmpty) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () =>
                      _selectCategory(isFocusedMode ? 0 : meta.categoryIndex),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isFocusedMode ? 'Semua Rak' : 'Ruang Baca',
                          style: TextStyle(
                            color: isFocusedMode ? SG.ink : meta.accent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isFocusedMode
                              ? Icons.close_fullscreen_rounded
                              : Icons.arrow_forward_rounded,
                          size: 13,
                          color: isFocusedMode ? SG.ink : meta.accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (phaseArticles.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .88),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Belum ada artikel untuk ${meta.title} dari web admin.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: SG.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else if (!isFocusedMode) ...[
            SizedBox(
              height: 266,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: phaseArticles.length,
                separatorBuilder: (context, index) => const SizedBox(width: 13),
                itemBuilder: (context, index) => _buildVisualMagazineCard(
                  phaseArticles[index],
                  meta: meta,
                  orderNumber: index + 1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.swipe_rounded, size: 14, color: meta.accent),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Geser ke samping untuk melihat ${phaseArticles.length} artikel',
                    style: const TextStyle(color: SG.muted, fontSize: 10.5),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < phaseArticles.length.clamp(1, 5); i++)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: i == 0 ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == 0
                              ? meta.accent
                              : meta.accent.withValues(alpha: .35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ] else ...[
            for (var i = 0; i < pagedArticles.length; i++) ...[
              _buildFocusedReaderCard(pagedArticles[i], meta: meta),
              if (i != pagedArticles.length - 1) const SizedBox(height: 12),
            ],
            if (totalPages > 1) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hal. $safePage / $totalPages (${phaseArticles.length} artikel)',
                    style: const TextStyle(
                      color: SG.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: safePage > 1
                            ? () => setState(
                                () => _containerPageMap[meta.categoryIndex] =
                                    safePage - 1,
                              )
                            : null,
                        child: const Text('← Sebelumnya'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: safePage < totalPages
                            ? () => setState(
                                () => _containerPageMap[meta.categoryIndex] =
                                    safePage + 1,
                              )
                            : null,
                        child: const Text('Berikutnya →'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildVisualMagazineCard(
    Informasi article, {
    required _PhaseContainerMeta meta,
    required int orderNumber,
  }) {
    final isBookmarked = _bookmarkedIds.contains(article.id);
    return SizedBox(
      width: 260,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: SG.ink.withValues(alpha: .10),
        child: InkWell(
          onTap: () => _openArticle(article),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Visual Banner (Uses API thumbnailUrl first, falls back to Phase Illustration)
              SizedBox(
                height: 112,
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
                            Colors.black.withValues(alpha: .42),
                            Colors.black.withValues(alpha: .08),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .92),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              article.kategori,
                              style: TextStyle(
                                color: meta.accent,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () => _toggleBookmark(article.id),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .92),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 17,
                                color: isBookmarked ? SG.primary : SG.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .42),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '#$orderNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SG.ink,
                          fontSize: 13.5,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        article.ringkasan,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SG.muted,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                      const Spacer(),
                      const Divider(height: 14, color: SG.line),
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
                              horizontal: 10,
                              vertical: 4,
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
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 2),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusedReaderCard(
    Informasi article, {
    required _PhaseContainerMeta meta,
  }) {
    final isBookmarked = _bookmarkedIds.contains(article.id);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openArticle(article),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 82,
                  height: 82,
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
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 18,
                            color: isBookmarked ? SG.primary : SG.muted,
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
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.ringkasan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SG.muted,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
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
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 10),
          if (savedArticles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Belum ada artikel yang disimpan.',
                  style: TextStyle(color: SG.muted, fontSize: 12),
                ),
              ),
            )
          else
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: savedArticles.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final a = savedArticles[index];
                  final phaseIdx = _resolvePhaseIndex(a);
                  final meta = _containerMetas.firstWhere(
                    (m) => m.categoryIndex == phaseIdx,
                    orElse: () => _containerMetas.first,
                  );
                  return SizedBox(
                    width: 230,
                    child: Material(
                      color: SG.background,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _openArticle(a),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 92,
                              width: double.infinity,
                              child: _ArticleCoverImage(
                                thumbnailUrl: a.thumbnailUrl,
                                meta: meta,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(11),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.kategori,
                                    style: const TextStyle(
                                      color: SG.primary,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    a.judul,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: SG.ink,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: SG.line),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: SG.primary),
          SizedBox(height: 16),
          Text(
            'Memuat artikel edukasi...',
            style: TextStyle(
              color: SG.ink,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Menyinkronkan data Gizi Balita & Ibu Hamil Trimester 1–3',
            textAlign: TextAlign.center,
            style: TextStyle(color: SG.muted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF4C6D4)),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: SG.pale,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: SG.primary,
              size: 27,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Artikel gagal dimuat',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SG.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _error ?? 'Periksa koneksi API Laravel Anda.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: SG.muted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadArticles,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDatabaseState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: SG.line),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: SG.pale,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: SG.primary,
              size: 27,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada artikel edukasi',
            style: TextStyle(
              color: SG.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Artikel yang ditambahkan admin melalui web akan otomatis muncul di dalam container fase yang sesuai.',
            textAlign: TextAlign.center,
            style: TextStyle(color: SG.muted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _loadArticles,
            icon: const Icon(Icons.sync_rounded, size: 18),
            label: const Text('Muat Ulang'),
          ),
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
  final _PhaseContainerMeta meta;

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage =
        thumbnailUrl != null && thumbnailUrl!.trim().isNotEmpty;

    if (!hasNetworkImage) {
      return _buildFallbackAsset();
    }

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

class _PhaseContainerMeta {
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

  const _PhaseContainerMeta({
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

class _NutritionPhaseGuide {
  final String id;
  final String title;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;
  final String m1Label;
  final String m1Value;
  final String m1Unit;
  final IconData m1Icon;
  final Color m1Bg;
  final Color m1Color;
  final String m2Label;
  final String m2Value;
  final String m2Unit;
  final IconData m2Icon;
  final Color m2Bg;
  final Color m2Color;
  final String m3Label;
  final String m3Value;
  final String m3Unit;
  final IconData m3Icon;
  final Color m3Bg;
  final Color m3Color;
  final String tip;

  const _NutritionPhaseGuide({
    required this.id,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
    required this.m1Label,
    required this.m1Value,
    required this.m1Unit,
    required this.m1Icon,
    required this.m1Bg,
    required this.m1Color,
    required this.m2Label,
    required this.m2Value,
    required this.m2Unit,
    required this.m2Icon,
    required this.m2Bg,
    required this.m2Color,
    required this.m3Label,
    required this.m3Value,
    required this.m3Unit,
    required this.m3Icon,
    required this.m3Bg,
    required this.m3Color,
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
