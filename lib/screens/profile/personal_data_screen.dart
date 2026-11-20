import 'dart:async';
import 'package:flutter/material.dart';

class PersonalDataScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const PersonalDataScreen({super.key, required this.user});

  static const Color _primaryContainer = Color(0xFFF7E5EA);
  static const Color _onPrimaryContainer = Color(0xFF701230);
  static const Color _surface = Color(0xFFFFFDF9);
  static const Color _surfaceContainer = Color(0xFFFFFFFF);
  static const Color _onSurfaceVariant = Color(0xFF6B5E62);
  static const Color _outlineVariant = Color(0xFFE6DFDC);

  @override
  Widget build(BuildContext context) {
    final name = user['name']?.toString() ?? '-';
    final email = user['email']?.toString() ?? '-';

    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter()),
          ),
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Curved Crimson-Magenta Gradient Hero Banner
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.78, 0.92, 1.0],
                          colors: [
                            Color(0xEB8A153B),
                            Color(0xE0981840),
                            Color(0x73DC356E),
                            Color(0x47F7E5EA),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Brand & Navigation Row
                              _EntranceAnim(
                                delayMs: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Material(
                                          color: const Color(0x26FFFFFF),
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () => Navigator.maybePop(context),
                                            child: const SizedBox(
                                              width: 36,
                                              height: 36,
                                              child: Icon(
                                                Icons.arrow_back,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 36,
                                          height: 36,
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: _surfaceContainer,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Image.asset(
                                            'assets/images/logo-StuntGuard.png',
                                            fit: BoxFit.contain,
                                            excludeFromSemantics: true,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'StuntGuard',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                height: 1.2,
                                              ),
                                            ),
                                            Text(
                                              'Jember Bebas Stunting',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xD9FFFFFF),
                                                height: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _primaryContainer,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'Data Pribadi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Hero Headline
                              const _EntranceAnim(
                                delayMs: 0,
                                child: Text(
                                  'Informasi',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.15,
                                    height: 1.28,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              _EntranceAnim(
                                delayMs: 90,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _primaryContainer,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Akun Orang Tua',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const _EntranceAnim(
                                delayMs: 60,
                                child: Text(
                                  'Detail akun yang terdaftar pada layanan StuntGuard.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.42,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Layered Curved Wave Transition
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: -1,
                      child: SizedBox(
                        height: 36,
                        width: double.infinity,
                        child: CustomPaint(painter: _HeaderWavePainter()),
                      ),
                    ),
                  ],
                ),

                // Personal Data Card
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.25, 0.6],
                      colors: [
                        Color(0xB8F7E5EA),
                        Color(0x38F7E5EA),
                        Color(0x00FFFDF9),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: _EntranceAnim(
                    delayMs: 120,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _surfaceContainer,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _outlineVariant),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          _DataRow(
                            icon: Icons.person_outline,
                            iconBg: const Color(0xB3F7E5EA),
                            iconColor: _onPrimaryContainer,
                            label: 'Nama',
                            value: name,
                          ),
                          const Divider(height: 1, thickness: 1, color: _outlineVariant),
                          _DataRow(
                            icon: Icons.mail_outline,
                            iconBg: _surface,
                            iconColor: _onSurfaceVariant,
                            iconBorderColor: _outlineVariant,
                            label: 'Email',
                            value: email,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color? iconBorderColor;
  final String label;
  final String value;

  const _DataRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.iconBorderColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
              border: iconBorderColor != null
                  ? Border.all(color: iconBorderColor!)
                  : null,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B5E62),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F1A1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntranceAnim extends StatefulWidget {
  final int delayMs;
  final Widget child;

  const _EntranceAnim({required this.delayMs, required this.child});

  @override
  State<_EntranceAnim> createState() => _EntranceAnimState();
}

class _EntranceAnimState extends State<_EntranceAnim> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.08),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _HeaderWavePainter extends CustomPainter {
  const _HeaderWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final backPaint = Paint()
      ..color = const Color(0x99F7E5EA)
      ..style = PaintingStyle.fill;

    final backPath = Path()
      ..moveTo(0, h * (16 / 44))
      ..cubicTo(w * (110 / 480), h * (38 / 44), w * (220 / 480), h * (2 / 44), w * (340 / 480), h * (16 / 44))
      ..cubicTo(w * (400 / 480), h * (23 / 44), w * (448 / 480), h * (28 / 44), w, h * (18 / 44))
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(backPath, backPaint);

    final frontPaint = Paint()
      ..color = const Color(0xFFFFFDF9)
      ..style = PaintingStyle.fill;

    final frontPath = Path()
      ..moveTo(0, h * (24 / 44))
      ..cubicTo(w * (120 / 480), h * (42 / 44), w * (230 / 480), h * (10 / 44), w * (350 / 480), h * (24 / 44))
      ..cubicTo(w * (410 / 480), h * (31 / 44), w * (452 / 480), h * (34 / 44), w, h * (26 / 44))
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(frontPath, frontPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paintPrimary = Paint()..color = const Color(0x11A8224A);
    final paintAccent = Paint()..color = const Color(0x0CDC356E);
    const spacing = 24.0;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, paintPrimary);
        canvas.drawCircle(Offset(x + 12, y + 12), 1.1, paintAccent);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}