import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../services/auth_service.dart';
import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Future<Map<String, dynamic>?> _sessionFuture;

  bool _hasNavigated = false;
  bool _animationErrorScheduled = false;

  @override
  void initState() {
    super.initState();

    _sessionFuture = AuthService().restoreSession();
    _animationController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _goToAuth();
        }
      });
  }

  void _onAnimationLoaded(LottieComposition composition) {
    _animationController
      ..duration = composition.duration
      ..forward();
  }

  Widget _onAnimationError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    if (!_animationErrorScheduled) {
      _animationErrorScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToAuth());
    }

    return const ColoredBox(color: Color(0xFFFFF8FA));
  }

  void _goToAuth() {
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FA),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.center,
              child: Lottie.asset(
                'assets/animations/stuntguard_splash.json',
                controller: _animationController,
                width: MediaQuery.sizeOf(context).width * 0.88,
                height: MediaQuery.sizeOf(context).height * 0.5,
                fit: BoxFit.contain,
                onLoaded: _onAnimationLoaded,
                errorBuilder: _onAnimationError,
              ),
            ),

            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 28,
              left: 0,
              right: 0,
              child: const Column(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFC65375),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Menyiapkan StuntGuard...',
                    style: TextStyle(color: Color(0xFF754052), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
