import 'dart:async';

import 'package:flutter/material.dart';

import 'widgets/profile_header.dart';

class PersonalDataScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const PersonalDataScreen({super.key, required this.user});

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
                const ProfileHeader(
                  badge: 'Data Pribadi',
                  title: 'Informasi',
                  highlight: 'Akun Orang Tua',
                  description:
                      'Detail akun yang terdaftar pada layanan StuntGuard.',
                  showBackButton: true,
                  showBranding: false,
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
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: _outlineVariant,
                          ),
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
