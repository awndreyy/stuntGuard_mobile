import 'package:flutter/material.dart';

import '../../models/pengukuran.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';
import '../../widgets/who_result_card.dart';

class MeasurementDetailScreen extends StatelessWidget {
  const MeasurementDetailScreen({super.key, required this.measurement});

  final Pengukuran measurement;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detail Pengukuran')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                measurement.tanggalLabel,
                style: const TextStyle(
                  color: SG.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${measurement.beratLabel} kg  •  ${measurement.tinggiLabel} cm',
                style: const TextStyle(color: SG.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (measurement.hasil case final result?)
          WhoResultCard(result: result)
        else
          const SurfaceCard(
            child: Text(
              'Hasil WHO untuk catatan ini belum tersedia.',
              style: TextStyle(color: SG.muted, height: 1.5),
            ),
          ),
      ],
    ),
  );
}
