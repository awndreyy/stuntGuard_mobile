import 'package:flutter/material.dart';

import '../theme/sg_theme.dart';
import 'sg_components.dart';

class WhoResultCard extends StatelessWidget {
  const WhoResultCard({super.key, required this.result});

  final Map<String, dynamic> result;

  static const _unavailable = 'Tidak tersedia / di luar rentang';

  Map<String, dynamic>? _nestedResult(String key) {
    final value = result[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  Object? _firstValue(List<String> keys) {
    for (final key in keys) {
      final value = result[key];
      if (value != null) return value;
    }
    return null;
  }

  String _formatValue(Object? value) {
    if (value == null) return '-';
    final number = value is num
        ? value.toDouble()
        : double.tryParse(value.toString().replaceAll(',', '.'));
    if (number == null) return value.toString();
    return number
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '')
        .replaceAll('.', ',');
  }

  Object? _indicatorValue(String directKey, String nestedKey) {
    final direct = _firstValue([directKey]);
    if (direct != null) return direct;
    return _nestedResult(nestedKey)?['z_score'];
  }

  String _scoreText(String directKey, String nestedKey) {
    final value = _indicatorValue(directKey, nestedKey);
    if (value == null || value.toString().trim().isEmpty) {
      return _unavailable;
    }
    return '${_formatValue(value)} SD';
  }

  double? _mainScore() {
    final value = _indicatorValue('z_score', 'pbu');
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '');
  }

  String _status() =>
      (_firstValue(['ringkasan', 'status_stunting']) ??
              _nestedResult('pbu')?['status'])
          ?.toString() ??
      'Hasil perhitungan tersimpan';

  String _gender() {
    final value = (_firstValue(['jenis_kelamin_label', 'jenis_kelamin']))
        ?.toString();
    if (value == 'L') return 'Laki-laki';
    if (value == 'P') return 'Perempuan';
    return value ?? '-';
  }

  String _position() {
    final value = (_firstValue(['posisi_badan_label', 'posisi_badan']))
        ?.toString();
    if (value == 'terlentang') return 'Terlentang';
    if (value == 'berdiri') return 'Berdiri';
    return value ?? '-';
  }

  Color _statusColor(String status) {
    final value = status.toLowerCase();
    if (value.contains('sangat pendek')) return const Color(0xFFB42318);
    if (value.contains('pendek')) return const Color(0xFFB54708);
    if (value.contains('normal')) return const Color(0xFF13805B);
    if (value.contains('tinggi')) return const Color(0xFF087E8B);
    return SG.primary;
  }

