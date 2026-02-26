import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';

/// Horizontal 7-day pill strip for the Planning tab.
/// Tapping a pill selects that day; the selected day is highlighted.
class MealPlanningTable extends StatelessWidget {
  const MealPlanningTable({
    super.key,
    required this.isDark,
    required this.weekStart,
    this.selectedDayIndex,
    this.onDayTap,
  });

  final bool isDark;
  final DateTime weekStart;

  /// Index of the currently selected day column (0 = Mon … 6 = Sun).
  final int? selectedDayIndex;

  /// Called when the user taps a day pill.
  final void Function(int dayIndex)? onDayTap;

  static const List<String> _dayNames = [
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim',
  ];

  /// Full meal slot names exposed for use in other widgets.
  static const List<String> mealLabelsFull = [
    'Petit-déjeuner',
    'Déjeuner',
    'Snack',
    'Dîner',
  ];

  /// Meal slot emojis matching [mealLabelsFull].
  static const List<String> mealEmojis = ['☀️', '🍽️', '🍎', '🌙'];

  @override
  Widget build(BuildContext context) {
    final muted =
        isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;
    final accent =
        isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange;
    final now = DateTime.now();

    return Row(
      children: List.generate(7, (i) {
        final dayDate = weekStart.add(Duration(days: i));
        final isSelected = i == selectedDayIndex;
        final isToday = dayDate.year == now.year &&
            dayDate.month == now.month &&
            dayDate.day == now.day;

        return Expanded(
          child: GestureDetector(
            onTap: () => onDayTap?.call(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? accent.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(
                        color: accent.withValues(alpha: 0.4),
                        width: 1,
                      )
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _dayNames[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? accent : muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isToday ? accent : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
