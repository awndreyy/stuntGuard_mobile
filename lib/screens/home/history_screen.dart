import 'package:flutter/material.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Riwayat Pengukuran')),
    body: const Padding(
      padding: EdgeInsets.all(20),
      child: SurfaceCard(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.history, size: 42, color: SG.primary),
        SizedBox(height: 12),
        Text('Belum ada riwayat pengukuran', style: TextStyle(fontWeight: FontWeight.w800)),
        SizedBox(height: 8),
        Text('Riwayat dari petugas dan grafik akan ditampilkan setelah API dihubungkan.', textAlign: TextAlign.center),
      ])),
    ),
  );
}
