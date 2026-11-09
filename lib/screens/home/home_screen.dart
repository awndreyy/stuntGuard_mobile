import 'package:flutter/material.dart';

/// Palette follows welcome_screen.dart without changing other screens.
class _HomeColors {
  static const primary = Color(0xFFC8103D);
  static const dark = Color(0xFF8B1038);
  static const yellow = Color(0xFFFFD84D);
  static const background = Color(0xFFFFF8F6);
  static const pale = Color(0xFFFFEBEF);
  static const ink = Color(0xFF35232B);
  static const muted = Color(0xFF75616A);
  static const line = Color(0xFFF0DEE3);
  static const green = Color(0xFF227257);
  static const greenPale = Color(0xFFEAF6EF);
}

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onOpenCalculator;
  final VoidCallback? onOpenMpasi;
  final VoidCallback? onOpenEducation;
  final VoidCallback? onOpenProfile;

  const HomeScreen({
    super.key,
    required this.user,
    required this.onOpenCalculator,
    this.onOpenMpasi,
    this.onOpenEducation,
    this.onOpenProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _children = [
    _ChildProfile(name: 'Danendra', age: '14 bulan'),
    _ChildProfile(name: 'Aluna', age: '8 bulan'),
  ];
  static const _measurements = [
    _Measurement(date: '12 Oktober 2026', weight: '9,8', height: '78'),
    _Measurement(date: '12 September 2026', weight: '9,5', height: '77'),
    _Measurement(date: '12 Agustus 2026', weight: '9,2', height: '76'),
  ];
  static const _articles = [
    _EducationArticle(
      category: 'TUMBUH KEMBANG',
      title: 'Pantau pertumbuhan si kecil setiap bulan',
      readTime: '4 menit baca',
      icon: Icons.child_care_rounded,
      color: _HomeColors.dark,
    ),
    _EducationArticle(
      category: 'GIZI ANAK',
      title: 'Kenali isi piring makan bergizi seimbang',
      readTime: '5 menit baca',
      icon: Icons.favorite_rounded,
      color: _HomeColors.green,
    ),
    _EducationArticle(
      category: 'MPASI',
      title: 'Ide menu MPASI lokal yang mudah dibuat',
      readTime: '3 menit baca',
      icon: Icons.restaurant_rounded,
      color: _HomeColors.primary,
    ),
  ];
  _ChildProfile _activeChild = _children.first;

  String get _userName {
    final name = widget.user['name']?.toString().trim();
    return name == null || name.isEmpty ? 'Orang Tua' : name;
  }

  @override
  Widget build(BuildContext context) {
    // MainNavigation already provides the top SafeArea.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return ColoredBox(
      color: _HomeColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gutter = constraints.maxWidth > 600 ? 32.0 : 20.0;
          return ListView(
            key: const PageStorageKey('home-scroll'),
            padding: EdgeInsets.only(bottom: 120 + bottomInset),
            children: [
              _buildHeader(gutter),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildChildSelector(),
                        const SizedBox(height: 20),
                        _buildNutritionCard(),
                        const SizedBox(height: 28),
                        _sectionTitle(
                          'Untuk si kecil',
                          'Langkah kecil, manfaat besar.',
                        ),
                        const SizedBox(height: 12),
                        _buildQuickActions(),
                        const SizedBox(height: 28),
                        _buildGrowthChart(),
                        const SizedBox(height: 28),
                        _buildHistory(),
                        const SizedBox(height: 28),
                        _buildEducation(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(double gutter) => Container(
    padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 28),
    decoration: const BoxDecoration(
      color: _HomeColors.dark,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Image.asset(
                    'assets/images/logo-StuntGuard.png',
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Stunt',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'Guard',
                              style: TextStyle(color: _HomeColors.yellow),
                            ),
                          ],
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.5,
                        ),
                      ),
                      Text(
                        'JEMBER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          letterSpacing: 2,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: widget.onOpenProfile,
                  tooltip: 'Buka profil',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: .15),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white60,
                    minimumSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.person_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Halo, $_userName!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Temani setiap langkah\ntumbuh kembang si kecil.',
              style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _HomeColors.yellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    color: _HomeColors.dark,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Tumbuh sehat, bersama StuntGuard',
                      style: TextStyle(
                        color: _HomeColors.dark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
  );

  Widget _buildChildSelector() => _card(
    padding: EdgeInsets.zero,
    child: PopupMenuButton<_ChildProfile>(
      tooltip: 'Pilih anak contoh',
      initialValue: _activeChild,
      onSelected: (child) => setState(() => _activeChild = child),
      itemBuilder: (_) => [
        for (final child in _children)
          PopupMenuItem(
            value: child,
            child: Text('${child.name} • ${child.age}'),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _iconTile(
              Icons.child_care_rounded,
              _HomeColors.primary,
              _HomeColors.pale,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ANAK YANG DIPANTAU • CONTOH',
                    style: TextStyle(
                      color: _HomeColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .6,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _activeChild.name,
                    style: const TextStyle(
                      color: _HomeColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _activeChild.age,
                    style: const TextStyle(
                      color: _HomeColors.muted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.unfold_more_rounded, color: _HomeColors.primary),
          ],
        ),
      ),
    ),
  );

  Widget _buildNutritionCard() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Ringkasan pertumbuhan',
              style: TextStyle(
                color: _HomeColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            _Badge(
              label: 'Data contoh',
              color: _HomeColors.dark,
              background: _HomeColors.pale,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Pengukuran • 12 Oktober 2026',
          style: TextStyle(color: _HomeColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < 280 ||
                MediaQuery.textScalerOf(context).scale(14) > 20;
            final metrics = [
              _metric(
                'Berat badan',
                '9,8',
                'kg',
                Icons.monitor_weight_outlined,
              ),
              _metric('Tinggi badan', '78', 'cm', Icons.straighten_rounded),
            ];
            return stacked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      metrics[0],
                      const SizedBox(height: 12),
                      metrics[1],
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: metrics[0]),
                      const SizedBox(width: 12),
                      Expanded(child: metrics[1]),
                    ],
                  );
          },
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Badge(
              label: 'Gizi normal • contoh',
              color: _HomeColors.green,
              background: _HomeColors.greenPale,
              icon: Icons.check_circle_outline_rounded,
            ),
            Text(
              'Posisi ukur: terlentang',
              style: TextStyle(color: _HomeColors.muted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: _HomeColors.line),
        const SizedBox(height: 12),
        const Text(
          'Data ilustrasi, belum terhubung ke data anak. Hasil skrining bukan diagnosis medis.',
          style: TextStyle(color: _HomeColors.muted, fontSize: 12, height: 1.5),
        ),
      ],
    ),
  );

  Widget _metric(String label, String value, String unit, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _HomeColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _HomeColors.primary, size: 22),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(color: _HomeColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              style: const TextStyle(color: _HomeColors.ink),
            ),
          ],
        ),
      );

  Widget _buildQuickActions() => LayoutBuilder(
    builder: (context, constraints) {
      final width =
          constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(14) > 20
          ? constraints.maxWidth
          : (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: width,
            child: _action(
              title: 'Kalkulator gizi',
              subtitle: 'Cek gizi dengan WHO',
              icon: Icons.calculate_outlined,
              filled: true,
              onTap: widget.onOpenCalculator,
            ),
          ),
          SizedBox(
            width: width,
            child: _action(
              title: 'Resep MPASI',
              subtitle: 'Ide menu untuk si kecil',
              icon: Icons.ramen_dining_rounded,
              filled: false,
              onTap: widget.onOpenMpasi,
            ),
          ),
        ],
      );
    },
  );

  Widget _action({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool filled,
    VoidCallback? onTap,
  }) => Material(
    color: filled ? _HomeColors.primary : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: filled ? _HomeColors.primary : _HomeColors.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: filled ? _HomeColors.yellow : _HomeColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: filled ? Colors.white : _HomeColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                color: filled ? Colors.white : _HomeColors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildGrowthChart() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _sectionTitle(
        'Grafik pertumbuhan',
        'Gambaran perjalanan tumbuh si kecil.',
      ),
      const SizedBox(height: 12),
      _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Badge(
              label: 'Ilustrasi grafik',
              color: _HomeColors.dark,
              background: _HomeColors.pale,
            ),
            const SizedBox(height: 16),
            const Text(
              'Contoh tren pengukuran',
              style: TextStyle(
                color: _HomeColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Garis merah: contoh anak • Abu-abu: pembanding ilustratif',
              style: TextStyle(
                color: _HomeColors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              image: true,
              label: 'Grafik ilustrasi lima titik. Bukan hasil pengukuran atau kurva WHO tervalidasi.',
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(painter: _GrowthChartPainter()),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1', style: _chartLabelStyle),
                Text('2', style: _chartLabelStyle),
                Text('3', style: _chartLabelStyle),
                Text('4', style: _chartLabelStyle),
                Text('5', style: _chartLabelStyle),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Urutan pengukuran contoh', style: _chartLabelStyle),
            const SizedBox(height: 16),
            const Divider(height: 1, color: _HomeColors.line),
            const SizedBox(height: 12),
            const Text(
              'Grafik ini belum menggunakan data anak atau kurva WHO tervalidasi.',
              style: TextStyle(
                color: _HomeColors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildHistory() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _sectionTitle('Riwayat pengukuran', '3 catatan contoh • belum data anak'),
      const SizedBox(height: 12),
      _card(
        child: Column(
          children: [
            for (var i = 0; i < _measurements.length; i++) ...[
              if (i > 0) const Divider(height: 32, color: _HomeColors.line),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconTile(
                    Icons.event_note_rounded,
                    _HomeColors.primary,
                    _HomeColors.pale,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _measurements[i].date,
                          style: const TextStyle(
                            color: _HomeColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_measurements[i].weight} kg  •  ${_measurements[i].height} cm',
                          style: const TextStyle(
                            color: _HomeColors.muted,
                            fontSize: 13,
                          ),
                        ),
                        if (i == 0)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              'Terbaru',
                              style: TextStyle(
                                color: _HomeColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ],
  );

  Widget _buildEducation() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _sectionTitle(
        'Bekal untuk orang tua',
        'Inspirasi merawat si kecil setiap hari.',
      ),
      if (widget.onOpenEducation != null)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: widget.onOpenEducation,
            style: TextButton.styleFrom(
              foregroundColor: _HomeColors.primary,
              minimumSize: const Size(48, 48),
            ),
            child: const Text('Buka edukasi →'),
          ),
        ),
      const SizedBox(height: 12),
      for (final article in _articles)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconTile(
                  article.icon,
                  article.color,
                  article.color.withValues(alpha: .08),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.category,
                        style: TextStyle(
                          color: article.color,
                          fontSize: 10,
                          letterSpacing: .6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.title,
                        style: const TextStyle(
                          color: _HomeColors.ink,
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${article.readTime} • Contoh artikel',
                        style: const TextStyle(
                          color: _HomeColors.muted,
                          fontSize: 12,
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
  );

  Widget _sectionTitle(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: _HomeColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -.4,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: const TextStyle(
          color: _HomeColors.muted,
          fontSize: 13,
          height: 1.5,
        ),
      ),
    ],
  );

  Widget _iconTile(IconData icon, Color color, Color background) =>
      ExcludeSemantics(
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
      );

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: _HomeColors.line),
    ),
    child: child,
  );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  final IconData? icon;
  const _Badge({
    required this.label,
    required this.color,
    required this.background,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          ExcludeSemantics(child: Icon(icon, color: color, size: 16)),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _GrowthChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const horizontalInset = 20.0;
    const verticalInset = 8.0;
    final chartWidth = size.width - horizontalInset * 2;
    final chartHeight = size.height - verticalInset * 2;

    final gridPaint = Paint()
      ..color = const Color(0xFFE9EDF2)
      ..strokeWidth = 1;
    for (var index = 0; index < 5; index++) {
      final y = verticalInset + chartHeight * index / 4;
      canvas.drawLine(
        Offset(horizontalInset, y),
        Offset(size.width - horizontalInset, y),
        gridPaint,
      );
    }

    final referencePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (final offset in [-.15, .16]) {
      final path = Path();
      for (var index = 0; index < 5; index++) {
        final x = horizontalInset + chartWidth * index / 4;
        final normalized = .5 + offset + (index - 2) * .035;
        final y = verticalInset + chartHeight * normalized;
        if (index == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, referencePaint);
    }

    const samplePoints = [.48, .46, .52, .49, .45];
    final growthPath = Path();
    final points = <Offset>[];
    for (var index = 0; index < samplePoints.length; index++) {
      final point = Offset(
        horizontalInset + chartWidth * index / (samplePoints.length - 1),
        verticalInset + chartHeight * samplePoints[index],
      );
      points.add(point);
      if (index == 0) {
        growthPath.moveTo(point.dx, point.dy);
      } else {
        growthPath.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(
      growthPath,
      Paint()
        ..color = _HomeColors.primary
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = Colors.white);
      canvas.drawCircle(point, 3, Paint()..color = _HomeColors.primary);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) => false;
}

class _ChildProfile {
  final String name;
  final String age;

  const _ChildProfile({required this.name, required this.age});
}

class _Measurement {
  final String date;
  final String weight;
  final String height;

  const _Measurement({
    required this.date,
    required this.weight,
    required this.height,
  });
}

class _EducationArticle {
  final String category;
  final String title;
  final String readTime;
  final IconData icon;
  final Color color;

  const _EducationArticle({
    required this.category,
    required this.title,
    required this.readTime,
    required this.icon,
    required this.color,
  });
}

const _chartLabelStyle = TextStyle(color: _HomeColors.muted, fontSize: 12);
