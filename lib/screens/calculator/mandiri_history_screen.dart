import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/mandiri_record.dart';
import '../../services/mandiri_history_service.dart';
import 'mandiri_detail_screen.dart';
import 'widgets/calculator_components.dart';
import 'widgets/calculator_header.dart';

class MandiriHistoryScreen extends StatefulWidget {
  const MandiriHistoryScreen({super.key});

  @override
  State<MandiriHistoryScreen> createState() => _MandiriHistoryScreenState();
}

class _MandiriHistoryScreenState extends State<MandiriHistoryScreen> {
  final _service = MandiriHistoryService();
  late Future<List<MandiriRecord>> _records;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _records = _service.list();

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
                  title: 'Riwayat Mandiri',
                  badgeText: 'Tersimpan di Perangkat',
                  subtitle:
                      'Catatan pengecekan mandiri orang tua, terpisah dari data resmi petugas.',
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 0),
                      child: FutureBuilder<List<MandiriRecord>>(
                        future: _records,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const CalcCard(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 28),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: CalcColors.primary,
                                  ),
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return CalcCard(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: CalcColors.primary,
                                    size: 38,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tidak dapat membuka riwayat: ${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: CalcColors.muted,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  OutlinedButton.icon(
                                    onPressed: () => setState(_reload),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: CalcColors.primary,
                                      side: const BorderSide(
                                        color: CalcColors.line,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Coba lagi'),
                                  ),
                                ],
                              ),
                            );
                          }

                          final records = snapshot.data ?? [];
                          if (records.isEmpty) {
                            return CalcCard(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: CalcColors.pale,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Icon(
                                      Icons.history_rounded,
                                      size: 30,
                                      color: CalcColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Belum ada riwayat mandiri',
                                    style: TextStyle(
                                      color: CalcColors.ink,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Hitung Z-score melalui Kalkulator Gizi, lalu tekan '
                                    'Simpan ke Riwayat Mandiri untuk menyimpannya di HP.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: CalcColors.muted,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CalcSectionTitle(
                                title: 'Catatan Pengecekan',
                                subtitle:
                                    '${records.length} catatan tersimpan di perangkat ini.',
                              ),
                              const SizedBox(height: 14),
                              for (final record in records) ...[
                                _MandiriRecordTile(
                                  record: record,
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MandiriDetailScreen(record: record),
                                      ),
                                    );
                                    if (mounted) setState(_reload);
                                  },
                                ),
                                const SizedBox(height: 12),
                              ],
                            ],
                          );
                        },
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

class _MandiriRecordTile extends StatelessWidget {
  final MandiriRecord record;
  final VoidCallback onTap;

  const _MandiriRecordTile({
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: CalcColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: CalcColors.pale,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.child_care_rounded,
                    color: CalcColors.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.childName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: CalcColors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CalcColors.pale,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _dateLabel(record.measuredAt),
                            style: const TextStyle(
                              color: CalcColors.dark,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_number(record.weight)} kg  •  ${_number(record.height)} cm  •  '
                      '${record.bodyPosition == 'berdiri' ? 'Berdiri' : 'Terlentang'}',
                      style: const TextStyle(
                        color: CalcColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: CalcColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _number(double value) => value.toStringAsFixed(1).replaceAll('.', ',');
String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';