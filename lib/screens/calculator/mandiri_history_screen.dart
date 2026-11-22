import 'package:flutter/material.dart';

import '../../models/mandiri_record.dart';
import '../../services/mandiri_history_service.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';
import 'mandiri_detail_screen.dart';

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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Riwayat Pengecekan Mandiri')),
    body: FutureBuilder<List<MandiriRecord>>(
      future: _records,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tidak dapat membuka riwayat: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => setState(_reload),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }
        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 46, color: SG.primary),
                  SizedBox(height: 14),
                  Text(
                    'Belum ada riwayat mandiri',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hitung Z-score melalui Kalkulator, lalu tekan '
                    'Simpan ke Riwayat Mandiri.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const Text(
              'Catatan pribadi di perangkat ini. Tidak digunakan '
              'untuk grafik maupun data resmi petugas.',
              style: TextStyle(fontSize: 12, color: SG.muted),
            ),
            const SizedBox(height: 16),
            for (final record in records) ...[
              SurfaceCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: SG.pale,
                    child: Icon(Icons.child_care, color: SG.primary),
                  ),
                  title: Text(
                    record.childName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${_dateLabel(record.measuredAt)}\n'
                    '${_number(record.weight)} kg  ·  ${_number(record.height)} cm\n'
                    'Pengecekan mandiri',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MandiriDetailScreen(record: record),
                      ),
                    );
                    if (mounted) setState(_reload);
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    ),
  );
}

String _number(double value) => value.toStringAsFixed(1).replaceAll('.', ',');
String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';
