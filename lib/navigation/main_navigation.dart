import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../screens/welcome_screen.dart';
import '../theme/sg_theme.dart';
import '../screens/home/home_screen.dart';
import '../screens/calculator/calculator_screen.dart';
import '../screens/mpasi/mpasi_screen.dart';
import '../screens/education/education_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final Map<String, dynamic> user;

  const MainNavigation({super.key, required this.user});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selected = 0;
  bool isLoggingOut = false;

  Future<void> logout() async {
    if (isLoggingOut) return;

    setState(() => isLoggingOut = true);

    try {
      await AuthService().logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => isLoggingOut = false);
      }
    }
  }

  void _selectTab(int index) {
    if (selected == index) return;

    setState(() {
      selected = index;
    });
  }

  void openCalculator() => _selectTab(2);
  void openMpasi() => _selectTab(1);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(user: widget.user, onOpenCalculator: openCalculator, onOpenMpasi: openMpasi),
      const MpasiScreen(),
      const CalculatorScreen(),
      const EducationScreen(),
      ProfileScreen(
        user: widget.user,
        onLogout: logout,
        isLoggingOut: isLoggingOut,
      ),
    ];

    return Scaffold(
      backgroundColor: SG.background,
      body: SafeArea(
        child: IndexedStack(index: selected, children: pages),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          height: 112,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              children: [
                const SizedBox(
                  width: double.infinity,
                  height: 22,
                  child: ColoredBox(color: Color(0xFFF5F6F8)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 2, 0, 7),
                    child: Row(
                      children: [
                        _BottomNavItem(
                          label: 'Beranda',
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home_rounded,
                          active: selected == 0,
                          onTap: () => _selectTab(0),
                        ),

                        _BottomNavItem(
                          label: 'MPASI',
                          icon: Icons.ramen_dining_outlined,
                          activeIcon: Icons.ramen_dining_rounded,
                          active: selected == 1,
                          onTap: () => _selectTab(1),
                        ),

                        _buildCenterCalculatorButton(),

                        _BottomNavItem(
                          label: 'Edukasi',
                          icon: Icons.menu_book_outlined,
                          activeIcon: Icons.menu_book_rounded,
                          active: selected == 3,
                          onTap: () => _selectTab(3),
                        ),

                        _BottomNavItem(
                          label: 'Profil',
                          icon: Icons.person_outline_rounded,
                          activeIcon: Icons.person_rounded,
                          active: selected == 4,
                          onTap: () => _selectTab(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterCalculatorButton() {
    return Expanded(
      child: Center(
        child: Semantics(
          button: true,
          selected: selected == 2,
          label: 'Kalkulator Gizi',
          child: Tooltip(
            message: 'Kalkulator Gizi',
            child: Material(
              color: SG.primary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => _selectTab(2),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 60,
                  height: 60,
                  child: Icon(
                    Icons.calculate_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = active ? SG.primary : const Color(0xFF454951);

    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 76,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(active ? activeIcon : icon, size: 25, color: color),

                  const SizedBox(height: 6),

                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
