import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/meal_planning_table.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/shopping_generator_card.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/shopping_list_view.dart';

/// "Planning" tab: week navigator, meal calendar, shopping list generator and list.
class PlanningTabScreen extends StatefulWidget {
  const PlanningTabScreen({super.key, required this.isDark});

  final bool isDark;

  @override
  State<PlanningTabScreen> createState() => _PlanningTabScreenState();
}

class _PlanningTabScreenState extends State<PlanningTabScreen> {
  int _weekOffset = 0;
  int _numberOfPersons = 4;
  final Map<int, String?> _meals = {};
  final List<({String label, bool checked})> _shoppingItems = [
    (label: '500g de farine', checked: false),
    (label: '1kg de sel', checked: false),
    (label: '7g de levure', checked: false),
    (label: '30cm³ d\'eau tiède', checked: false),
  ];
  bool _listGenerated = false;

  static const List<String> _dayNames = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche',
  ];
  static const List<({String name, String emoji, String category})> _recipeOptions = [
    (name: 'Poulet Rôti aux Herbes', emoji: '🍽️', category: 'Plats'),
    (name: 'Pain de campagne', emoji: '🍞', category: 'Pains'),
    (name: 'Tarte aux pommes', emoji: '🍰', category: 'Desserts'),
    (name: 'Smoothie tropical', emoji: '🥤', category: 'Jus'),
  ];

  DateTime get _weekStart {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    return monday.add(Duration(days: _weekOffset * 7));
  }

  DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));

  String get _weekRangeText {
    const months = ['janv', 'févr', 'mars', 'avr', 'mai', 'juin', 'juil', 'août', 'sept', 'oct', 'nov', 'déc'];
    final start = _weekStart;
    final end = _weekEnd;
    return '${_dayNames[start.weekday - 1]} ${start.day} - ${_dayNames[end.weekday - 1]} ${end.day} ${months[end.month - 1]}';
  }

  void _pickRecipe(int dayIndex, int slotIndex) async {
    final key = dayIndex * 10 + slotIndex;
    final chosen = await showModalBottomSheet<({String name, String emoji})>(
      context: context,
      backgroundColor: widget.isDark ? AppPalette.darkPastelSurfaceElevated : AppPalette.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choisir une recette',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray,
                ),
              ),
              const SizedBox(height: 12),
              ..._recipeOptions.map((r) => ListTile(
                leading: Text(r.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(r.name),
                subtitle: Text(r.category, style: TextStyle(
                  fontSize: 12,
                  color: widget.isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray,
                )),
                onTap: () => Navigator.of(ctx).pop((name: r.name, emoji: r.emoji)),
              )),
            ],
          ),
        ),
      ),
    );
    if (chosen != null && mounted) {
      setState(() => _meals[key] = '${chosen.emoji} ${chosen.name}');
    }
  }

  void _generateList() {
    setState(() => _listGenerated = true);
    if (mounted) {
      AppUtils.showSnackBar(context, message: 'Liste générée pour $_numberOfPersons personnes');
    }
  }

  int get _plannedDishesCount =>
      _meals.values.where((v) => v != null && v.isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final muted = isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;
    final surface = isDark ? AppPalette.darkPastelSurface : AppPalette.cream;

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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppPalette.darkPastelBorder : AppPalette.lightGray,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Menu de la semaine',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: onBg,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Planifiez vos repas et générez votre liste de courses.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: muted,
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _plannedDishesCount == 0
                            ? 'Aucun plat'
                            : '$_plannedDishesCount plat${_plannedDishesCount > 1 ? 's' : ''} prévu${_plannedDishesCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: onBg,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setState(() => _weekOffset -= 1),
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
                      onPressed: () => setState(() => _weekOffset += 1),
                      color: onBg,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MealPlanningTable(
                  isDark: isDark,
                  weekStart: _weekStart,
                  meals: _meals,
                  onAddTap: _pickRecipe,
                ),
                const SizedBox(height: 24),
                ShoppingGeneratorCard(
                  isDark: isDark,
                  numberOfPersons: _numberOfPersons,
                  onPersonsChanged: (v) => setState(() => _numberOfPersons = v),
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
                        final list = List<({String label, bool checked})>.from(_shoppingItems);
                        list[index] = (label: list[index].label, checked: !list[index].checked);
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
                        'Ajoutez des recettes au planning pour générer votre liste de courses.',
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
