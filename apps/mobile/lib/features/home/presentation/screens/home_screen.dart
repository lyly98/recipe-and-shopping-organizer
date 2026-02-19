import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _HomeScreenBody(ref: ref);
  }
}

class _HomeScreenBody extends StatefulWidget {
  const _HomeScreenBody({required this.ref});

  final WidgetRef ref;

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Recettes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppPalette.darkPastelOnBackground
                : AppPalette.darkGray,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_outline,
              color: isDark
                  ? AppPalette.darkPastelOnBackground
                  : AppPalette.darkGray,
            ),
            onPressed: () => context.push(AppConstants.profileRoute),
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: isDark
                  ? AppPalette.darkPastelOnBackground
                  : AppPalette.darkGray,
            ),
            onPressed: () => _showLogoutDialog(context, widget.ref),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabs(context, isDark),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mes Recettes',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppPalette.darkPastelOnBackground
                            : AppPalette.darkGray,
                      ),
                ),
                const SizedBox(height: 16),
                _buildPrimaryButtons(context, isDark),
                const SizedBox(height: 16),
                _buildManageCategoriesButton(context, isDark),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _RecipesTab(isDark: isDark),
                _PlanningTab(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppPalette.darkPastelSurface
            : AppPalette.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isDark
              ? AppPalette.darkPastelPrimaryOrange
              : AppPalette.primaryOrange,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppPalette.white,
        unselectedLabelColor: isDark
            ? AppPalette.darkPastelOnSurfaceMuted
            : AppPalette.mediumGray,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: '🍳 Recettes'),
          Tab(text: '📅 Planning'),
        ],
      ),
    );
  }

  Widget _buildPrimaryButtons(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Nouvelle recette
              AppUtils.showSnackBar(context, message: 'Nouvelle recette');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppPalette.darkPastelPrimaryOrange
                  : AppPalette.primaryOrange,
              foregroundColor: AppPalette.white,
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Nouvelle recette'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Depuis un lien
              AppUtils.showSnackBar(context, message: 'Importer depuis un lien');
            },
            icon: const Icon(Icons.link, size: 20),
            label: const Text('Depuis un lien'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark
                  ? AppPalette.darkPastelPrimaryPink
                  : AppPalette.primaryPink,
              side: BorderSide(
                color: isDark
                    ? AppPalette.darkPastelPrimaryPink
                    : AppPalette.primaryPink,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManageCategoriesButton(BuildContext context, bool isDark) {
    return SizedBox(
      height: 44,
      child: TextButton.icon(
        onPressed: () {
          AppUtils.showSnackBar(context, message: 'Gérer les catégories');
        },
        icon: Icon(
          Icons.category_outlined,
          size: 20,
          color: isDark
              ? AppPalette.darkPastelPrimaryBlue
              : AppPalette.primaryBlue,
        ),
        label: Text(
          'Gérer catégories',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppPalette.darkPastelPrimaryBlue
                : AppPalette.primaryBlue,
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted && ref.read(authProvider).errorMessage != null) {
        AppUtils.showSnackBar(
          context,
          message: ref.read(authProvider).errorMessage!,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
  }
}

class _RecipesTab extends StatelessWidget {
  const _RecipesTab({required this.isDark});

  final bool isDark;

  static const List<({String emoji, String name, int count, Color light, Color dark})> _categories = [
    (emoji: '🍽️', name: 'Plats', count: 1, light: AppPalette.categoryPlats, dark: AppPalette.darkPastelCategoryPlats),
    (emoji: '🍞', name: 'Pains', count: 1, light: AppPalette.categoryPains, dark: AppPalette.darkPastelCategoryPains),
    (emoji: '🍰', name: 'Desserts', count: 1, light: AppPalette.categoryDesserts, dark: AppPalette.darkPastelCategoryDesserts),
    (emoji: '🥤', name: 'Jus', count: 1, light: AppPalette.categoryJus, dark: AppPalette.darkPastelCategoryJus),
    (emoji: '🍿', name: 'Snacks', count: 8, light: AppPalette.categorySnacks, dark: AppPalette.darkPastelCategorySnacks),
    (emoji: '🍲', name: 'Soupes', count: 6, light: AppPalette.categorySoupes, dark: AppPalette.darkPastelCategorySoupes),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final cat = _categories[index];
                final bg = isDark ? cat.dark : cat.light;
                final fg = isDark
                    ? AppPalette.darkPastelOnBackground
                    : AppPalette.darkGray;
                return _CategoryCard(
                  emoji: cat.emoji,
                  name: cat.name,
                  count: cat.count,
                  backgroundColor: bg,
                  foregroundColor: fg,
                  isDark: isDark,
                );
              },
              childCount: _categories.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.emoji,
    required this.name,
    required this.count,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isDark,
  });

  final String emoji;
  final String name;
  final int count;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: () {
          AppUtils.showSnackBar(context, message: 'Catégorie: $name');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: foregroundColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count recette${count > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: foregroundColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanningTab extends StatefulWidget {
  const _PlanningTab({required this.isDark});

  final bool isDark;

  @override
  State<_PlanningTab> createState() => _PlanningTabState();
}

class _PlanningTabState extends State<_PlanningTab> {
  int _weekOffset = 0;
  int _numberOfPersons = 4;
  final Map<int, String?> _meals = {}; // key: dayIndex * 10 + slotIndex (0 or 1)
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

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final muted = isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Week navigation
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
                // Meal planning table
                _MealPlanningTable(
                  isDark: isDark,
                  weekStart: _weekStart,
                  meals: _meals,
                  onAddTap: _pickRecipe,
                ),
                const SizedBox(height: 24),
                // Shopping list generator card
                _ShoppingGeneratorCard(
                  isDark: isDark,
                  numberOfPersons: _numberOfPersons,
                  onPersonsChanged: (v) => setState(() => _numberOfPersons = v),
                  onGenerate: _generateList,
                ),
                if (_listGenerated) ...[
                  const SizedBox(height: 20),
                  _ShoppingListView(
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
                // Planning link info
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

class _MealPlanningTable extends StatelessWidget {
  const _MealPlanningTable({
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
        // Header row: empty corner + day names
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
        // Two meal rows
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
                        child: _MealCell(
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

class _MealCell extends StatelessWidget {
  const _MealCell({
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

class _ShoppingGeneratorCard extends StatelessWidget {
  const _ShoppingGeneratorCard({
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

class _ShoppingListView extends StatelessWidget {
  const _ShoppingListView({
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
