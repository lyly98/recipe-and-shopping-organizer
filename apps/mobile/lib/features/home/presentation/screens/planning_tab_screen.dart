import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/meal_plan_entry_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/recipe_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/recipe_picker_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/meal_planning_table.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/shopping_generator_card.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/shopping_list_view.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/providers/home_providers.dart';

/// "Planning" tab: day strip, per-day meal slot cards,
/// shopping list generator and list.
class PlanningTabScreen extends ConsumerStatefulWidget {
  const PlanningTabScreen({super.key, required this.isDark});

  final bool isDark;

  @override
  ConsumerState<PlanningTabScreen> createState() => _PlanningTabScreenState();
}

class _PlanningTabScreenState extends ConsumerState<PlanningTabScreen> {
  int _weekOffset = 0;
  int _numberOfPersons = 4;

  /// Recipes per date+slot.
  /// Key = "yyyy-MM-dd_$slotIndex".
  final Map<String, List<({String entryId, RecipeEntity recipe})>>
      _mealRecipes = {};

  List<({String label, bool checked})> _shoppingItems = [];
  bool _listGenerated = false;
  bool _isGenerating = false;
  bool _isLoadingPlan = false;

  /// 0 = Lundi … 6 = Dimanche. Defaults to today's weekday.
  int _selectedDayIndex = DateTime.now().weekday - 1;

