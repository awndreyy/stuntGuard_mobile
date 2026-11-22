import 'package:flutter/material.dart';

import '../../../models/mpasi.dart';
import '../../../widgets/mpasi_recipe_image.dart';

class _HeaderColors {
  static const primary = Color(0xFFC8103D);
  static const dark = Color(0xFF8B1038);
  static const pale = Color(0xFFF7F9FC);
}

class MpasiDetailHeader extends StatelessWidget {
  final Mpasi resep;
  const MpasiDetailHeader({super.key, required this.resep});

  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: _DetailWaveClipper(),
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_HeaderColors.primary, _HeaderColors.dark],
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
                            color: _HeaderColors.pale,
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
