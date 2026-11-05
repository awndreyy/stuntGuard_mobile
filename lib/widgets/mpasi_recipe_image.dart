import 'package:flutter/material.dart';

import '../theme/sg_theme.dart';

class MpasiRecipeImage extends StatelessWidget {
  final String? url;
  final double size;

  const MpasiRecipeImage({super.key, required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    final placeholder = Center(
      child: Icon(Icons.rice_bowl_rounded, color: SG.primary, size: size),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return Image.network(
      url!,
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, error, stackTrace) => placeholder,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
    );
  }
}
