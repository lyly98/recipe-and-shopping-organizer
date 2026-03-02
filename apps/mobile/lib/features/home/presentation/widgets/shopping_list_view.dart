import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';

/// Displays the generated shopping list with checkboxes and remaining count.
class ShoppingListView extends StatelessWidget {
  const ShoppingListView({
    super.key,
    required this.isDark,
    required this.numberOfPersons,
    required this.items,
    required this.onToggle,
  });

  final bool isDark;
  final int numberOfPersons;
  final List<({String label, bool checked})> items;
  final void Function(int index) onToggle;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppPalette.darkPastelSurface : AppPalette.white;
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final muted = isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;
    final remaining = items.where((e) => !e.checked).length;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Liste de courses',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: onBg,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pour $numberOfPersons personnes • $remaining articles restants',
                  style: TextStyle(fontSize: 13, color: muted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(items.length, (i) {
              final item = items[i];
              return CheckboxListTile(
                value: item.checked,
                onChanged: (_) => onToggle(i),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: onBg,
                    decoration: item.checked ? TextDecoration.lineThrough : null,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange,
              );
            }),
          ],
        ),
      ),
    );
  }
}
