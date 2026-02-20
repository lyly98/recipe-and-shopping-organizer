import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';

/// Card to generate the shopping list: title, subtitle, number of persons stepper, CTA button.
class ShoppingGeneratorCard extends StatelessWidget {
  const ShoppingGeneratorCard({
    super.key,
    required this.isDark,
    required this.numberOfPersons,
    required this.onPersonsChanged,
    required this.onGenerate,
  });

  final bool isDark;
  final int numberOfPersons;
  final void Function(int) onPersonsChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppPalette.darkPastelSurface : AppPalette.white;
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final muted = isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;
    final orange = isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange;

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
            Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 28,
                  color: orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Générer la liste de courses',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: onBg,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Créer votre liste basée sur le menu de la semaine',
                        style: TextStyle(
                          fontSize: 13,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Nombre de personnes',
                    style: TextStyle(
                      fontSize: 14,
                      color: onBg,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: numberOfPersons > 1
                          ? () => onPersonsChanged(numberOfPersons - 1)
                          : null,
                      color: orange,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '$numberOfPersons pers.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: onBg,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => onPersonsChanged(numberOfPersons + 1),
                      color: orange,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onGenerate,
                icon: const Icon(Icons.shopping_cart, size: 20),
                label: const Text('Générer la liste'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: AppPalette.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
