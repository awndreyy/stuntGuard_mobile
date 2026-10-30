import 'package:flutter/material.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';

class PersonalDataScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const PersonalDataScreen({super.key, required this.user});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Data Pribadi')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: SurfaceCard(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Nama', style: TextStyle(color: SG.muted)),
          Text(user['name']?.toString() ?? '-'),
          const SizedBox(height: 16),
          const Text('Email', style: TextStyle(color: SG.muted)),
          Text(user['email']?.toString() ?? '-'),
        ],
      )),
    ),
  );
}
