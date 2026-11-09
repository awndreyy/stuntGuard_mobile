import 'package:flutter/material.dart';

import '../navigation/main_navigation.dart';
import '../services/auth_service.dart';
import '../theme/sg_theme.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, this.sessionFuture});

  final Future<Map<String, dynamic>?>? sessionFuture;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();

  late Future<Map<String, dynamic>?> _session;

  @override
  void initState() {
    super.initState();
    _session = widget.sessionFuture ?? _authService.restoreSession();
  }

  void _retry() {
    setState(() {
      _session = _authService.restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _session,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: SG.background,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo-StuntGuard.png',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(color: SG.primary),
                    const SizedBox(height: 16),
                    const Text(
                      'Memeriksa sesi login...',
                      style: TextStyle(color: SG.muted),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: SG.background,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 48,
                        color: SG.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum dapat terhubung',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: SG.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Periksa koneksi internet dan pastikan '
                        'server Laravel berjalan, lalu coba lagi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: SG.muted, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _retry,
                        style: FilledButton.styleFrom(
                          backgroundColor: SG.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(160, 48),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return MainNavigation(user: user);
      },
    );
  }
}
