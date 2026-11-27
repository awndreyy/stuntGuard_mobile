import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/mandiri_record.dart';
import '../../services/mandiri_history_service.dart';
import '../../widgets/who_result_card.dart';
import 'widgets/calculator_components.dart';
import 'widgets/calculator_header.dart';

class MandiriDetailScreen extends StatelessWidget {
  const MandiriDetailScreen({super.key, required this.record});

  final MandiriRecord record;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Hapus pengecekan mandiri?',
          style: TextStyle(
            color: CalcColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Catatan akan dihapus dari HP dan tidak dapat dipulihkan. '
          'Data pengukuran resmi tidak terpengaruh.',
          style: TextStyle(
            color: CalcColors.muted,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(foregroundColor: CalcColors.muted),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: CalcColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted || record.id == null) return;
    try {
      await MandiriHistoryService().delete(record.id!);
      if (context.mounted) Navigator.pop(context);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus riwayat: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: CalcColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final gutter = constraints.maxWidth > 600 ? 32.0 : 20.0;
            return ListView(
              padding: EdgeInsets.only(bottom: 36 + bottomInset),
              children: [
                CalcSubPageHeader(
                  gutter: gutter,
                  title: record.childName,
                  badgeText: 'Pengecekan Mandiri',
                  subtitle: 'Diukur pada ${_date(record.measuredAt)}',
                  trailingAction: OutlinedButton.icon(
                    onPressed: () => _delete(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: .15),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: .35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text(
                      'Hapus',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const CalcSectionTitle(
                            title: 'Data Pengukuran',
                            subtitle: 'Rincian antropometri yang dicatat.',
                          ),
                          const SizedBox(height: 12),
                          CalcCard(
                            child: Column(
                              children: [
                                _DetailRow(
                                  icon: Icons.monitor_weight_outlined,
                                  label: 'Berat badan',
                                  value: '${_number(record.weight)} kg',
                                ),
                                const Divider(
                                  height: 22,
                                  color: CalcColors.line,
                                ),
                                _DetailRow(
                                  icon: Icons.straighten_rounded,
                                  label: 'Panjang / tinggi',
                                  value: '${_number(record.height)} cm',
                                ),
                                const Divider(
                                  height: 22,
                                  color: CalcColors.line,
                                ),
                                _DetailRow(
                                  icon: Icons.accessibility_new_rounded,
                                  label: 'Posisi badan',
                                  value: record.bodyPosition == 'berdiri'
                                      ? 'Berdiri'
                                      : 'Terlentang',
                                ),
                                const Divider(
                                  height: 22,
                                  color: CalcColors.line,
                                ),
                                _DetailRow(
                                  icon: Icons.wc_rounded,
                                  label: 'Jenis kelamin',
                                  value: _gender(record.gender),
                                ),
                                if (record.headCircumference != null) ...[
                                  const Divider(
                                    height: 22,
                                    color: CalcColors.line,
                                  ),
                                  _DetailRow(
                                    icon: Icons.face_retouching_natural_rounded,
                                    label: 'Lingkar kepala',
                                    value:
                                        '${_number(record.headCircumference!)} cm',
                                  ),
                                ],
                                if (record.lila != null) ...[
                                  const Divider(
                                    height: 22,
                                    color: CalcColors.line,
                                  ),
                                  _DetailRow(
                                    icon: Icons.fitness_center_rounded,
                                    label: 'LiLA',
                                    value: '${_number(record.lila!)} cm',
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          const CalcSectionTitle(
                            title: 'Hasil Analisis',
                            subtitle:
                                'Evaluasi Z-score berdasarkan data di atas.',
                          ),
                          const SizedBox(height: 12),
                          WhoResultCard(result: record.result),
                          const SizedBox(height: 14),
                          const CalcCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: CalcColors.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Hasil ini adalah estimasi pengukuran mandiri orang tua, '
                                    'bukan pemeriksaan resmi. Untuk memastikan kondisi pertumbuhan '
                                    'anak, lakukan pengukuran bersama petugas kesehatan.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.5,
                                      color: CalcColors.muted,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: CalcColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: CalcColors.muted, fontSize: 13),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: CalcColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

String _number(double value) => value.toStringAsFixed(1).replaceAll('.', ',');
String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';
String _gender(String value) {
  final gender = value.toLowerCase();
  if (gender == 'l' || gender.contains('laki')) return 'Laki-laki';
  if (gender == 'p' || gender.contains('perempuan')) return 'Perempuan';
  return value;
}