  /// Shopping range. Defaults to today → today + 6 days.
  DateTime _shopStart = _today();
  DateTime _shopEnd = _today().add(const Duration(days: 6));

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static const List<String> _dayNamesFull = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  static const List<String> _monthNames = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMealPlan());
  }

  // ---------------------------------------------------------------------------
  // Date helpers
  // ---------------------------------------------------------------------------

  DateTime get _weekStart {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final base = DateTime(monday.year, monday.month, monday.day);
    return base.add(Duration(days: _weekOffset * 7));
  }

  DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));

  DateTime get _selectedDay =>
      _weekStart.add(Duration(days: _selectedDayIndex));

  String get _weekRangeText {
    final start = _weekStart;
    final end = _weekEnd;
    return '${_dayNamesFull[start.weekday - 1]} ${start.day}'
        ' – ${_dayNamesFull[end.weekday - 1]} ${end.day} ${_monthNames[end.month - 1]}';
  }

  // ---------------------------------------------------------------------------
  // Meal data helpers
  // ---------------------------------------------------------------------------

  String _dateSlotKey(DateTime date, int slot) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}'
      '_$slot';

  List<RecipeEntity> _recipesFor(DateTime date, int slot) =>
      (_mealRecipes[_dateSlotKey(date, slot)] ?? [])
          .map((e) => e.recipe)
          .toList();

  // ---------------------------------------------------------------------------
  // API-backed persistence
  // ---------------------------------------------------------------------------

  Future<void> _loadMealPlan() async {
    setState(() => _isLoadingPlan = true);

    final repo = ref.read(mealPlanRepositoryProvider);
    final start = _weekStart;
    final end = _weekEnd;

    final result = await repo.getMealPlan(start: start, end: end);
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isLoadingPlan = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement : ${failure.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (entries) {
        // Remove all keys belonging to this week's range then repopulate.
        final keysToRemove = _mealRecipes.keys.where((k) {
          final datePart = k.substring(0, 10);
          final d = DateTime.tryParse(datePart);
          if (d == null) return false;
          return !d.isBefore(start) && !d.isAfter(end);
        }).toList();
        for (final k in keysToRemove) {
          _mealRecipes.remove(k);
        }

        for (final entry in entries) {
          _addEntryToLocalMap(entry);
        }

        setState(() => _isLoadingPlan = false);
      },
    );
  }

  void _addEntryToLocalMap(MealPlanEntryEntity entry) {
    final key = _dateSlotKey(entry.planDate, entry.slotIndex);
    _mealRecipes[key] = [
      ...(_mealRecipes[key] ?? []),
      (entryId: entry.id, recipe: entry.recipe),
    ];
  }

  Future<void> _addRecipe(DateTime date, int slot, RecipeEntity recipe) async {
    final repo = ref.read(mealPlanRepositoryProvider);
    final result = await repo.addEntry(
      date: date,
      slotIndex: slot,
      recipeId: recipe.id,
    );
    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${failure.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (entry) {
        setState(() => _addEntryToLocalMap(entry));
      },
    );
  }

  Future<void> _removeRecipe(
    DateTime date,
    int slot,
    int recipeIndex,
  ) async {
    final key = _dateSlotKey(date, slot);
    final entries = _mealRecipes[key];
    if (entries == null || recipeIndex >= entries.length) return;

    final entryId = entries[recipeIndex].entryId;
    final repo = ref.read(mealPlanRepositoryProvider);
    final result = await repo.removeEntry(entryId);
    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${failure.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (_) {
        setState(() {
          final list = List<({String entryId, RecipeEntity recipe})>.of(
              _mealRecipes[key] ?? []);
          list.removeAt(recipeIndex);
          if (list.isEmpty) {
            _mealRecipes.remove(key);
          } else {
            _mealRecipes[key] = list;
          }
        });
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  Future<void> _openPicker(DateTime date, int slot) async {
    final mealLabel = MealPlanningTable.mealLabelsFull[slot];
    final chosen = await Navigator.of(context).push<RecipeEntity>(
      MaterialPageRoute<RecipeEntity>(
        builder: (_) => RecipePickerScreen(mealLabel: mealLabel),
      ),
    );
    if (chosen != null && mounted) {
      await _addRecipe(date, slot, chosen);
    }
  }

  // ---------------------------------------------------------------------------
  // Shopping list generation
  // ---------------------------------------------------------------------------

  Future<void> _generateList() async {
    setState(() => _isGenerating = true);

    // Collect all recipes for each date in the range.
    final planned = <RecipeEntity>[];
    var date = _shopStart;
    while (!date.isAfter(_shopEnd)) {
      for (var slot = 0; slot < 4; slot++) {
        planned.addAll(_recipesFor(date, slot));
      }
      date = date.add(const Duration(days: 1));
    }

    // For recipes without ingredient data (light list version), fetch the full
    // recipe from the API.
    final repo = ref.read(recipeRepositoryProvider);
    final full = <RecipeEntity>[];
    for (final recipe in planned) {
      if (recipe.ingredients.isEmpty) {
        final result = await repo.getRecipe(recipe.id);
        result.fold(
          (_) => full.add(recipe),
          (r) => full.add(r),
        );
      } else {
        full.add(recipe);
      }
    }

    if (!mounted) return;
    setState(() {
      _shoppingItems = _aggregateIngredients(full, _numberOfPersons);
      _listGenerated = true;
      _isGenerating = false;
    });
  }

  /// Aggregates and scales ingredients from [recipes] for [persons] people.
  List<({String label, bool checked})> _aggregateIngredients(
    List<RecipeEntity> recipes,
    int persons,
  ) {
    final Map<String, ({double qty, String? unit, String name})> numeric = {};
    final List<String> textOnly = [];

    for (final recipe in recipes) {
      final servings = recipe.servings > 0 ? recipe.servings : 1;
      final scale = persons / servings;

      for (final ing in recipe.ingredients) {
        final parsed = _parseQuantity(ing.quantity);
        final key =
            '${ing.name.trim().toLowerCase()}|${(ing.unit ?? '').toLowerCase()}';

        if (parsed != null) {
          final existing = numeric[key];
          numeric[key] = (
            qty: (existing?.qty ?? 0) + parsed * scale,
            unit: ing.unit,
            name: ing.name.trim(),
          );
        } else {
          final unitPart =
              ing.unit != null && ing.unit!.isNotEmpty ? ' ${ing.unit}' : '';
          textOnly.add('${ing.quantity}$unitPart ${ing.name}');
        }
      }
    }

    final items = <({String label, bool checked})>[];
    for (final entry in numeric.values) {
      final formatted = _formatQty(entry.qty);
      final unitPart =
          entry.unit != null && entry.unit!.isNotEmpty ? ' ${entry.unit}' : '';
      items.add((label: '$formatted$unitPart de ${entry.name}', checked: false));
    }
    for (final text in textOnly) {
      items.add((label: text, checked: false));
    }

    return items;
  }

  double? _parseQuantity(String qty) {
    final trimmed = qty.trim();
    final direct = double.tryParse(trimmed);
    if (direct != null) return direct;

    final parts = trimmed.split('/');
    if (parts.length == 2) {
      final num = double.tryParse(parts[0].trim());
      final den = double.tryParse(parts[1].trim());
      if (num != null && den != null && den != 0) return num / den;
    }
    return null;
  }

  String _formatQty(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(1);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final onBg =
        isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final muted =
        isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;

    final selected = _selectedDay;
    final daySlotRecipes = List.generate(
      4,
      (slot) => _recipesFor(selected, slot),
    );

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planning',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: onBg,
                      ),
                ),
                const SizedBox(height: 16),

                // ── Week navigator ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() => _weekOffset -= 1);
                        _loadMealPlan();
                      },
                      color: onBg,
                    ),
                    Expanded(
                      child: Text(
                        _weekRangeText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: onBg,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() => _weekOffset += 1);
                        _loadMealPlan();
                      },
                      color: onBg,
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // ── Day strip ────────────────────────────────────────────
                MealPlanningTable(
                  isDark: isDark,
                  weekStart: _weekStart,
                  selectedDayIndex: _selectedDayIndex,
                  onDayTap: (i) => setState(() => _selectedDayIndex = i),
                ),
                const SizedBox(height: 20),

                // ── Meal slot cards (or loading indicator) ───────────────
                if (_isLoadingPlan)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  for (var slot = 0; slot < 4; slot++) ...[
                    _MealSlotCard(
                      isDark: isDark,
                      slotIndex: slot,
                      recipes: daySlotRecipes[slot],
                      onAdd: () => _openPicker(selected, slot),
                      onRemove: (i) => _removeRecipe(selected, slot, i),
                    ),
                    const SizedBox(height: 12),
                  ],

                const SizedBox(height: 12),

                // ── Shopping generator ─────────────────────────────────
                ShoppingGeneratorCard(
                  isDark: isDark,
                  numberOfPersons: _numberOfPersons,
                  onPersonsChanged: (v) =>
                      setState(() => _numberOfPersons = v),
                  shopStart: _shopStart,
                  shopEnd: _shopEnd,
                  onStartChanged: (d) => setState(() {
                    _shopStart = d;
                    if (_shopEnd.isBefore(d)) _shopEnd = d;
                  }),
                  onEndChanged: (d) => setState(() {
                    _shopEnd = d;
                    if (_shopStart.isAfter(d)) _shopStart = d;
                  }),
                  isGenerating: _isGenerating,
                  onGenerate: _generateList,
                ),
                if (_listGenerated) ...[
                  const SizedBox(height: 20),
                  ShoppingListView(
                    isDark: isDark,
                    numberOfPersons: _numberOfPersons,
                    items: _shoppingItems,
                    onToggle: (index) {
                      setState(() {
                        final list =
                            List<({String label, bool checked})>.from(
                                _shoppingItems);
                        list[index] = (
                          label: list[index].label,
                          checked: !list[index].checked,
                        );
                        _shoppingItems
                          ..clear()
                          ..addAll(list);
                      });
                    },
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 20, color: muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Appuyez sur un jour pour voir son menu, '
                        'puis ajoutez des recettes à chaque repas.',
                        style: TextStyle(fontSize: 13, color: muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Meal slot card  (editable list of recipes for one slot of the selected day)
// ---------------------------------------------------------------------------

class _MealSlotCard extends StatelessWidget {
  const _MealSlotCard({
    required this.isDark,
    required this.slotIndex,
    required this.recipes,
    required this.onAdd,
    required this.onRemove,
  });

  final bool isDark;
  final int slotIndex;
  final List<RecipeEntity> recipes;
  final VoidCallback onAdd;
  final void Function(int recipeIndex) onRemove;

  @override
  Widget build(BuildContext context) {
    final surface =
        isDark ? AppPalette.darkPastelSurface : AppPalette.cream;
    final border =
        isDark ? AppPalette.darkPastelBorder : AppPalette.lightGray;
    final onBg =
        isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final muted =
        isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;
    final accent =
        isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange;

    final emoji = MealPlanningTable.mealEmojis[slotIndex];
    final label = MealPlanningTable.mealLabelsFull[slotIndex];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: onBg,
                  ),
                ),
                const Spacer(),
                if (recipes.isNotEmpty)
                  Text(
                    '${recipes.length} plat${recipes.length > 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
              ],
            ),
          ),

          if (recipes.isNotEmpty) ...[
            Divider(height: 1, thickness: 1, color: border),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < recipes.length; i++)
                    _RecipeChip(
                      label: recipes[i].title,
                      isDark: isDark,
                      onRemove: () => onRemove(i),
                    ),
                ],
              ),
            ),
          ],

          // Add button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAdd,
                icon: Icon(Icons.add, size: 16, color: accent),
                label: Text(
                  'Ajouter une recette',
                  style: TextStyle(
                    fontSize: 13,
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: accent.withValues(alpha: 0.5), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  backgroundColor: accent.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recipe chip inside a slot card
// ---------------------------------------------------------------------------

class _RecipeChip extends StatelessWidget {
  const _RecipeChip({
    required this.label,
    required this.isDark,
    required this.onRemove,
  });

  final String label;
  final bool isDark;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final accent =
        isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange;
    final bg = accent.withValues(alpha: 0.1);
    final onBg =
        isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: onBg,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: accent),
          ),
        ],
      ),
    );
  }
}
