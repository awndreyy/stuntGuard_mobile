import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/sg_theme.dart';
import 'auth_gate.dart';

/// Splash animasi yang hanya tampil ketika aplikasi pertama kali dibuka.
/// Pemeriksaan sesi dimulai paralel agar transisi lebih cepat.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Future<Map<String, dynamic>?> _sessionFuture;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Jangan menunggu animasi selesai untuk mulai memeriksa token.
    _sessionFuture = AuthService().restoreSession();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 1, curve: Curves.easeIn),
    );
    _controller.forward();

    _timer = Timer(const Duration(milliseconds: 2300), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AuthGate(sessionFuture: _sessionFuture),
          transitionDuration: const Duration(milliseconds: 450),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SG.primaryDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SG.primaryDark, SG.primary, Color(0xFFC65375)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(top: -120, right: -105, child: _halo(310)),
              Positioned(bottom: -180, left: -120, child: _halo(360)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: FadeTransition(
                      opacity: _fade,
                      child: Container(
                        width: 112,
                        height: 112,
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.13),
                              blurRadius: 26,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo-StuntGuard.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  FadeTransition(
                    opacity: _fade,
                    child: const Column(
                      children: [
                        Text(
                          'StunGuard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'J E M B E R',
                          style: TextStyle(
                            color: Color(0xFFFDE5EC),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Pantau Tumbuh Kembang Si Kecil',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 42,
                child: FadeTransition(
                  opacity: _fade,
                  child: const Column(
                    children: [
                      SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.3,
                        ),
                      ),
                      SizedBox(height: 13),
                      Text(
                        'Menyiapkan StunGuard...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFDE5EC),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _halo(double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 2,
        ),
      ),
    );
  }
}
