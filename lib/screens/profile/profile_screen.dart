import 'package:flutter/material.dart';

import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';
import '../profile/manage_children_screen.dart';
import 'personal_data_screen.dart';

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
  @override
  Widget build(BuildContext context) => ScreenContent(
    title: 'Profil',
    subtitle: 'Kelola akun dan data anak dalam satu tempat.',
    children: [
      SurfaceCard(
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: SG.pale,
              child: Icon(Icons.person, color: SG.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name']?.toString() ?? 'Orang Tua',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    user['email']?.toString() ?? '-',
                    style: const TextStyle(fontSize: 12, color: SG.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SurfaceCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _ProfileMenu(
              icon: Icons.child_care_outlined,
              label: 'Kelola Anak',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageChildrenScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 1, color: SG.line),
            _ProfileMenu(
              icon: Icons.manage_accounts_outlined,
              label: 'Data Pribadi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PersonalDataScreen(user: user),
                  ),
                );
              },
            ),
            const Divider(height: 1, color: SG.line),

            _ProfileMenu(
              icon: Icons.logout,
              label: 'Logout',
              isDanger: true,
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) => Dialog(
                    backgroundColor: Colors.white,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 26),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ikon Logout
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFB0003A),
                              size: 30,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // Judul
                          const Text(
                            'Keluar dari akun?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF242124),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Deskripsi
                          const Text(
                            'Anda akan keluar dari akun StunGuard Mobile. '
                            'Silakan masuk kembali untuk mengakses',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.7,
                              color: Color(0xFF6B6265),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Tombol aksi
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF514A4D),
                                    minimumSize: const Size(0, 56),
                                  ),
                                  child: const Text(
                                    'Batal',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                    onLogout();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB0003A),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    minimumSize: const Size(0, 56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Ya, Keluar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ],
  );
}

class _ProfileMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;
  const _ProfileMenu({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
    leading: Icon(icon, color: isDanger ? SG.primary : SG.muted),
    title: Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: isDanger ? SG.primary : SG.ink,
      ),
    ),
    trailing: const Icon(Icons.chevron_right, size: 20, color: SG.muted),
    onTap: onTap,
  );
}
