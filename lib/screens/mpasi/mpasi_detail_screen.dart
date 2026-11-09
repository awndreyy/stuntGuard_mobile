import 'package:flutter/material.dart';

import '../../models/mpasi.dart';
import '../../widgets/mpasi_recipe_image.dart';

class _DetailColors {
  static const primary = Color(0xFFC8103D);
  static const dark = Color(0xFF8B1038);
  static const ink = Color(0xFF202738);
  static const muted = Color(0xFF657086);
  static const line = Color(0xFFE6EBF1);
  static const pale = Color(0xFFF7F9FC);
}

class MpasiDetailScreen extends StatelessWidget {
  final Mpasi resep;
  const MpasiDetailScreen({super.key, required this.resep});

  // Mpasi.gizi API order: energy, carbohydrate, fat, protein, iron, zinc.
  static const _nutrition = [
    _NutritionSpec('Energi', 0, Color(0xFFC8103D), Color(0xFFFFF2F5)),
    _NutritionSpec('Protein', 3, Color(0xFF98501C), Color(0xFFFFFAEE)),
    _NutritionSpec('Lemak', 2, Color(0xFF16705B), Color(0xFFF0FCF5)),
    _NutritionSpec('Karbohidrat', 1, Color(0xFF3D4B61), Color(0xFFF6F8FC)),
    _NutritionSpec('Zat Besi (Fe)', 4, Color(0xFFC8103D), Color(0xFFFFF1F3)),
    _NutritionSpec('Seng (Zinc)', 5, Color(0xFF146493), Color(0xFFEEF8FF)),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _header(context)),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  32 + MediaQuery.viewPaddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      resep.nama,
                      style: const TextStyle(
                        color: _DetailColors.ink,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        letterSpacing: -.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kategori Usia: ${resep.usia}',
                      style: const TextStyle(
                        color: _DetailColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _metaChip(
                          Icons.access_time_rounded,
                          '${resep.waktuMenit} menit',
                        ),
                        _metaChip(
                          Icons.rice_bowl_outlined,
                          '${resep.jumlahPorsi} porsi',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: _DetailColors.line),
                    const SizedBox(height: 24),
                    const Text(
                      'KANDUNGAN GIZI PER PORSI',
                      style: TextStyle(
                        color: _DetailColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _nutritionGrid(context),
                    const SizedBox(height: 32),
                    _sectionTitle('Bahan & Takaran'),
                    const SizedBox(height: 16),
                    _ingredients(),
                    const SizedBox(height: 32),
                    _sectionTitle('Langkah Pembuatan'),
                    const SizedBox(height: 16),
                    if (resep.langkah.isEmpty)
                      _empty('Langkah pembuatan belum tersedia.')
                    else
                      for (var index = 0; index < resep.langkah.length; index++)
                        _step(index),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBED),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF2DB93)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExcludeSemantics(
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF8A551D),
                              size: 22,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Catatan Resep',
                                  style: TextStyle(
                                    color: Color(0xFF754516),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Takaran bahan dan kandungan gizi per porsi mengikuti data resep yang dikelola admin.',
                                  style: TextStyle(
                                    color: Color(0xFF754516),
                                    fontSize: 13,
                                    height: 1.6,
                                  ),
                                ),
                              ],
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
        ),
      ],
    ),
  );

  Widget _header(BuildContext context) => ClipPath(
    clipper: _DetailWaveClipper(),
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_DetailColors.primary, _DetailColors.dark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Kembali ke daftar resep',
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: .15),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: .35),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'StuntGuard • Jember Bebas Stunting',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    image: true,
                    label: 'Foto ${resep.nama}',
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 240),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipOval(
                          child: ColoredBox(
                            color: _DetailColors.pale,
                            child: MpasiRecipeImage(
                              url: resep.gambarUrl,
                              size: 72,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _metaChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: _DetailColors.pale,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: _DetailColors.line),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Icon(icon, color: _DetailColors.primary, size: 20),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: _DetailColors.muted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _nutritionGrid(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
      final columns = constraints.maxWidth < 280
          ? 1
          : largeText
          ? 2
          : 3;
      final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final spec in _nutrition)
            SizedBox(
              width: width,
              child: Container(
                constraints: const BoxConstraints(minHeight: 100),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: spec.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: spec.color.withValues(alpha: .15)),
                ),
                child: Column(
                  children: [
                    Text(
                      spec.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: spec.color,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      spec.index < resep.gizi.length
                          ? resep.gizi[spec.index]
                          : '—',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: spec.color,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );

  Widget _ingredients() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: _DetailColors.pale,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _DetailColors.line),
    ),
    child: resep.bahan.isEmpty
        ? _empty('Bahan dan takaran belum tersedia.')
        : Column(
            children: [
              for (var i = 0; i < resep.bahan.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: _DetailColors.line),
                _IngredientRow(text: resep.bahan[i]),
              ],
            ],
          ),
  );

  Widget _step(int index) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: _DetailColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (index != resep.langkah.length - 1)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        color: const Color(0xFFFFE4EB),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _DetailColors.line),
              ),
              child: Text(
                resep.langkah[index],
                style: const TextStyle(
                  color: _DetailColors.ink,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _sectionTitle(String title) => Row(
    children: [
      Container(
        width: 7,
        height: 18,
        decoration: BoxDecoration(
          color: _DetailColors.primary,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: _DetailColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );

  Widget _empty(String message) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      message,
      style: const TextStyle(
        color: _DetailColors.muted,
        fontSize: 14,
        height: 1.5,
      ),
    ),
  );
}

/// Split only explicit quantity patterns; keep unrecognized API text intact.
class _IngredientRow extends StatelessWidget {
  final String text;
  const _IngredientRow({required this.text});

  static const _amount =
      r'(?:\d+(?:[.,/]\d+)?(?:\s*[-–]\s*\d+(?:[.,]\d+)?)?|[½¼¾])\s*(?:sendok makan|sendok teh|sdm|sdt|gram|gr|kg|mg|ml|liter|g|l|buah|butir|siung|lembar|potong|ruas|ikat|cangkir)(?:\s*\([^)]*\))?';

  @override
  Widget build(BuildContext context) {
    var name = text.trim();
    String? amount;
    final prefix = RegExp(
      r'^(' + _amount + r')\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(name);
    final suffix = RegExp(
      r'^(.+?)\s*(?::|[-–])?\s+(' + _amount + r'|secukupnya)$',
      caseSensitive: false,
    ).firstMatch(name);
    if (prefix != null) {
      amount = prefix.group(1);
      name = prefix.group(2)!;
    } else if (suffix != null) {
      name = suffix.group(1)!.replaceFirst(RegExp(r'\s*[:\-–]\s*$'), '').trim();
      amount = suffix.group(2);
    }
    final quantity = amount;
    final nameWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Icon(Icons.circle, size: 6, color: _DetailColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              color: _DetailColors.ink,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
    final quantityWidget = quantity == null
        ? null
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _DetailColors.line),
            ),
            child: Text(
              quantity,
              style: const TextStyle(
                color: _DetailColors.dark,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (quantityWidget == null) return nameWidget;
          if (constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(14) > 20) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                nameWidget,
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: quantityWidget,
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: nameWidget),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: quantityWidget),
            ],
          );
        },
      ),
    );
  }
}

class _NutritionSpec {
  final String label;
  final int index;
  final Color color;
  final Color background;
  const _NutritionSpec(this.label, this.index, this.color, this.background);
}

class _DetailWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..lineTo(0, size.height - 36)
    ..quadraticBezierTo(
      size.width * .4,
      size.height + 24,
      size.width * .72,
      size.height - 20,
    )
    ..quadraticBezierTo(
      size.width * .88,
      size.height - 48,
      size.width,
      size.height - 24,
    )
    ..lineTo(size.width, 0)
    ..close();
  @override
  bool shouldReclip(covariant _DetailWaveClipper oldClipper) => false;
}
