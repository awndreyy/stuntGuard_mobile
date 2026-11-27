import 'package:flutter/material.dart';

import '../../../models/balita.dart';

class CalcColors {
  static const primary = Color(0xFFC8103D);
  static const dark = Color(0xFF8B1038);
  static const yellow = Color(0xFFFFD84D);
  static const background = Color(0xFFFFF8F6);
  static const pale = Color(0xFFFFEBEF);
  static const ink = Color(0xFF35232B);
  static const muted = Color(0xFF75616A);
  static const line = Color(0xFFF0DEE3);
  static const green = Color(0xFF227257);
  static const greenPale = Color(0xFFEAF6EF);
}

class CalcCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const CalcCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CalcColors.line),
      ),
      child: child,
    );
  }
}

class CalcSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const CalcSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: CalcColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: CalcColors.muted,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class CalcChildSelectorCard extends StatelessWidget {
  final List<Balita> childrenList;
  final Balita? selectedChild;
  final String? selectedChildId;
  final bool enabled;
  final String genderText;
  final String ageText;
  final String Function(Balita child) ageBuilder;
  final ValueChanged<String> onSelected;

  const CalcChildSelectorCard({
    super.key,
    required this.childrenList,
    required this.selectedChild,
    required this.selectedChildId,
    required this.enabled,
    required this.genderText,
    required this.ageText,
    required this.ageBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CalcCard(
      padding: EdgeInsets.zero,
      child: PopupMenuButton<String>(
        tooltip: 'Pilih anak yang diukur',
        enabled: enabled,
        initialValue: selectedChildId,
        onSelected: onSelected,
        itemBuilder: (_) => [
          for (final child in childrenList)
            PopupMenuItem(
              value: child.id,
              child: Text('${child.nama} • ${ageBuilder(child)}'),
            ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: CalcColors.pale,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.child_care_rounded,
                    color: CalcColors.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ANAK YANG DIUKUR',
                      style: TextStyle(
                        color: CalcColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedChild?.nama ?? '-',
                      style: const TextStyle(
                        color: CalcColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _CalcBadge(
                          label: genderText,
                          icon: genderText == 'Perempuan'
                              ? Icons.girl_rounded
                              : Icons.boy_rounded,
                        ),
                        _CalcBadge(
                          label: ageText,
                          icon: Icons.cake_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.unfold_more_rounded,
                color: CalcColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalcPositionOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const CalcPositionOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? CalcColors.pale : CalcColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? CalcColors.primary : CalcColors.line,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? CalcColors.primary : CalcColors.muted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: selected ? CalcColors.dark : CalcColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CalcColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalcBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _CalcBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: CalcColors.pale,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: CalcColors.primary, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: CalcColors.dark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration calcInputDecoration({
  required String label,
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: const TextStyle(color: CalcColors.muted, fontSize: 13),
    hintStyle: TextStyle(
      color: CalcColors.muted.withValues(alpha: .65),
      fontSize: 13,
    ),
    prefixIcon: Icon(icon, color: CalcColors.primary, size: 20),
    filled: true,
    fillColor: CalcColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: CalcColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: CalcColors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: CalcColors.primary, width: 1.5),
    ),
  );
}