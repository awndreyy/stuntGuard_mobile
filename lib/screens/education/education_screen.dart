import 'package:flutter/material.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});
  @override
  Widget build(BuildContext context) => ScreenContent(
        title: 'Edukasi',
        subtitle: 'Artikel pertumbuhan, gizi, dan kesehatan anak.',
        children: [
          const SurfaceCard(child: Row(children: [
            Icon(Icons.menu_book_outlined, color: SG.primary),
            SizedBox(width: 12),
            Expanded(child: Text('Artikel akan dimuat dari data informasi Laravel.')),
          ])),
          const SizedBox(height: 14),
          const Text('Kategori konten', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final title in ['Pertumbuhan Anak', 'Pencegahan Stunting', 'Gizi dan MPASI']) ...[
            SurfaceCard(child: Row(children: [
              const Icon(Icons.article_outlined, color: SG.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
            ])),
            const SizedBox(height: 10),
          ],
        ],
      );
}
