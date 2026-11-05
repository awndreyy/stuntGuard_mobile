import 'package:flutter/material.dart';

import '../../models/mpasi.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/mpasi_recipe_image.dart';

// HALAMAN DETAIL RESEP
class MpasiDetailScreen extends StatelessWidget {
  final Mpasi resep;

  const MpasiDetailScreen({super.key, required this.resep});

  static const _nutritionLabels = [
    'Energi',
    'Karbohidrat',
    'Lemak',
    'Protein',
    'Zat Besi',
    'Seng',
  ];

  static const _nutritionIcons = [
    Icons.bolt_rounded,
    Icons.grain_rounded,
    Icons.water_drop_rounded,
    Icons.fitness_center_rounded,
    Icons.health_and_safety_rounded,
    Icons.science_rounded,
  ];

  static const _nutritionColors = [
    Color(0xFFD81B60),
    Color(0xFFC85B18),
    Color(0xFFB77500),
    Color(0xFF1976D2),
    Color(0xFF00896B),
    Color(0xFF7B1FA2),
  ];

  static const _nutritionBackgrounds = [
    Color(0xFFFCECF2),
    Color(0xFFFFF4E9),
    Color(0xFFFFF9E9),
    Color(0xFFEDF5FF),
    Color(0xFFEAFBF4),
    Color(0xFFF5F0FF),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: SG.primary,
        title: const Text('Detail Resep'),
        leading: BackButton(
          color: SG.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
          children: [
            // FOTO / ILUSTRASI RESEP
            Container(
              height: 175,
              decoration: BoxDecoration(
                color: SG.pale,
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: MpasiRecipeImage(url: resep.gambarUrl, size: 80),
            ),

            const SizedBox(height: 18),

            Text(
              resep.nama,
              style: const TextStyle(
                color: SG.primary,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metaChip(
                  Icons.child_care_rounded,
                  resep.usia,
                  highlighted: true,
                ),
                _metaChip(Icons.schedule_rounded, '${resep.waktuMenit} menit'),
                _metaChip(
                  Icons.restaurant_rounded,
                  '${resep.jumlahPorsi} porsi',
                ),
              ],
            ),

            const SizedBox(height: 26),

            _sectionTitle(
              Icons.monitor_heart_rounded,
              'Kandungan Gizi per Porsi',
            ),

            const SizedBox(height: 12),

            // ENAM NILAI GIZI DALAM DUA KOLOM
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _nutritionLabels.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 82,
              ),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _nutritionBackgrounds[index],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _nutritionIcons[index],
                        color: _nutritionColors[index],
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nutritionLabels[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: SG.muted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              resep.gizi[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _nutritionColors[index],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 26),

            _sectionTitle(
              Icons.shopping_basket_rounded,
              'Bahan yang Dibutuhkan',
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: SG.line),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  for (final bahan in resep.bahan)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: SG.primary,
                            size: 19,
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              bahan,
                              style: const TextStyle(
                                fontSize: 13,
                                color: SG.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            _sectionTitle(Icons.restaurant_menu_rounded, 'Cara Pembuatan'),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: SG.line),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < resep.langkah.length;
                    index++
                  ) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: SG.pale,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: SG.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                resep.langkah[index],
                                style: const TextStyle(
                                  color: SG.ink,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < resep.langkah.length - 1)
                      const Divider(color: SG.line),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Kandungan gizi per porsi sesuai data resep yang dikelola admin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SG.muted, fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label, {bool highlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: highlighted ? SG.pale : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: highlighted ? SG.primary : SG.muted),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: highlighted ? SG.primary : SG.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: SG.primary, size: 21),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: SG.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
