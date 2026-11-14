import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../navigation/main_navigation.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();

  late final AnimationController _controller;
  Timer? _animationFallback;

  Map<String, dynamic>? _user;
  String? _sessionError;

  bool _animationStarted = false;
  bool _animationFinished = false;
  bool _sessionFinished = false;
  bool _checkingSession = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishAnimation();
      }
    });

    // Pengaman jika animasi gagal dimuat atau diputar.
    _animationFallback = Timer(const Duration(seconds: 6), _finishAnimation);

    // Pemeriksaan sesi langsung berjalan selama splash.
    _checkSession();
  }

  Future<void> _checkSession() async {
    if (_checkingSession || _hasNavigated) return;

    setState(() {
      _checkingSession = true;
      _sessionFinished = false;
      _sessionError = null;
    });

    try {
      final user = await _authService.restoreSession();

      if (!mounted || _hasNavigated) return;

      setState(() {
        _user = user;
        _sessionFinished = true;
        _checkingSession = false;
      });

      _navigateIfReady();
    } catch (_) {
      if (!mounted || _hasNavigated) return;

      setState(() {
        _checkingSession = false;
        _sessionError =
            'Belum dapat terhubung ke server. '
            'Periksa koneksi dan pastikan server Laravel berjalan.';
      });
    }
  }

  void _finishAnimation() {
    if (!mounted || _animationFinished) return;

    _animationFallback?.cancel();

    setState(() {
      _animationFinished = true;
    });

    _navigateIfReady();
  }

  void _navigateIfReady() {
    if (!mounted || _hasNavigated || !_animationFinished || !_sessionFinished) {
      return;
    }

    _hasNavigated = true;
    _animationFallback?.cancel();

    final user = _user;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) =>
            user == null ? const LoginScreen() : MainNavigation(user: user),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _animationFallback?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF852641),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Lottie.asset(
            'assets/animations/stuntguard_splash.json',
            controller: _controller,
            repeat: false,
            fit: BoxFit.cover,
            onLoaded: (composition) {
              if (!mounted ||
                  _hasNavigated ||
                  _animationStarted ||
                  _animationFinished) {
                return;
              }

              _animationStarted = true;

              _controller
                ..duration = composition.duration
                ..forward(from: 0);
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Image.asset(
                  'assets/images/logo-StuntGuard.png',
                  width: 120,
                  height: 120,
                ),
              );
            },
          ),

          // Jika server lambat, tetap tampil di splash.
          if (_animationFinished && _checkingSession)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 48,
              child: SafeArea(
                top: false,
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),

          // Kesalahan koneksi ditampilkan tanpa meninggalkan splash.
          if (_sessionError != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: SafeArea(
                top: false,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _sessionError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF852641)),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _checkSession,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
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
  }
}
