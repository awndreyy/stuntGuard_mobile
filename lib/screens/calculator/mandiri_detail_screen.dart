import 'package:flutter/material.dart';

import '../../models/mandiri_record.dart';
import '../../services/mandiri_history_service.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';
import '../../widgets/who_result_card.dart';

class MandiriDetailScreen extends StatelessWidget {
  const MandiriDetailScreen({super.key, required this.record});

  final MandiriRecord record;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus pengecekan mandiri?'),
        content: const Text(
          'Catatan akan dihapus dari HP dan tidak dapat dipulihkan. '
          'Data pengukuran resmi tidak terpengaruh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Detail Pengecekan'),
      actions: [
        IconButton(
          tooltip: 'Hapus riwayat',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _delete(context),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SG.primaryDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 29,
                backgroundColor: Colors.white,
                child: Icon(Icons.child_care, size: 32, color: SG.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.childName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _date(record.measuredAt),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'PENGECEKAN MANDIRI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Data Pengukuran',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            children: [
              _DetailRow('Berat badan', '${_number(record.weight)} kg'),
              _DetailRow('Panjang / tinggi', '${_number(record.height)} cm'),
              _DetailRow(
                'Posisi badan',
                record.bodyPosition == 'berdiri' ? 'Berdiri' : 'Terlentang',
              ),
              _DetailRow('Jenis kelamin', _gender(record.gender)),
              if (record.headCircumference != null)
                _DetailRow(
                  'Lingkar kepala',
                  '${_number(record.headCircumference!)} cm',
                ),
              if (record.lila != null)
                _DetailRow('LiLA', '${_number(record.lila!)} cm'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        WhoResultCard(result: record.result),
        const SizedBox(height: 14),
        const SurfaceCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: SG.primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hasil ini adalah estimasi pengukuran mandiri orang tua, '
                  'bukan pemeriksaan resmi. Untuk memastikan kondisi pertumbuhan '
                  'anak, lakukan pengukuran bersama petugas kesehatan.',
                  style: TextStyle(fontSize: 12, height: 1.5, color: SG.muted),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: SG.muted)),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
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
