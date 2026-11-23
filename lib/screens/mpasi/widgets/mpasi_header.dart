import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'mpasi_components.dart';

class MpasiHeader extends StatelessWidget {
  const MpasiHeader({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9F1D47), Color(0xFFCB2458), Color(0xFFE84D78)],
      ),
    ),
    child: Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Dua lapis gelombang mengikuti lebar perangkat.
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 64,
          child: CustomPaint(painter: _MpasiHeaderWavePainter()),
        ),
        // Dekorasi sayuran berada di depan gelombang, tidak menghalangi teks.
        Positioned(
          left: -12,
          bottom: 12,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: -0.26,
              child: Image.asset(
                'assets/images/decorations/wortel.png',
                width: 58,
                height: 66,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          left: 32,
          bottom: 24,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: 0.18,
              child: Image.asset(
                'assets/images/decorations/brokoli.png',
                width: 55,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 96,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: 0.2,
              child: Image.asset(
                'assets/images/decorations/heart.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 70),
            child: Column(
              children: [
                // LOGO DAN NAMA APLIKASI
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Image.asset(
                        'assets/images/logo-StuntGuard.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'StuntGuard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Jember Bebas Stunting',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD1DD),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'MPASI',
                        style: TextStyle(
                          color: Color(0xFF881438),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // JUDUL DAN ANIMASI BAYI
                LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 340;
                    final babyWidth = narrow ? 116.0 : 155.0;
                    return SizedBox(
                      height: narrow ? 145 : 155,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            right: babyWidth - 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MPASI Sehat,',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: narrow ? 20 : 23,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD66B),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Si Kecil Lahap!',
                                        style: TextStyle(
                                          color: const Color(0xFF851735),
                                          fontSize: narrow ? 17 : 21,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Text(
                                  'Temukan menu bergizi sesuai usia '
                                  'untuk dukung tumbuh kembang optimal si kecil.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: narrow ? 10 : 11,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ANIMASI BAYI DI KANAN
                          Positioned(
                            right: -8,
                            bottom: -12,
                            child: Lottie.asset(
                              'assets/animations/bayi_makan.json',
                              width: babyWidth,
                              height: narrow ? 125 : 145,
                              fit: BoxFit.contain,
                              repeat: true,
                              animate: true,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Gelombang dua warna: blush sebagai aksen, cream menyambung konten.
class _MpasiHeaderWavePainter extends CustomPainter {
  const _MpasiHeaderWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final pink = Path()
      ..moveTo(0, height * .29)
      ..cubicTo(
        width * .20,
        height * .72,
        width * .37,
        height * .03,
        width * .58,
        height * .38,
      )
      ..cubicTo(
        width * .74,
        height * .72,
        width * .91,
        height * .31,
        width,
        height * .25,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(pink, Paint()..color = const Color(0xFFFFA8BF));

    final cream = Path()
      ..moveTo(0, height * .66)
      ..cubicTo(
        width * .22,
        height * .96,
        width * .37,
        height * .35,
        width * .58,
        height * .72,
      )
      ..cubicTo(
        width * .77,
        height * 1.03,
        width * .92,
        height * .57,
        width,
        height * .62,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(cream, Paint()..color = MpasiColors.background);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
