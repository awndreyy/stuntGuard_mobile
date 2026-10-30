
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'theme/sg_theme.dart';

void main() {
  runApp(const StunGuardApp());
}

class StunGuardApp extends StatelessWidget {
  const StunGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StuntGuard Jember',
      debugShowCheckedModeBanner: false,
      theme: SgTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
