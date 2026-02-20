import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';

/// Weekly meal planning grid: 7 days × 2 meal slots (Petit-déj/Déjeuner, Snack/Dîner).
class MealPlanningTable extends StatelessWidget {
  const MealPlanningTable({
    super.key,
    required this.isDark,
    required this.weekStart,
    required this.meals,
    required this.onAddTap,
  });

  final bool isDark;
  final DateTime weekStart;
  final Map<int, String?> meals;
  final void Function(int dayIndex, int slotIndex) onAddTap;

  static const List<String> _dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  static const List<String> _mealLabels = ['Petit-déj / Déjeuner', 'Snack / Dîner'];

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                'Jour',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: muted,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: List.generate(7, (i) {
                  return Expanded(
                    child: Text(
                      _dayNames[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: muted,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var slot = 0; slot < 2; slot++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _mealLabels[slot],
                    style: TextStyle(
                      fontSize: 10,
                      color: muted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: List.generate(7, (day) {
                    final key = day * 10 + slot;
                    final value = meals[key];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 1, right: 1),
                        child: MealCell(
                          isDark: isDark,
                          label: value,
                          onTap: () => onAddTap(day, slot),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          if (slot == 0) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Single cell in the meal planning grid (empty "+ Ajouter" or recipe label).
class MealCell extends StatelessWidget {
  const MealCell({
    super.key,
    required this.isDark,
    required this.label,
    required this.onTap,
  });

  final bool isDark;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppPalette.darkPastelSurface : AppPalette.cream;
    final border = isDark ? AppPalette.darkPastelBorder : AppPalette.mediumGray;
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;

    return AspectRatio(
      aspectRatio: 0.9,
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: border,
                width: 1,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: label == null || label!.isEmpty
                ? Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 20, color: onBg.withValues(alpha: 0.6)),
                          const SizedBox(height: 2),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(6),
                    child: Center(
                      child: Text(
                        label!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: onBg,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
