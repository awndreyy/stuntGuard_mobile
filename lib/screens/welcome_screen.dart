
import 'package:flutter/material.dart';
import 'package:stuntguardmobile/screens/login_screen.dart';
import 'package:stuntguardmobile/screens/register_screen.dart';

const Color primaryRed = Color(0xFFC8103D);
const Color darkRed = Color(0xFF8B1038);
const Color accentYellow = Color(0xFFFFD84D);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF922447),
              Color(0xFFB90F42),
              Color(0xFFD20C3F),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Ornamen lingkaran di belakang konten
              Positioned(
                top: 18,
                left: -45,
                right: -45,
                child: Container(
                  height: 390,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 1.2,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 50,
                left: 25,
                child: _decorationIcon(
                  Icons.medication_outlined,
                  -0.15,
                ),
              ),

              Positioned(
                top: 55,
                right: 25,
                child: _decorationIcon(
                  Icons.bar_chart_rounded,
                  0.15,
                ),
              ),

              Positioned(
                top: 175,
                left: 15,
                child: _decorationIcon(
                  Icons.favorite_border_rounded,
                  -0.1,
                ),
              ),

              Positioned(
                top: 190,
                right: 20,
                child: _decorationIcon(
                  Icons.favorite_rounded,
                  0.1,
                ),
              ),

              // Konten utama (scrollable agar tidak overflow di layar pendek)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            child: Column(
                              children: [
                    const SizedBox(height: 55),

                    const Spacer(flex: 3),

                    // Logo aplikasi
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF52E55),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.55,
                          ),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.12,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/logo-StuntGuard.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 42,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Nama aplikasi
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment:
                          WrapCrossAlignment.center,
                      spacing: 10,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                            ),
                            children: [
                              TextSpan(
                                text: 'Stun',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: 'Guard',
                                style: TextStyle(
                                  color: accentYellow,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.16,
                            ),
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white24,
                            ),
                          ),
                          child: const Text(
                            'JEMBER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.13,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'MONITORING GIZI & MPASI BALITA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Pantau tumbuh kembang & cegah '
                      'stunting anak Anda bersama ribuan '
                      'keluarga sehat di Jember.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        height: 1.7,
                        fontSize: 14,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Tombol Login
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                         Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: darkRed,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tombol Buat Akun
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const RegisterScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white
                              .withValues(alpha: 0.16),
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.white38,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Buat Akun Baru',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      '© 2026 StunGuard Jember. Hak Cipta Dilindungi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),

                    const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _decorationIcon(
    IconData icon,
    double rotation,
  ) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
