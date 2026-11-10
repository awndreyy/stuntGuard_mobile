import 'package:flutter/material.dart';
import '../theme/sg_theme.dart';
import '../services/auth_service.dart';

const Color primaryCrimson = SG.primary;
const Color darkCrimson = SG.primaryDark;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final AuthService _authService = AuthService();

    bool _isLoading = false;

    Future<void> _register() async {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (!_setuju) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan centang persetujuan data terlebih dahulu.'),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.register(
          nama: _namaController.text.trim(),
          nik: _nikController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }


  bool _obscurePassword = true;
  bool _setuju = false;
  int _nikLength = 0;

  @override
  void initState() {
    super.initState();
    _nikController.addListener(() {
      setState(() {
        _nikLength = _nikController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SG.primaryDark,
      body: Stack(
        children: [
          // Background Gradient and Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SG.primaryDark,
                    SG.primary,
                    SG.primaryDark,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  // Concentric background circles
                  Center(
                    child: Container(
                      width: 330,
                      height: 330,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.07),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // Floating icons
                  // Top Left: Water drop
                  Positioned(
                    top: 36,
                    left: 24,
                    child: _buildFloatingIcon(Icons.water_drop_outlined),
                  ),

                  // Top Right: Smile
                  Positioned(
                    top: 40,
                    right: 24,
                    child: _buildFloatingIcon(
                      Icons.sentiment_satisfied_alt_outlined,
                    ),
                  ),

                  // Bottom Left: Card/Medical Icon
                  Positioned(
                    top: 155,
                    left: 32,
                    child: _buildFloatingIcon(Icons.badge_outlined),
                  ),

                  // Bottom Right: Heart
                  Positioned(
                    top: 155,
                    right: 32,
                    child: _buildFloatingIcon(Icons.favorite_border_rounded),
                  ),

                  // Center Logo & Title
                  Positioned(
                    top: 36,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo box
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/logo-StuntGuard.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    color: primaryCrimson,
                                    size: 34,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Title with JEMBER Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'StunGuard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'JEMBER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Subtitle
                        Text(
                          'Monitoring Gizi & MPASI Balita',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // White Form Card
          Positioned.fill(
            top: 215,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag indicator
                        Center(
                          child: Container(
                            width: 38,
                            height: 4,
                            decoration: BoxDecoration(
                              color: SG.line,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Title
                        const Center(
                          child: Text(
                            'Registrasi Akun',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: SG.ink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        const Center(
                          child: Text(
                            'Lengkapi data diri Anda untuk memulai perjalanan\nsehat si kecil',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: SG.muted,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // 1. Nama Lengkap
                        _buildRequiredLabel('Nama Lengkap'),
                        const SizedBox(height: 7),
                        TextFormField(
                          controller: _namaController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _buildInputDecoration(
                            hint: 'Masukkan nama lengkap sesuai KTP',
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama lengkap wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // 2. NIK with badge counter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildRequiredLabel(
                              'Nomor Induk Kependudukan (NIK)',
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: SG.soft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$_nikLength/16 Digit',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: SG.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        TextFormField(
                          controller: _nikController,
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          decoration: _buildInputDecoration(
                            hint: '3509xxxxxxxxxxxx (16 Digit)',
                            prefixIcon: Icons.badge_outlined,
                          ).copyWith(counterText: ''),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'NIK wajib diisi';
                            }
                            if (!RegExp(r'^[0-9]{16}$').hasMatch(value)) {
                              return 'NIK harus terdiri dari 16 digit angka';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Harus berupa 16 digit angka sesuai KTP',
                          style: TextStyle(
                            fontSize: 11,
                            color: SG.muted,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. Email
                        _buildRequiredLabel('Email Address'),
                        const SizedBox(height: 7),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _buildInputDecoration(
                            hint: 'contoh@gmail.com',
                            prefixIcon: Icons.email_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email wajib diisi';
                            }
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(value.trim())) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // 4. Password
                        _buildRequiredLabel('Password'),
                        const SizedBox(height: 7),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration:
                              _buildInputDecoration(
                                hint: 'Minimal 6 karakter',
                                prefixIcon: Icons.lock_outline_rounded,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: SG.muted,
                                    size: 20,
                                  ),
                                ),
                              ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password wajib diisi';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Gunakan minimal 6 karakter',
                          style: TextStyle(
                            fontSize: 11,
                            color: SG.muted,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 5. Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _setuju,
                                activeColor: SG.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: const BorderSide(
                                  color: SG.line,
                                  width: 1.5,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _setuju = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1.45,
                                    color: SG.muted,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Saya menyetujui bahwa data yang saya masukkan adalah benar untuk keperluan sistem monitoring ',
                                    ),
                                    TextSpan(
                                      text: 'StunGuard.',
                                      style: TextStyle(
                                        color: SG.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 6. Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SG.primary,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: SG.primary
                                  .withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Daftar Sekarang',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 19),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Kembali ke halaman Login tanpa menambah route baru.
                        Center(
                          child: TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded, size: 20),
                            label: const Text('Kembali ke Login'),
                            style: TextButton.styleFrom(
                              foregroundColor: SG.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),

                        // 8. Footer Copyright
                        const Center(
                          child: Text(
                            '© 2026 StunGuard Jember. Kelompok 2',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: SG.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 18),
      ),
    );
  }

  Widget _buildRequiredLabel(String text) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: SG.ink,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: SG.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: SG.muted, fontSize: 12),
      prefixIcon: Icon(prefixIcon, size: 19, color: SG.muted),
      filled: true,
      fillColor: SG.soft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: SG.primary, width: 1.5),
      ),
    );
  }
}
