import 'package:flutter/material.dart';

import '../../theme/sg_theme.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenCalculator;
  final VoidCallback? onOpenMpasi;

  const HomeScreen({
    super.key,
    required this.onOpenCalculator,
    this.onOpenMpasi,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _children = [
    _ChildProfile(name: 'Danendra', age: '14 Bulan'),
    _ChildProfile(name: 'Aluna', age: '8 Bulan'),
  ];

  static const _measurements = [
    _Measurement(date: '12 Okt 2026', weight: '9,8', height: '78'),
    _Measurement(date: '12 Sep 2026', weight: '9,5', height: '77'),
    _Measurement(date: '12 Agu 2026', weight: '9,2', height: '76'),
  ];

  static const _articles = [
    _EducationArticle(
      category: 'TUMBUH KEMBANG',
      title: 'Pantau pertumbuhan si kecil setiap bulan',
      readTime: '4 menit baca',
      icon: Icons.child_care_rounded,
      color: Color(0xFFE9A23B),
    ),
    _EducationArticle(
      category: 'GIZI ANAK',
      title: 'Kenali isi piring makan bergizi seimbang',
      readTime: '5 menit baca',
      icon: Icons.favorite_rounded,
      color: Color(0xFF35A989),
    ),
    _EducationArticle(
      category: 'MPASI',
      title: 'Ide menu MPASI lokal yang mudah dibuat',
      readTime: '3 menit baca',
      icon: Icons.restaurant_rounded,
      color: SG.primary,
    ),
  ];

  _ChildProfile _activeChild = _children.first;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: [
        _buildTopBar(),
        const SizedBox(height: 22),
        _buildGreeting(),
        const SizedBox(height: 18),
        _buildChildSelector(),
        const SizedBox(height: 18),
        _buildNutritionStatusCard(),
        const SizedBox(height: 18),
        _buildQuickActions(),
        const SizedBox(height: 27),
        _buildGrowthChartSection(),
        const SizedBox(height: 27),
        _buildMeasurementHistorySection(),
        const SizedBox(height: 27),
        _buildEducationSection(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Image.asset(
          'assets/images/logoBesar.png',
          width: 42,
          height: 42,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.shield_rounded, color: SG.primary, size: 38),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'StuntGuard',
                style: TextStyle(
                  color: SG.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'KABUPATEN JEMBER',
                style: TextStyle(
                  color: SG.primary,
                  fontSize: 9,
                  letterSpacing: .45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: () => _showMessage('Belum ada notifikasi baru.'),
          icon: const Icon(Icons.notifications_none_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: SG.ink,
            side: const BorderSide(color: SG.line),
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          onTap: () =>
              _showMessage('Menu profil akan tersedia di halaman Profil.'),
          borderRadius: BorderRadius.circular(24),
          child: const CircleAvatar(
            radius: 21,
            backgroundColor: SG.pale,
            child: Icon(Icons.person_rounded, color: SG.primary, size: 23),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Halo, Orang Tua! 👋',
          style: TextStyle(
            color: SG.ink,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Pantau tumbuh kembang ${_activeChild.name} dengan penuh kasih.',
          style: const TextStyle(color: SG.muted, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildChildSelector() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: SG.pale,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.child_care_rounded, color: SG.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ANAK YANG DIPANTAU',
                  style: TextStyle(
                    color: SG.muted,
                    fontSize: 10,
                    letterSpacing: .5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_activeChild.name} (${_activeChild.age})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SG.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<_ChildProfile>(
            tooltip: 'Pilih anak',
            onSelected: (child) => setState(() => _activeChild = child),
            itemBuilder: (context) => [
              for (final child in _children)
                PopupMenuItem(
                  value: child,
                  child: Text('${child.name} (${child.age})'),
                ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.keyboard_arrow_down_rounded, color: SG.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF4D8E3)),
        boxShadow: [
          BoxShadow(
            color: SG.primary.withValues(alpha: .07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Status gizi terakhir',
                  style: TextStyle(
                    color: SG.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F7F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF16846E),
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Gizi Normal',
                      style: TextStyle(
                        color: Color(0xFF16846E),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Pengukuran contoh • 12 Oktober 2026',
            style: TextStyle(color: SG.muted, fontSize: 11),
          ),
          const SizedBox(height: 19),
          Row(
            children: [
              const Expanded(
                child: _NutritionMetric(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Berat badan',
                  value: '9,8',
                  unit: 'kg',
                ),
              ),
              _buildMetricDivider(),
              const Expanded(
                child: _NutritionMetric(
                  icon: Icons.straighten_rounded,
                  label: 'Tinggi badan',
                  value: '78',
                  unit: 'cm',
                ),
              ),
              _buildMetricDivider(),
              const Expanded(
                child: _NutritionMetric(
                  icon: Icons.airline_seat_flat_rounded,
                  label: 'Posisi ukur',
                  value: 'Terlentang',
                  unit: '',
                  compact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: SG.primary, size: 17),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data ilustrasi untuk pratinjau. Hasil skrining bukan diagnosis medis.',
                    style: TextStyle(
                      color: SG.muted,
                      fontSize: 10,
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

  Widget _buildMetricDivider() => Container(
    height: 44,
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 7),
    color: SG.line,
  );

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: widget.onOpenCalculator,
            icon: const Icon(Icons.calculate_outlined, size: 18),
            label: const Text('Cek Gizi WHO'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                widget.onOpenMpasi ??
                () => _showMessage('Halaman Resep MPASI belum tersedia.'),
            icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
            label: const Text('Resep MPASI'),
            style: OutlinedButton.styleFrom(
              foregroundColor: SG.primary,
              side: const BorderSide(color: SG.primary),
              minimumSize: const Size.fromHeight(50),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Grafik Pertumbuhan',
          subtitle: 'Z-Score WHO • Tinggi badan menurut umur',
          trailing: 'ILUSTRASI',
        ),
        const SizedBox(height: 12),
        _card(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  _ChartLegend(color: SG.primary, label: 'Danendra'),
                  SizedBox(width: 16),
                  _ChartLegend(
                    color: Color(0xFFCBD5E1),
                    label: 'Referensi WHO',
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 150,
                width: double.infinity,
                child: CustomPaint(
                  painter: _GrowthChartPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('10 bln', style: _chartLabelStyle),
                  Text('11 bln', style: _chartLabelStyle),
                  Text('12 bln', style: _chartLabelStyle),
                  Text('13 bln', style: _chartLabelStyle),
                  Text('14 bln', style: _chartLabelStyle),
                ],
              ),
              const SizedBox(height: 13),
              const Divider(height: 1, color: SG.line),
              const SizedBox(height: 11),
              const Text(
                'Grafik dan titik pengukuran adalah data contoh. Penilaian pertumbuhan perlu menggunakan standar WHO dan data anak yang tervalidasi.',
                style: TextStyle(color: SG.muted, fontSize: 10, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Riwayat Pengukuran',
          subtitle: 'Catatan BB dan tinggi badan',
          trailing: '3 DATA',
        ),
        const SizedBox(height: 12),
        _card(
          padding: const EdgeInsets.fromLTRB(14, 3, 14, 3),
          child: Column(
            children: [
              for (var index = 0; index < _measurements.length; index++) ...[
                _buildMeasurementRow(
                  _measurements[index],
                  isLatest: index == 0,
                ),
                if (index != _measurements.length - 1)
                  const Divider(height: 1, color: SG.line),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementRow(
    _Measurement measurement, {
    required bool isLatest,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isLatest ? SG.pale : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.monitor_weight_outlined,
              color: isLatest ? SG.primary : SG.muted,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  measurement.date,
                  style: const TextStyle(
                    color: SG.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${measurement.weight} kg  •  ${measurement.height} cm',
                  style: const TextStyle(color: SG.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          if (isLatest)
            const Text(
              'Terbaru',
              style: TextStyle(
                color: SG.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Edukasi & MPASI',
          subtitle: 'Informasi kesehatan untuk keluarga',
          trailing: 'LIHAT SEMUA',
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 174,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _articles.length,
            separatorBuilder: (context, index) => const SizedBox(width: 11),
            itemBuilder: (context, index) =>
                _buildEducationCard(_articles[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationCard(_EducationArticle article) {
    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              _showMessage('Artikel akan dibuka setelah konten tersedia.'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SG.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: article.color.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(article.icon, color: article.color, size: 20),
                ),
                const Spacer(),
                Text(
                  article.category,
                  style: const TextStyle(
                    color: SG.primary,
                    fontSize: 9,
                    letterSpacing: .35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SG.ink,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  article.readTime,
                  style: const TextStyle(color: SG.muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: SG.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: SG.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: SG.primary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(15),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: SG.line),
        boxShadow: [
          BoxShadow(
            color: SG.ink.withValues(alpha: .025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _NutritionMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool compact;

  const _NutritionMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: SG.primary),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: SG.muted, fontSize: 9),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: SG.ink,
                    fontSize: compact ? 11 : 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(color: SG.muted, fontSize: 10),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: SG.muted, fontSize: 10)),
    ],
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

    const zScores = [.48, .46, .52, .49, .45];
    final growthPath = Path();
    final points = <Offset>[];
    for (var index = 0; index < zScores.length; index++) {
      final point = Offset(
        horizontalInset + chartWidth * index / (zScores.length - 1),
        verticalInset + chartHeight * zScores[index],
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
        ..color = SG.primary
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = Colors.white);
      canvas.drawCircle(point, 3, Paint()..color = SG.primary);
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

const _chartLabelStyle = TextStyle(color: SG.muted, fontSize: 9);
