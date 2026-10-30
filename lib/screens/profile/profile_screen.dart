import 'package:flutter/material.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';
import '../profile/manage_children_screen.dart';
import 'personal_data_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final Future<void> Function() onLogout;
  final bool isLoggingOut;
  const ProfileScreen({super.key, required this.user, required this.onLogout, required this.isLoggingOut});
  @override
  Widget build(BuildContext context) => ScreenContent(
        title: 'Profil',
        subtitle: 'Kelola akun dan data anak dalam satu tempat.',
        children: [
          SurfaceCard(child: Row(children: [
            const CircleAvatar(radius: 24, backgroundColor: SG.pale, child: Icon(Icons.person, color: SG.primary)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user['name']?.toString() ?? 'Orang Tua', style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(user['email']?.toString() ?? '-', style: const TextStyle(fontSize: 12, color: SG.muted)),
            ])),
          ])),
          const SizedBox(height: 16),
          SurfaceCard(padding: EdgeInsets.zero, child: Column(children: [
            _ProfileMenu(icon: Icons.child_care_outlined, label: 'Kelola Anak', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageChildrenScreen()));
            }),
            const Divider(height: 1, color: SG.line),
            _ProfileMenu(icon: Icons.manage_accounts_outlined, label: 'Data Pribadi', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PersonalDataScreen(user: user)));
            }),
            const Divider(height: 1, color: SG.line),
            _ProfileMenu(icon: Icons.logout, label: 'Logout', isDanger: true, onTap: () {
              showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
                title: const Text('Keluar dari StunGuard?'),
                content: const Text('Sesi login akan diakhiri.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
                  TextButton(onPressed: () { Navigator.pop(dialogContext); onLogout(); }, child: const Text('Keluar')),
                ],
              ));
            }),
          ])),
        ],
      );
}

class _ProfileMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;
  const _ProfileMenu({required this.icon, required this.label, required this.onTap, this.isDanger = false});
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
    leading: Icon(icon, color: isDanger ? SG.primary : SG.muted),
    title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: isDanger ? SG.primary : SG.ink)),
    trailing: const Icon(Icons.chevron_right, size: 20, color: SG.muted),
    onTap: onTap,
  );
}
