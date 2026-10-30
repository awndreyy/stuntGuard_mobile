import 'package:flutter/material.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';

class ManageChildrenScreen extends StatelessWidget {
  const ManageChildrenScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kelola Anak')),
    body: const Padding(
      padding: EdgeInsets.all(20),
      child: SurfaceCard(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.child_care_outlined, size: 42, color: SG.primary),
        SizedBox(height: 12),
        Text('Belum ada data anak', style: TextStyle(fontWeight: FontWeight.w800)),
        SizedBox(height: 8),
        Text('Daftar, tambah, dan ubah anak akan mengambil data dari API Laravel.', textAlign: TextAlign.center),
      ])),
    ),
  );
}
