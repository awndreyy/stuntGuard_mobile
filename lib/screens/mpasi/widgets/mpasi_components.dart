import 'package:flutter/material.dart';

import '../../../models/mpasi.dart';
import '../../../widgets/mpasi_recipe_image.dart';

// Komponen bersama untuk halaman daftar resep MPASI.

// WARNA 
class MpasiColors {
  static const primary = Color(0xFFC8103D);
  static const dark = Color(0xFF8B1038);
  static const background = Color(0xFFFFF7F4);
  static const ink = Color(0xFF222629);
  static const muted = Color(0xFF725C62);
  static const line = Color(0xFFEDE8EC);
  static const border = Color(0xFFF0BDCA);
  static const pale = Color(0xFFFFEDF1);
  static const olive = Color(0xFF7C6818);
}

// PENCARIAN
class MpasiSearch extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onCleared;

  const MpasiSearch({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onCleared,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFB72859).withValues(alpha: 0.12),
          blurRadius: 20,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      onSubmitted: (_) {
        onSubmitted();
      },
      maxLength: 100,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: Color(0xFF4B2634), fontSize: 14),
      decoration: InputDecoration(
        counterText: '',
        hintText: 'Cari resep MPASI...',
        hintStyle: const TextStyle(color: Color(0xFF93747F), fontSize: 14),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFFE0004D),
          size: 25,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 50,
          minHeight: 48,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Hapus pencarian',
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  controller.clear();
                  onCleared();
                },
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFFFB3CA), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFE0004D), width: 1.8),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
  );
}

// FILTER KATEGORI

class MpasiCategoryFilter extends StatelessWidget {
  final List<String> categories;
  final int selectedCategory;
  final ValueChanged<int> onSelected;

  const MpasiCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < categories.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i == categories.length - 1 ? 0 : 5,
              ),
              child: Semantics(
                button: true,
                selected: selectedCategory == i,
                child: Material(
                  color: selectedCategory == i
                      ? MpasiColors.primary
                      : Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: selectedCategory == i
                          ? MpasiColors.primary
                          : MpasiColors.line,
                    ),
                  ),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () => onSelected(i),
                    child: SizedBox(
                      height: 36,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              categories[i],
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: selectedCategory == i
                                    ? Colors.white
                                    : MpasiColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}


// Recipe Card
class MpasiRecipeCard extends StatelessWidget {
  final Mpasi resep;
  final VoidCallback onTap;
  const MpasiRecipeCard({
    required this.resep,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    // Show actual nutrition from the API; do not infer health claims.
    final protein = resep.gizi.length > 3 ? resep.gizi[3] : '—';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ColoredBox(
                    color: MpasiColors.pale,
                    child: MpasiRecipeImage(url: resep.gambarUrl, size: 48),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: MpasiColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        resep.usia,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: MpasiColors.pale,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Protein $protein',
                      maxLines: 2,
                      style: const TextStyle(
                        color: MpasiColors.dark,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resep.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: MpasiColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (resep.bahan.isNotEmpty) ...[
                    Text(
                      resep.bahan.first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MpasiColors.muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Divider(height: 1, color: MpasiColors.line),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _meta(
                        Icons.access_time_rounded,
                        '${resep.waktuMenit} mnt',
                        MpasiColors.olive,
                      ),
                      _meta(
                        Icons.rice_bowl_outlined,
                        '${resep.jumlahPorsi} porsi',
                        MpasiColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ExcludeSemantics(child: Icon(icon, size: 16, color: color)),
      const SizedBox(width: 4),
      Flexible(
        child: Text(label, style: TextStyle(color: color, fontSize: 12)),
      ),
    ],
  );
}
