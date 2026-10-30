import 'package:flutter/material.dart';
import '../theme/sg_theme.dart';

class ScreenContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const ScreenContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: SG.ink)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: SG.muted)),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const SurfaceCard({super.key, required this.child, this.padding = const EdgeInsets.all(17)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SG.line),
      ),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;
  const SectionHeader(this.title, {super.key, this.action, this.onTap});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
          if (action != null)
            TextButton(onPressed: onTap, child: Text(action!)),
        ],
      );
}

// HALAMAN BERANDA - desain berdasarkan screenshot pengguna.
// Semua angka/nama berikut DEMO untuk preview, bukan data dari API.
