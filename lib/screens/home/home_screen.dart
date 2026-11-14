import 'package:flutter/material.dart';

import '../../models/balita.dart';
import '../../models/informasi.dart';
import '../../models/pengukuran.dart';
import 'measurement_detail_screen.dart';
import '../../services/balita_service.dart';
import '../../services/informasi_service.dart';
import '../../services/pengukuran_service.dart';

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

enum _GrowthMetric { weight, height }

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onOpenCalculator;
  final VoidCallback? onOpenMpasi;
  final VoidCallback? onOpenEducation;
  final VoidCallback? onOpenProfile;
  final bool isActive;
  final BalitaService balitaService;
  final InformasiService informasiService;
  final PengukuranService pengukuranService;

  HomeScreen({
    super.key,
    this.user = const {},
    required this.onOpenCalculator,
    this.onOpenMpasi,
    this.onOpenEducation,
    this.onOpenProfile,
    this.isActive = true,
    BalitaService? balitaService,
    InformasiService? informasiService,
    PengukuranService? pengukuranService,
  }) : balitaService = balitaService ?? BalitaService(),
       informasiService = informasiService ?? InformasiService(),
       pengukuranService = pengukuranService ?? PengukuranService();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Balita> _children = <Balita>[];
  List<Pengukuran> _measurements = <Pengukuran>[];
  List<Informasi> _articles = <Informasi>[];
  Balita? _activeChild;
  bool _loading = true;
  bool _articlesLoading = true;
  String? _error;
  String? _articlesError;
  _GrowthMetric? _growthMetric = _GrowthMetric.weight;

  _GrowthMetric get _selectedGrowthMetric =>
      _growthMetric ?? _GrowthMetric.weight;

  String get _userName {
    final name = widget.user['name']?.toString().trim();
    return name == null || name.isEmpty ? 'Orang Tua' : name;
  }

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    _loadArticles();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadHomeData();
    }
  }

  Future<void> _loadArticles() async {
    setState(() {
      _articlesLoading = true;
      _articlesError = null;
    });

    try {
      final articles = await widget.informasiService.fetchArticles();
      if (!mounted) return;
      setState(() {
        _articles = articles;
        _articlesLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _articles = const <Informasi>[];
        _articlesError = error.toString().replaceFirst('Exception: ', '');
        _articlesLoading = false;
      });
    }
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final children = await widget.balitaService.fetchChildren();
      if (!mounted) return;

      final nextActive = children.isNotEmpty ? children.first : null;
      setState(() {
        _children
          ..clear()
          ..addAll(children);
        _activeChild = nextActive;
      });

      if (nextActive != null) {
        await _loadMeasurementsForChild(nextActive.id);
      } else {
        if (!mounted) return;
        setState(() {
          _measurements = const <Pengukuran>[];
          _loading = false;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _measurements = const <Pengukuran>[];
        _loading = false;
      });
    }
  }

  Future<void> _loadMeasurementsForChild(String childId) async {
    try {
      final measurements = await widget.pengukuranService.fetchByChild(childId);
      if (!mounted) return;
      if (_activeChild?.id != childId) return;
      setState(() {
        _measurements = measurements;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      if (_activeChild?.id != childId) return;
      setState(() {
        _measurements = const <Pengukuran>[];
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _childAgeLabel(Balita child) {
    final birthDate = DateTime.tryParse(child.tanggalLahir);
    if (birthDate == null) return 'Umur belum diisi';

    final now = DateTime.now();
    var months =
        (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) {
      months--;
    }
    final value = months < 0 ? 0 : months;
    return '$value bulan';
  }

  Pengukuran? get _latestMeasurement => _measurements.isEmpty
      ? null
      : _measurements.reduce(
          (value, element) =>
              value.tanggal.isAfter(element.tanggal) ? value : element,
        );

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

  Widget _buildChildSelector() {
    final activeChild =
        _activeChild ?? (_children.isNotEmpty ? _children.first : null);

    if (_loading && _children.isEmpty) {
      return _card(
        child: const Center(
          child: CircularProgressIndicator(color: _HomeColors.primary),
        ),
      );
    }

    if (_children.isEmpty) {
      return _card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Belum ada data anak yang tersedia.',
            style: const TextStyle(
              color: _HomeColors.muted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return _card(
      padding: EdgeInsets.zero,
      child: PopupMenuButton<Balita>(
        tooltip: 'Pilih anak yang dipantau',
        initialValue: activeChild,
        onSelected: (child) {
          setState(() {
            _activeChild = child;
            _loading = true;
            _error = null;
          });
          _loadMeasurementsForChild(child.id);
        },
        itemBuilder: (_) => [
          for (final child in _children)
            PopupMenuItem(
              value: child,
              child: Text('${child.nama} • ${_childAgeLabel(child)}'),
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
                      'ANAK YANG DIPANTAU',
                      style: TextStyle(
                        color: _HomeColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      activeChild!.nama,
                      style: const TextStyle(
                        color: _HomeColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _childAgeLabel(activeChild),
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
  }

  Widget _buildNutritionCard() {
    final latest = _latestMeasurement;
    final activeChild = _activeChild;
    final hasData = latest != null;

    final metrics = [
      _metric(
        'Berat badan',
        latest?.beratLabel ?? '—',
        'kg',
        Icons.monitor_weight_outlined,
      ),
      _metric(
        'Tinggi badan',
        latest?.tinggiLabel ?? '—',
        'cm',
        Icons.straighten_rounded,
      ),
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Ringkasan pertumbuhan',
                style: TextStyle(
                  color: _HomeColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _Badge(
                label: hasData ? 'Data terbaru' : 'Belum ada data',
                color: _HomeColors.dark,
                background: _HomeColors.pale,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pengukuran • ${latest?.tanggalLabel ?? 'belum tersedia'}',
            style: const TextStyle(color: _HomeColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 280 ||
                  MediaQuery.textScalerOf(context).scale(14) > 20;
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Badge(
                label: hasData
                    ? 'Data terkini tersedia'
                    : 'Menunggu pengukuran',
                color: hasData ? _HomeColors.green : _HomeColors.muted,
                background: hasData
                    ? _HomeColors.greenPale
                    : _HomeColors.background,
                icon: hasData
                    ? Icons.check_circle_outline_rounded
                    : Icons.pending_outlined,
              ),
              if (activeChild != null)
                Text(
                  '${activeChild.nama} • ${_childAgeLabel(activeChild)}',
                  style: const TextStyle(
                    color: _HomeColors.muted,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: _HomeColors.line),
          const SizedBox(height: 12),
          Text(
            _error != null ? 'Gagal memuat data beranda: $_error' : 'Data ditampilkan dari riwayat pengukuran anak yang tersimpan di server.',
            style: const TextStyle(
              color: _HomeColors.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildGrowthChart() {
    final chartMeasurements = _measurements.toList()
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));
    final metricLabel = _selectedGrowthMetric == _GrowthMetric.weight
        ? 'Berat badan (kg)'
        : 'Tinggi badan (cm)';
    final latest = chartMeasurements.isEmpty ? null : chartMeasurements.last;
    final previous = chartMeasurements.length < 2
        ? null
        : chartMeasurements[chartMeasurements.length - 2];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(
          'Grafik pertumbuhan',
          'Pantau perubahan berat dan tinggi dari setiap pengukuran.',
        ),
        const SizedBox(height: 12),
        _card(
          child: chartMeasurements.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Belum ada data pengukuran untuk menampilkan grafik.',
                    style: TextStyle(
                      color: _HomeColors.muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Badge(
                      label: 'Titik grafik mengikuti tanggal pengukuran',
                      color: _HomeColors.dark,
                      background: _HomeColors.pale,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${chartMeasurements.first.tanggalLabel} - ${chartMeasurements.last.tanggalLabel}',
                      style: const TextStyle(
                        color: _HomeColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      latest == null
                          ? ''
                          : 'Terbaru: ${latest.beratLabel} kg • ${latest.tinggiLabel} cm',
                      style: const TextStyle(
                        color: _HomeColors.muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    if (latest != null && previous != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Perubahan dari pengukuran sebelumnya: '
                          '${_formatGrowthChange(latest.beratBadan - previous.beratBadan)} kg • '
                          '${_formatGrowthChange(latest.tinggiBadan - previous.tinggiBadan)} cm',
                          style: const TextStyle(
                            color: _HomeColors.muted,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SegmentedButton<_GrowthMetric>(
                      segments: const [
                        ButtonSegment(
                          value: _GrowthMetric.weight,
                          label: Text('Berat (kg)'),
                        ),
                        ButtonSegment(
                          value: _GrowthMetric.height,
                          label: Text('Tinggi (cm)'),
                        ),
                      ],
                      selected: {_selectedGrowthMetric},
                      onSelectionChanged: (selection) {
                        setState(() => _growthMetric = selection.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sumbu vertikal: $metricLabel',
                      style: const TextStyle(
                        color: _HomeColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Semantics(
                      image: true,
                      label:
                          'Grafik $metricLabel dengan ${chartMeasurements.length} data pengukuran.',
                      child: SizedBox(
                        height: 230,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _GrowthChartPainter(
                            chartMeasurements,
                            metric: _selectedGrowthMetric,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: _HomeColors.line),
                    const SizedBox(height: 14),
                    const Text(
                      'Rincian pengukuran',
                      style: TextStyle(
                        color: _HomeColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (
                      var index = 0;
                      index < chartMeasurements.length;
                      index++
                    ) ...[
                      if (index > 0)
                        const Divider(height: 18, color: _HomeColors.line),
                      _GrowthMeasurementDetail(
                        measurement: chartMeasurements[index],
                        isLatest: index == chartMeasurements.length - 1,
                        previous: index == 0
                            ? null
                            : chartMeasurements[index - 1],
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    final history = (_measurements.toList()
      ..sort((a, b) => b.tanggal.compareTo(a.tanggal)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(
          'Riwayat pengukuran',
          history.isEmpty
              ? 'Belum ada data anak'
              : '${history.length} catatan tersimpan',
        ),
        const SizedBox(height: 12),
        _card(
          child: history.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Riwayat pengukuran belum tersedia untuk anak ini.',
                    style: TextStyle(
                      color: _HomeColors.muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < history.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 32, color: _HomeColors.line),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: ValueKey('measurement-history-${history[i].id}'),
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => MeasurementDetailScreen(
                                measurement: history[i],
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        history[i].tanggalLabel,
                                        style: const TextStyle(
                                          color: _HomeColors.ink,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${history[i].beratLabel} kg  •  ${history[i].tinggiLabel} cm',
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
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: _HomeColors.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

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
      if (_articlesLoading)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: _HomeColors.primary),
          ),
        )
      else if (_articlesError != null)
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gagal memuat artikel: $_articlesError',
                style: const TextStyle(color: _HomeColors.muted, height: 1.5),
              ),
              TextButton(
                onPressed: _loadArticles,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        )
      else if (_articles.isEmpty)
        _card(
          child: const Text(
            'Belum ada artikel edukasi yang tersedia.',
            style: TextStyle(color: _HomeColors.muted, height: 1.5),
          ),
        )
      else
        for (final article in _articles)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconTile(
                    Icons.menu_book_rounded,
                    _HomeColors.primary,
                    _HomeColors.pale,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.kategori.toUpperCase(),
                          style: const TextStyle(
                            color: _HomeColors.primary,
                            fontSize: 10,
                            letterSpacing: .6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          article.judul,
                          style: const TextStyle(
                            color: _HomeColors.ink,
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (article.ringkasan.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            article.ringkasan,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _HomeColors.muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
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

class _GrowthMeasurementDetail extends StatelessWidget {
  const _GrowthMeasurementDetail({
    required this.measurement,
    required this.isLatest,
    required this.previous,
  });

  final Pengukuran measurement;
  final bool isLatest;
  final Pengukuran? previous;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              measurement.tanggalLabel,
              style: const TextStyle(
                color: _HomeColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isLatest)
            const _Badge(
              label: 'Terbaru',
              color: _HomeColors.dark,
              background: _HomeColors.pale,
            ),
        ],
      ),
      const SizedBox(height: 5),
      Wrap(
        spacing: 16,
        runSpacing: 4,
        children: [
          Text(
            'Berat: ${measurement.beratLabel} kg',
            style: const TextStyle(color: _HomeColors.muted, fontSize: 12),
          ),
          Text(
            'Tinggi: ${measurement.tinggiLabel} cm',
            style: const TextStyle(color: _HomeColors.muted, fontSize: 12),
          ),
        ],
      ),
      if (previous != null) ...[
        const SizedBox(height: 4),
        Text(
          'Perubahan: ${_formatGrowthChange(measurement.beratBadan - previous!.beratBadan)} kg • '
          '${_formatGrowthChange(measurement.tinggiBadan - previous!.tinggiBadan)} cm',
          style: const TextStyle(color: _HomeColors.muted, fontSize: 11),
        ),
      ],
    ],
  );
}

String _formatGrowthChange(double change) {
  if (change.abs() < 0.005) return 'tetap';
  final sign = change > 0 ? '+' : '';
  final value = change
      .toStringAsFixed(1)
      .replaceFirst(RegExp(r'\.0$'), '')
      .replaceAll('.', ',');
  return '$sign$value';
}

class _GrowthChartPainter extends CustomPainter {
  final List<Pengukuran> measurements;
  final _GrowthMetric metric;

  const _GrowthChartPainter(this.measurements, {required this.metric});

  double _value(Pengukuran measurement) => metric == _GrowthMetric.weight
      ? measurement.beratBadan
      : measurement.tinggiBadan;

  String _formatValue(double value) => value
      .toStringAsFixed(1)
      .replaceFirst(RegExp(r'\.0$'), '')
      .replaceAll('.', ',');

  String _dateLabel(DateTime date) => '${date.day}/${date.month}';

  @override
  void paint(Canvas canvas, Size size) {
    if (measurements.isEmpty) return;

    final sorted = measurements.toList()
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));
    final values = sorted.map(_value).toList();
    final dataMax = values.reduce((a, b) => a > b ? a : b);
    final dataMin = values.reduce((a, b) => a < b ? a : b);
    final dataRange = dataMax - dataMin;
    final minimumPadding = metric == _GrowthMetric.weight ? 0.5 : 1.0;
    final padding = dataRange.abs() < 0.001 ? minimumPadding : dataRange * 0.15;
    final minValue = (dataMin - padding).clamp(0.0, double.infinity);
    final maxValue = dataMax + padding;
    final range = maxValue - minValue;

    const leftInset = 48.0;
    const rightInset = 12.0;
    const topInset = 18.0;
    const bottomInset = 32.0;
    final chartWidth = size.width - leftInset - rightInset;
    final chartHeight = size.height - topInset - bottomInset;

    final gridPaint = Paint()
      ..color = const Color(0xFFE9EDF2)
      ..strokeWidth = 1;
    for (var index = 0; index < 5; index++) {
      final y = topInset + chartHeight * index / 4;
      canvas.drawLine(
        Offset(leftInset, y),
        Offset(size.width - rightInset, y),
        gridPaint,
      );

      final value = maxValue - range * index / 4;
      final label = TextPainter(
        text: TextSpan(
          text: _formatValue(value),
          style: const TextStyle(color: _HomeColors.muted, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: leftInset - 6);
      label.paint(
        canvas,
        Offset(
          0,
          (y - label.height / 2).clamp(0.0, size.height - label.height),
        ),
      );
    }

    final growthPath = Path();
    final points = <Offset>[];
    for (var index = 0; index < sorted.length; index++) {
      final value = _value(sorted[index]);
      final x =
          leftInset +
          chartWidth * (sorted.length == 1 ? 0 : index / (sorted.length - 1));
      final normalized = (value - minValue) / range;
      final y = topInset + chartHeight * (1 - normalized);
      final point = Offset(x, y);
      points.add(point);
      if (index == 0) {
        growthPath.moveTo(point.dx, point.dy);
      } else {
        growthPath.lineTo(point.dx, point.dy);
      }
    }

    final linePaint = Paint()
      ..color = _HomeColors.primary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(growthPath, linePaint);

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      canvas.drawCircle(point, 4, Paint()..color = Colors.white);
      canvas.drawCircle(point, 3, Paint()..color = _HomeColors.primary);

      if (sorted.length <= 6) {
        final valueLabel = TextPainter(
          text: TextSpan(
            text: _formatValue(values[index]),
            style: const TextStyle(
              color: _HomeColors.ink,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final labelY = index.isEven
            ? point.dy - valueLabel.height - 7
            : point.dy + 7;
        valueLabel.paint(
          canvas,
          Offset(
            (point.dx - valueLabel.width / 2).clamp(
              leftInset,
              size.width - rightInset - valueLabel.width,
            ),
            labelY.clamp(
              topInset,
              size.height - bottomInset - valueLabel.height,
            ),
          ),
        );
      }
    }

    final labelCount = sorted.length <= 5 ? sorted.length : 5;
    final labelIndexes = <int>{};
    for (var index = 0; index < labelCount; index++) {
      labelIndexes.add(
        labelCount == 1
            ? 0
            : ((sorted.length - 1) * index / (labelCount - 1)).round(),
      );
    }
    for (final index in labelIndexes) {
      final dateLabel = TextPainter(
        text: TextSpan(
          text: _dateLabel(sorted[index].tanggal),
          style: const TextStyle(color: _HomeColors.muted, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final x =
          leftInset +
          chartWidth * (sorted.length == 1 ? 0.5 : index / (sorted.length - 1));
      dateLabel.paint(
        canvas,
        Offset(
          (x - dateLabel.width / 2).clamp(
            leftInset,
            size.width - rightInset - dateLabel.width,
          ),
          size.height - dateLabel.height,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) =>
      oldDelegate.metric != metric ||
      oldDelegate.measurements.length != measurements.length ||
      oldDelegate.measurements.any(
        (element) => !measurements.contains(element),
      );
}
