import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';

/// Card to generate the shopping list: title, persons stepper,
/// date-range steppers (today → any future date), and CTA button.
class ShoppingGeneratorCard extends StatelessWidget {
  const ShoppingGeneratorCard({
    super.key,
    required this.isDark,
    required this.numberOfPersons,
    required this.onPersonsChanged,
    required this.shopStart,
    required this.shopEnd,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.isGenerating,
    required this.onGenerate,
  });

  final bool isDark;
  final int numberOfPersons;
  final void Function(int) onPersonsChanged;

  /// Start date — minimum is today.
  final DateTime shopStart;

  /// End date — no upper limit.
  final DateTime shopEnd;

  final void Function(DateTime) onStartChanged;
  final void Function(DateTime) onEndChanged;
  final bool isGenerating;
  final VoidCallback onGenerate;

  static const _dayShort = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  static const _monthShort = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  String _label(DateTime d) =>
      '${_dayShort[d.weekday - 1]} ${d.day} ${_monthShort[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppPalette.darkPastelSurface : AppPalette.white;
    final onBg =
        isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final muted =
        isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;
    final orange =
        isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange;

    final today = _today();

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
            // ── Header ────────────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.shopping_cart_outlined, size: 28, color: orange),
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
                        'Basée sur la période sélectionnée',
                        style: TextStyle(fontSize: 13, color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Persons stepper ───────────────────────────────────────────
            _RowStepper(
              label: 'Personnes',
              value: '$numberOfPersons pers.',
              onDecrement: numberOfPersons > 1
                  ? () => onPersonsChanged(numberOfPersons - 1)
                  : null,
              onIncrement: () => onPersonsChanged(numberOfPersons + 1),
              accentColor: orange,
              onBg: onBg,
            ),
            const SizedBox(height: 14),

            // ── Start-date stepper ────────────────────────────────────────
            _RowStepper(
              label: 'Du',
              value: _label(shopStart),
              // Can't go before today
              onDecrement: shopStart.isAfter(today)
                  ? () =>
                      onStartChanged(shopStart.subtract(const Duration(days: 1)))
                  : null,
              // Can't push start past end
              onIncrement: shopStart.isBefore(shopEnd)
                  ? () => onStartChanged(shopStart.add(const Duration(days: 1)))
                  : null,
              accentColor: orange,
              onBg: onBg,
            ),
            const SizedBox(height: 10),

            // ── End-date stepper ──────────────────────────────────────────
            _RowStepper(
              label: 'Au',
              value: _label(shopEnd),
              // Can't go before start
              onDecrement: shopEnd.isAfter(shopStart)
                  ? () => onEndChanged(shopEnd.subtract(const Duration(days: 1)))
                  : null,
              // No upper limit
              onIncrement: () =>
                  onEndChanged(shopEnd.add(const Duration(days: 1))),
              accentColor: orange,
              onBg: onBg,
            ),
            const SizedBox(height: 20),

            // ── Generate button ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isGenerating ? null : onGenerate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: AppPalette.white,
                  disabledBackgroundColor: orange.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppPalette.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart, size: 20),
                          SizedBox(width: 8),
                          Text('Générer la liste'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable label + < value > stepper row
// ---------------------------------------------------------------------------

class _RowStepper extends StatelessWidget {
  const _RowStepper({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.accentColor,
    required this.onBg,
  });

  final String label;
  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final Color accentColor;
  final Color onBg;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: onBg),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: onDecrement,
                color: accentColor,
                style: IconButton.styleFrom(
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: onBg,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onIncrement,
                color: accentColor,
                style: IconButton.styleFrom(
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
