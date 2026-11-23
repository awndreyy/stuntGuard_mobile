import 'package:flutter/material.dart';

import '../profile/manage_children_screen.dart';
import 'personal_data_screen.dart';
import 'widgets/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final Future<void> Function() onLogout;
  final bool isLoggingOut;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.isLoggingOut,
  });

  // Palet warna sesuai desain
  static const Color _primary = Color(0xFFA8224A);
  static const Color _primaryContainer = Color(0xFFF7E5EA);
  static const Color _onPrimaryContainer = Color(0xFF701230);
  static const Color _surface = Color(0xFFFFF7F4);
  static const Color _surfaceContainer = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF1F1A1C);
  static const Color _onSurfaceVariant = Color(0xFF6B5E62);
  static const Color _outlineVariant = Color(0xFFE6DFDC);

  @override
  Widget build(BuildContext context) {
    final fullName = user['name']?.toString().trim().isNotEmpty == true
        ? user['name'].toString().trim()
        : 'Orang Tua';
    final firstName = fullName.split(RegExp(r'\s+')).first;
    final email = user['email']?.toString() ?? '-';

    return ColoredBox(
      color: _surface,
      child: Stack(
        children: [
          // Pola titik-titik halus pada latar (surface-pattern)
          const Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter()),
          ),

          // Konten utama yang dapat di-scroll
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(
                  title: 'Profil Akun',
                  highlight: '$firstName & Keluarga',
                  description: 'Kelola akun dan data anak dalam satu tempat.',
                ),

                // Main Area dengan gradasi pink lembut di bagian atas (main-pink-fade)
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.22, 0.5],
                      colors: [
                        Color(0xB8F7E5EA),
                        Color(0x38F7E5EA),
                        Color(0x00FFFDF9),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
                  child: Column(
                    children: [
                      // Modernized Parent Identity Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _surfaceContainer,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: _primaryContainer,
                                shape: BoxShape.circle,
                                border: Border.all(color: _surface, width: 3),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.person,
                                color: _primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: _onSurface,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: _onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Grouped Account & Child Management Menu
                      Container(
                        decoration: BoxDecoration(
                          color: _surfaceContainer,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _outlineVariant),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            _ModernProfileMenu(
                              icon: Icons.child_care_outlined,
                              iconBg: const Color(0xB3F7E5EA),
                              iconColor: _onPrimaryContainer,
                              label: 'Kelola Anak',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ManageChildrenScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: _outlineVariant,
                            ),
                            _ModernProfileMenu(
                              icon: Icons.manage_accounts_outlined,
                              iconBg: _surface,
                              iconColor: _onSurfaceVariant,
                              iconBorderColor: _outlineVariant,
                              label: 'Data Pribadi',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PersonalDataScreen(user: user),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Isolated Session Action (Logout)
                      Container(
                        decoration: BoxDecoration(
                          color: _surfaceContainer,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _outlineVariant),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _ModernProfileMenu(
                          icon: Icons.logout,
                          iconBg: const Color(0x99F7E5EA),
                          iconColor: _primary,
                          label: isLoggingOut ? 'Sedang Keluar...' : 'Logout',
                          labelColor: _primary,
                          chevronColor: const Color(0xB3A8224A),
                          isLoading: isLoggingOut,
                          onTap: isLoggingOut
                              ? () {}
                              : () {
                                  showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text(
                                        'Keluar dari StuntGuard?',
                                      ),
                                      content: const Text(
                                        'Apakah Anda yakin ingin keluar dari akun? '
                                        'Sesi login Anda akan diakhiri.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            false,
                                          ),
                                          child: const Text('Batal'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            true,
                                          ),
                                          child: const Text('Keluar'),
                                        ),
                                      ],
                                    ),
                                  ).then((confirmed) {
                                    if (confirmed == true) {
                                      onLogout();
                                    }
                                  });
                                },
                        ),
                      ),
                    ],
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

class _ModernProfileMenu extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color? iconBorderColor;
  final String label;
  final Color labelColor;
  final Color chevronColor;
  final bool isLoading;
  final VoidCallback onTap;

  const _ModernProfileMenu({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.iconBorderColor,
    required this.label,
    this.labelColor = const Color(0xFF1F1A1C),
    this.chevronColor = const Color(0xFF6B5E62),
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0x40F7E5EA),
        highlightColor: const Color(0x26F7E5EA),
        child: Padding(
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
                child: isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: iconColor,
                        ),
                      )
                    : Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: chevronColor),
            ],
          ),
        ),
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
