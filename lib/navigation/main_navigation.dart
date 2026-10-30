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
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (mounted) setState(() => isLoggingOut = false);
    }
  }

  void openCalculator() => setState(() => selected = 1);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onOpenCalculator: openCalculator),
      const CalculatorScreen(),
      const MpasiScreen(),
      const EducationScreen(),
      ProfileScreen(user: widget.user, onLogout: logout, isLoggingOut: isLoggingOut),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: selected, children: pages)),
      bottomNavigationBar: NavigationBar(
        height: 74,
        backgroundColor: Colors.white,
        indicatorColor: SG.pale,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: selected,
        onDestinationSelected: (index) => setState(() => selected = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: 'Kalkulator'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu_outlined), selectedIcon: Icon(Icons.restaurant_menu), label: 'MPASI'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Edukasi'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }



}