  @override
  Widget build(BuildContext context) {
    final status = _status();
    final statusColor = _statusColor(status);
    final heightIndicator =
        (_firstValue(['indikator_tinggi']) ?? 'PB/U atau TB/U').toString();
    final weightHeightIndicator =
        (_firstValue(['indikator_berat_tinggi', 'indikator_proporsi']) ??
                'BB/PB atau BB/TB')
            .toString();
    final age = _formatValue(_firstValue(['usia_bulan']));
    final weight = _formatValue(_firstValue(['berat', 'berat_badan']));
    final height = _formatValue(
      _firstValue(['tinggi', 'tinggi_input', 'tinggi_badan']),
    );
    final correctedHeight = _firstValue([
      'tinggi_koreksi',
      'panjang_tinggi_terkoreksi',
    ]);
    final score = _mainScore();
    final note = _firstValue(['catatan'])?.toString();
    final lilaScreening = _firstValue(['skrining_lila'])?.toString();

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Hasil perhitungan WHO',
            style: TextStyle(
              color: SG.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SG.soft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _ResultRow(label: 'Jenis kelamin', value: _gender()),
                _ResultRow(label: 'Usia', value: '$age bulan'),
                _ResultRow(
                  label: 'Berat / Tinggi',
                  value: '$weight kg / $height cm',
                ),
                _ResultRow(label: 'Posisi ukur', value: _position()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Indikator WHO (Z-score)',
            style: TextStyle(fontWeight: FontWeight.w700, color: SG.ink),
          ),
          const SizedBox(height: 8),
          _IndicatorRow(label: 'BB/U', value: _scoreText('z_bbu', 'bbu')),
          _IndicatorRow(
            label: heightIndicator,
            value: _scoreText('z_score', 'pbu'),
          ),
          _IndicatorRow(
            label: weightHeightIndicator,
            value: _scoreText('z_bb_tb', 'bbpb'),
          ),
          _IndicatorRow(label: 'LK/U', value: _scoreText('z_lku', 'lku')),
          _IndicatorRow(label: 'LiLA/U', value: _scoreText('z_lilau', 'lilau')),
          if (correctedHeight != null) ...[
            const SizedBox(height: 8),
            Text(
              'Panjang/tinggi terkoreksi: ${_formatValue(correctedHeight)} cm',
              style: const TextStyle(fontSize: 12, color: SG.muted),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: SG.line),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Z-Score ($heightIndicator):',
                  style: const TextStyle(color: SG.muted),
                ),
              ),
              Text(
                _scoreText('z_score', 'pbu'),
                style: const TextStyle(
                  color: SG.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ZScorePanel(
            score: score,
            label: heightIndicator,
            scoreText: _scoreText('z_score', 'pbu'),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SG.pale,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tentang standar WHO',
                  style: TextStyle(
                    color: SG.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'PB/U dan TB/U digunakan untuk skrining pertumbuhan linier menurut usia. Hasil ini bukan diagnosis medis; diskusikan hasil yang mengkhawatirkan dengan tenaga kesehatan.',
                  style: TextStyle(color: SG.muted, fontSize: 12, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: .08),
              border: Border.all(color: statusColor.withValues(alpha: .25)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'INDIKATOR STUNTING ($heightIndicator)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (lilaScreening != null && lilaScreening.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              lilaScreening,
              style: const TextStyle(
                color: SG.muted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            note ?? 'Data sudah tersimpan dan akan muncul di riwayat serta beranda.',
            style: const TextStyle(color: SG.muted, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: SG.muted, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: SG.ink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: SG.muted, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: SG.ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ZScorePanel extends StatelessWidget {
  const _ZScorePanel({
    required this.score,
    required this.label,
    required this.scoreText,
  });

  final double? score;
  final String label;
  final String scoreText;

  @override
  Widget build(BuildContext context) {
    final hasScore = score != null && score!.isFinite;
    final boundedScore = hasScore ? score!.clamp(-3.0, 3.0).toDouble() : null;
    final markerPosition = boundedScore == null ? null : (boundedScore + 3) / 6;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SG.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Posisi Z-score tinggi menurut usia',
                  style: TextStyle(
                    color: SG.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                hasScore ? scoreText : 'Tidak tersedia',
                style: const TextStyle(
                  color: SG.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Penanda menunjukkan hasil $label pada skala -3 sampai +3 SD. Garis putus-putus menandai batas -2 SD.',
            style: const TextStyle(color: SG.muted, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return SizedBox(
                height: 24,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 6,
                      height: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7E5E4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 6,
                      height: 12,
                      width: width / 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFECACA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Positioned(
                      left: width / 6,
                      top: 2,
                      bottom: 1,
                      child: const _DashedThreshold(),
                    ),
                    if (markerPosition != null)
                      Positioned(
                        left: width * markerPosition - 2,
                        top: 1,
                        bottom: 0,
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: SG.ink,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white, width: .5),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 3),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('-3', style: _axisLabelStyle),
              Text('-2', style: _axisLabelStyle),
              Text('0', style: _axisLabelStyle),
              Text('+2', style: _axisLabelStyle),
              Text('+3', style: _axisLabelStyle),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            !hasScore
                ? 'Posisi Z-score belum dapat divisualisasikan karena data tidak tersedia atau di luar rentang.'
                : score! < -3 || score! > 3
                ? 'Hasil berada di luar skala ilustrasi (-3 hingga +3 SD); angka tepatnya tetap ditampilkan di atas.'
                : 'Penanda menggambarkan posisi nilai Z-score pada rentang ilustrasi, bukan diagnosis medis.',
            style: const TextStyle(color: SG.muted, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _DashedThreshold extends StatelessWidget {
  const _DashedThreshold();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DashedThresholdPainter(), size: const Size(2, 22));
}

class _DashedThresholdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 1.5;
    for (var y = 0.0; y < size.height; y += 5) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 2.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedThresholdPainter oldDelegate) => false;
}

const _axisLabelStyle = TextStyle(
  color: SG.muted,
  fontSize: 10,
  fontWeight: FontWeight.w600,
);
