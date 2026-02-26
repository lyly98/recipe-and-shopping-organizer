import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/category_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/recipe_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/categories_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/recipes_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/providers/home_providers.dart';

/// Full-page recipe picker grouped by category.
/// Returns the selected [RecipeEntity] via [Navigator.pop].
class RecipePickerScreen extends ConsumerStatefulWidget {
  const RecipePickerScreen({
    super.key,
    required this.mealLabel,
  });

  final String mealLabel;

  @override
  ConsumerState<RecipePickerScreen> createState() => _RecipePickerScreenState();
}

class _RecipePickerScreenState extends ConsumerState<RecipePickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _collapsedCategories = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _select(RecipeEntity recipe) => Navigator.of(context).pop(recipe);

  void _preview(RecipeEntity recipe, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? AppPalette.darkPastelSurfaceElevated : AppPalette.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _RecipePreviewSheet(recipe: recipe, isDark: isDark),
    );
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_collapsedCategories.contains(categoryId)) {
        _collapsedCategories.remove(categoryId);
      } else {
        _collapsedCategories.add(categoryId);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Build grouped list items
  // ---------------------------------------------------------------------------

  /// Returns a flat list of [_ListItem] (either a header or a recipe tile).
  List<_ListItem> _buildItems(
    List<RecipeEntity> recipes,
    List<CategoryEntity> categories,
  ) {
    final items = <_ListItem>[];

    // Build a lookup: categoryId → CategoryEntity
    final categoryMap = {for (final c in categories) c.id: c};

    // Group recipes by categoryId (null → uncategorised)
    final Map<String?, List<RecipeEntity>> grouped = {};
    for (final recipe in recipes) {
      grouped.putIfAbsent(recipe.categoryId, () => []).add(recipe);
    }

    // Sort: categorised first (in the order categories appear), then uncategorised
    final orderedKeys = [
      ...categories
          .where((c) => grouped.containsKey(c.id))
          .map((c) => c.id as String?),
      if (grouped.containsKey(null)) null,
    ];

    for (final key in orderedKeys) {
      final sectionRecipes = grouped[key] ?? [];
      final category = key != null ? categoryMap[key] : null;
      final sectionId = key ?? '__none__';
      final isCollapsed = _collapsedCategories.contains(sectionId);

      items.add(_ListItem.header(
        categoryId: sectionId,
        label: category?.name ?? 'Sans catégorie',
        emoji: category?.emoji ?? '📁',
        count: sectionRecipes.length,
        isCollapsed: isCollapsed,
      ));

      if (!isCollapsed) {
        for (final recipe in sectionRecipes) {
          items.add(_ListItem.recipe(recipe));
        }
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBg =
        isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final bg = isDark ? AppPalette.darkPastelBackground : AppPalette.white;
    final surface =
        isDark ? AppPalette.darkPastelSurface : AppPalette.lightGray;
    final muted =
        isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;

    final recipesAsync = ref.watch(recipesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppPalette.darkPastelSurface : AppPalette.white,
        foregroundColor: onBg,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisir une recette',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: onBg,
              ),
            ),
            Text(
              'pour ${widget.mealLabel}',
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une recette…',
                hintStyle: TextStyle(color: muted),
                prefixIcon: Icon(Icons.search, color: muted),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: Icon(Icons.clear, color: muted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase().trim()),
            ),
          ),
          Expanded(
            child: recipesAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: isDark
                      ? AppPalette.darkPastelPrimaryOrange
                      : AppPalette.primaryOrange,
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_outlined, size: 40, color: muted),
                    const SizedBox(height: 12),
                    Text(
                      'Erreur de chargement',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: muted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Vérifiez votre connexion et réessayez.',
                      style: TextStyle(fontSize: 13, color: muted),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => ref.invalidate(recipesProvider),
                      icon: Icon(Icons.refresh,
                          size: 16,
                          color: isDark
                              ? AppPalette.darkPastelPrimaryOrange
                              : AppPalette.primaryOrange),
                      label: Text(
                        'Réessayer',
                        style: TextStyle(
                          color: isDark
                              ? AppPalette.darkPastelPrimaryOrange
                              : AppPalette.primaryOrange,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark
                              ? AppPalette.darkPastelPrimaryOrange
                              : AppPalette.primaryOrange,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              data: (recipes) {
                // ── Search mode: flat filtered list ──────────────────────────
                if (isSearching) {
                  final filtered = recipes
                      .where((r) =>
                          r.title.toLowerCase().contains(_searchQuery))
                      .toList();

                  if (filtered.isEmpty) {
                    return _EmptyState(muted: muted);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _RecipePickerTile(
                      recipe: filtered[i],
                      isDark: isDark,
                      onPreview: () => _preview(filtered[i], isDark),
                      onSelect: () => _select(filtered[i]),
                    ),
                  );
                }

                // ── Category mode: grouped list ───────────────────────────────
                if (recipes.isEmpty) {
                  return _EmptyState(muted: muted);
                }

                final categories =
                    categoriesAsync.value ?? <CategoryEntity>[];
                final listItems = _buildItems(recipes, categories);

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
                  itemCount: listItems.length,
                  itemBuilder: (_, i) {
                    final item = listItems[i];

                    if (item.isHeader) {
                      return _CategoryHeader(
                        emoji: item.emoji!,
                        label: item.label!,
                        count: item.count!,
                        isCollapsed: item.isCollapsed!,
                        isDark: isDark,
                        onTap: () => _toggleCategory(item.categoryId!),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _RecipePickerTile(
                        recipe: item.recipe!,
                        isDark: isDark,
                        onPreview: () => _preview(item.recipe!, isDark),
                        onSelect: () => _select(item.recipe!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List item model (header | recipe)
// ---------------------------------------------------------------------------

class _ListItem {
  _ListItem.header({
    required String categoryId,
    required String label,
    required String emoji,
    required int count,
    required bool isCollapsed,
  })  : isHeader = true,
        categoryId = categoryId,
        label = label,
        emoji = emoji,
        count = count,
        isCollapsed = isCollapsed,
        recipe = null;

  _ListItem.recipe(RecipeEntity r)
      : isHeader = false,
        recipe = r,
        categoryId = null,
        label = null,
        emoji = null,
        count = null,
        isCollapsed = null;

  final bool isHeader;
  final RecipeEntity? recipe;
  final String? categoryId;
  final String? label;
  final String? emoji;
  final int? count;
  final bool? isCollapsed;
}

// ---------------------------------------------------------------------------
// Category section header
// ---------------------------------------------------------------------------

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.emoji,
    required this.label,
    required this.count,
    required this.isCollapsed,
    required this.isDark,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final int count;
  final bool isCollapsed;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onBg =
        isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final muted =
        isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;
    final divider =
        isDark ? AppPalette.darkPastelBorder : AppPalette.lightGray;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: onBg,
                    ),
                  ),
                ),
                Text(
                  '$count recette${count > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: isCollapsed ? -0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 1, thickness: 1, color: divider),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.muted});
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant_outlined, size: 48, color: muted),
          const SizedBox(height: 12),
          Text(
            'Aucune recette trouvée',
            style: TextStyle(color: muted, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recipe tile
// ---------------------------------------------------------------------------

class _RecipePickerTile extends StatelessWidget {
  const _RecipePickerTile({
    required this.recipe,
    required this.isDark,
    required this.onPreview,
    required this.onSelect,
  });

  final RecipeEntity recipe;
  final bool isDark;
  final VoidCallback onPreview;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final onBg =
        isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final surface = isDark ? AppPalette.darkPastelSurface : AppPalette.cream;
    final border =
        isDark ? AppPalette.darkPastelBorder : AppPalette.lightGray;
    final muted =
        isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;

    final rawUrl = recipe.imageUrls != null && recipe.imageUrls!.isNotEmpty
        ? recipe.imageUrls!.first
        : null;
    final imageUrl = AppConstants.resolveRecipeImageUrl(rawUrl);
    final isHttp = imageUrl != null && imageUrl.startsWith('http');
    final isLocal = imageUrl != null && !isHttp;

    final totalMin = recipe.prepTimeMinutes + recipe.cookTimeMinutes;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(12)),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: _thumbnail(imageUrl, isHttp, isLocal, muted),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: onBg,
                        ),
                      ),
                      if (totalMin > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 13, color: muted),
                            const SizedBox(width: 3),
                            Text(
                              '$totalMin min',
                              style: TextStyle(fontSize: 12, color: muted),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.visibility_outlined, color: muted, size: 20),
                tooltip: 'Aperçu',
                onPressed: onPreview,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilledButton(
                  onPressed: onSelect,
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark
                        ? AppPalette.darkPastelPrimaryOrange
                        : AppPalette.primaryOrange,
                    minimumSize: const Size(36, 36),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnail(
    String? imageUrl,
    bool isHttp,
    bool isLocal,
    Color muted,
  ) {
    if (isHttp) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(muted),
      );
    }
    if (isLocal && File(imageUrl!).existsSync()) {
      return Image.file(File(imageUrl), fit: BoxFit.cover);
    }
    return _placeholder(muted);
  }

  Widget _placeholder(Color muted) => Container(
        color: muted.withValues(alpha: 0.1),
        child: Center(child: Icon(Icons.restaurant, size: 28, color: muted)),
      );
}

// ---------------------------------------------------------------------------
// Recipe preview bottom sheet — fetches full recipe (ingredients + steps)
// ---------------------------------------------------------------------------

class _RecipePreviewSheet extends ConsumerStatefulWidget {
  const _RecipePreviewSheet({required this.recipe, required this.isDark});

  final RecipeEntity recipe;
  final bool isDark;

  @override
  ConsumerState<_RecipePreviewSheet> createState() =>
      _RecipePreviewSheetState();
}

class _RecipePreviewSheetState extends ConsumerState<_RecipePreviewSheet> {
  RecipeEntity? _full;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFull();
  }

  Future<void> _fetchFull() async {
    final repo = ref.read(recipeRepositoryProvider);
    final result = await repo.getRecipe(widget.recipe.id);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _loading = false;
      }),
      (full) => setState(() {
        _full = full;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final onBg =
        isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final muted =
        isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;

    // Use full recipe if available, fall back to the list-level entity for
    // the header fields (title, times, servings) while loading.
    final recipe = _full ?? widget.recipe;

    final rawUrl = recipe.imageUrls != null && recipe.imageUrls!.isNotEmpty
        ? recipe.imageUrls!.first
        : null;
    final imageUrl = AppConstants.resolveRecipeImageUrl(rawUrl);
    final isHttp = imageUrl != null && imageUrl.startsWith('http');
    final isLocal = imageUrl != null && !isHttp;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: ListView(
          controller: scrollController,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: muted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Image
            if (imageUrl != null &&
                (isHttp || (isLocal && File(imageUrl).existsSync()))) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: isHttp
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Image.file(File(imageUrl), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Title
            Text(
              recipe.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: onBg,
              ),
            ),
            const SizedBox(height: 12),

            // Quick stats
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                if (recipe.prepTimeMinutes > 0)
                  _InfoChip(
                    icon: Icons.schedule,
                    label: 'Prép. ${recipe.prepTimeMinutes} min',
                    muted: muted,
                  ),
                if (recipe.cookTimeMinutes > 0)
                  _InfoChip(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Cuisson ${recipe.cookTimeMinutes} min',
                    muted: muted,
                  ),
                if (recipe.servings > 1)
                  _InfoChip(
                    icon: Icons.people_outlined,
                    label: '${recipe.servings} pers.',
                    muted: muted,
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Loading / error / content
            if (_loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    color: isDark
                        ? AppPalette.darkPastelPrimaryOrange
                        : AppPalette.primaryOrange,
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: muted, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Impossible de charger les détails',
                        style: TextStyle(color: muted, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Ingredients
              if (recipe.ingredients.isNotEmpty) ...[
                _SectionTitle(label: 'Ingrédients', count: recipe.ingredients.length, onBg: onBg),
                const SizedBox(height: 8),
                ...recipe.ingredients.map(
                  (ing) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(Icons.circle, size: 6, color: muted),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${ing.quantity} ${ing.unit != null ? '${ing.unit} ' : ''}${ing.name}',
                            style: TextStyle(fontSize: 13, color: onBg),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Preparation steps
              if (recipe.preparationSteps.isNotEmpty) ...[
                const SizedBox(height: 20),
                _SectionTitle(label: 'Préparation', count: recipe.preparationSteps.length, onBg: onBg),
                const SizedBox(height: 8),
                ...recipe.preparationSteps.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppPalette.darkPastelPrimaryOrange
                                    : AppPalette.primaryOrange)
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${step.stepNumber}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppPalette.darkPastelPrimaryOrange
                                    : AppPalette.primaryOrange,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.instruction,
                                style: TextStyle(fontSize: 13, color: onBg),
                              ),
                              if (step.durationMinutes != null &&
                                  step.durationMinutes! > 0) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(Icons.timer_outlined,
                                        size: 11, color: muted),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${step.durationMinutes} min',
                                      style: TextStyle(
                                          fontSize: 11, color: muted),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.muted,
  });

  final IconData icon;
  final String label;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: muted),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: muted)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.label,
    required this.count,
    required this.onBg,
  });

  final String label;
  final int count;
  final Color onBg;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label ($count)',
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: onBg,
      ),
    );
  }
}
