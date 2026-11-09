import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../screens/login_screen.dart';
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
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
      HomeScreen(
        user: widget.user,
        onOpenCalculator: openCalculator,
        onOpenMpasi: openMpasi,
        onOpenEducation: () => _selectTab(3),
        onOpenProfile: () => _selectTab(4),
      ),
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
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: selected, children: pages),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / 5;
          final diameter = (slotWidth - 4).clamp(48.0, 68.0).toDouble();
          final labelHeight = MediaQuery.textScalerOf(context).scale(11) * 1.4;
          final barHeight = 64.0 + labelHeight;
          final totalHeight = 24.0 + barHeight;
          return SizedBox(
            height: totalHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 24,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(48),
                      boxShadow: [
                        BoxShadow(
                          color: _navRose.withValues(alpha: .09),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    Expanded(
                      child: Column(
                        children: [
                          Semantics(
                            button: true,
                            selected: selected == 2,
                            label: 'Kalkulator Gizi',
                            excludeSemantics: true,
                            child: Tooltip(
                              message: 'Kalkulator Gizi',
                              child: Container(
                                width: diameter,
                                height: diameter,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _navRose.withValues(alpha: .25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: _navRose,
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () => _selectTab(2),
                                    customBorder: const CircleBorder(),
                                    child: const Center(
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
                          const SizedBox(height: 8),
                          Flexible(
                            child: Tooltip(
                              message: 'Kalkulator',
                              child: Text(
                                'Kalkulator',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                  color: selected == 2 ? _navRose : _navMuted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
              ],
            ),
          );
        },
      ),
    ),
  );
}

const _navRose = Color(0xFFC8103D);
const _navMuted = Color(0xFF7B7175);

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
    final color = active ? _navRose : _navMuted;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Semantics(
          button: true,
          selected: active,
          label: label,
          excludeSemantics: true,
          child: Tooltip(
            message: label,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(32),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(active ? activeIcon : icon, size: 26, color: color),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                          color: color,
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
    );
  }
}
