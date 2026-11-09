import 'package:flutter/material.dart';

import 'screens/auth_gate.dart';
import 'theme/sg_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const AuthGate(),
    );
  }
}
