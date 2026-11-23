import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String title;
  final String highlight;
  final String description;
  final String badge;
  final bool showBackButton;
  final bool showBranding;

  const ProfileHeader({
    super.key,
    required this.title,
    required this.highlight,
    required this.description,
    this.badge = 'Profil',
    this.showBackButton = false,
    this.showBranding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 64,
            child: CustomPaint(painter: _ProfileHeaderWavePainter()),
          ),
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (showBackButton) ...[
                        IconButton(
                          tooltip: 'Kembali',
                          onPressed: () => Navigator.of(context).pop(),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withValues(
                              alpha: .15,
                            ),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: .35),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 16),
                      ],

                      if (showBranding) ...[
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
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else
                        const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD1DD),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Color(0xFF881438),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD66B),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      highlight,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF851735),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderWavePainter extends CustomPainter {
  const _ProfileHeaderWavePainter();

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
    canvas.drawPath(cream, Paint()..color = const Color(0xFFFFF7F4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
