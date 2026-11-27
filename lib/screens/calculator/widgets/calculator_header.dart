import 'package:flutter/material.dart';

import 'calculator_components.dart';

class CalculatorHeader extends StatelessWidget {
  final double gutter;
  final VoidCallback onOpenHistory;

  const CalculatorHeader({
    super.key,
    required this.gutter,
    required this.onOpenHistory,
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
            child: CustomPaint(painter: _CalcHeaderWavePainter()),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 72),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            excludeFromSemantics: true,
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
                        OutlinedButton.icon(
                          onPressed: onOpenHistory,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withValues(alpha: .15),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: .35),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(Icons.history_rounded, size: 18),
                          label: const Text(
                            'Riwayat',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Kalkulator Gizi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: CalcColors.yellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Standar Antropometri WHO',
                        style: TextStyle(
                          color: Color(0xFF851735),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pantau status pertumbuhan si kecil secara mandiri kapan saja.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalcSubPageHeader extends StatelessWidget {
  final double gutter;
  final String title;
  final String badgeText;
  final String subtitle;
  final Widget? trailingAction;

  const CalcSubPageHeader({
    super.key,
    required this.gutter,
    required this.title,
    required this.badgeText,
    required this.subtitle,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.viewPaddingOf(context).top;
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
            child: CustomPaint(painter: _CalcHeaderWavePainter()),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(gutter, topPadding + 14, gutter, 72),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Material(
                          color: Colors.white.withValues(alpha: .18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: .35),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: const SizedBox(
                              width: 42,
                              height: 42,
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'StuntGuard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
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
                        if (trailingAction != null) trailingAction!,
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: CalcColors.yellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Color(0xFF851735),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalcHeaderWavePainter extends CustomPainter {
  const _CalcHeaderWavePainter();

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
    canvas.drawPath(cream, Paint()..color = CalcColors.background);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}