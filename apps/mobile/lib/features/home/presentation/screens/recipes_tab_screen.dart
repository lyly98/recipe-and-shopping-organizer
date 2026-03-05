import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/categories_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/recipes_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/category_card.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/providers/home_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/import_from_link_modal.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/new_recipe_modal.dart';
import 'package:go_router/go_router.dart';

/// "Mes Recettes" tab: page title, action buttons, then grid of recipe category cards.
class RecipesTabScreen extends ConsumerWidget {
  const RecipesTabScreen({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final recipesAsync = ref.watch(recipesProvider);
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;

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
                  'Prêt à mijoter!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: onBg,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final categories = categoriesAsync.value ?? [];
                            final items = categoriesToItems(categories);
                            if (items.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Chargez les catégories ou ajoutez-en une.')),
                              );
                              return;
                            }
                            NewRecipeModal.show(
                              context,
                              isDark: isDark,
                              categoryItems: items,
                              uploadImage: (path) async {
                                final repo = ref.read(recipeRepositoryProvider);
                                final result = await repo.uploadRecipeImage(path);
                                return result.fold((_) => null, (url) => url);
                              },
                              onSave: (params) => ref.read(recipesProvider.notifier).addRecipe(
                                    title: params['title'] as String? ?? '',
                                    categoryId: _nullableString(params['categoryId']),
                                    mealUsage: _nullableString(params['mealUsage']),
                                    servings: (params['servings'] as int?) ?? 1,
                                    imageUrls: _toStringList(params['imageUrls']),
                                    ingredients: _toMapList(params['ingredients']),
                                    preparationSteps: _toMapList(params['preparationSteps']),
                                  ),
                            );
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final entity = await ImportFromLinkModal.show(
                              context,
                              isDark: isDark,
                            );
                            if (entity != null && context.mounted) {
                              final categories = categoriesAsync.value ?? [];
                              final items = categoriesToItems(categories);
                              NewRecipeModal.show(
                                context,
                                isDark: isDark,
                                categoryItems: items,
                                existingRecipe: entity,
                                uploadImage: (path) async {
                                  final repo = ref.read(recipeRepositoryProvider);
                                  final result = await repo.uploadRecipeImage(path);
                                  return result.fold((_) => null, (url) => url);
                                },
                                onSave: (params) =>
                                    ref.read(recipesProvider.notifier).addRecipe(
                                          title: params['title'] as String? ?? '',
                                          categoryId: _nullableString(params['categoryId']),
                                          mealUsage: _nullableString(params['mealUsage']),
                                          servings: (params['servings'] as int?) ?? 1,
                                          imageUrls: _toStringList(params['imageUrls']),
                                          ingredients: _toMapList(params['ingredients']),
                                          preparationSteps: _toMapList(params['preparationSteps']),
                                        ),
                              );
                            }
                          },
                          icon: const Icon(Icons.link, size: 18),
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
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.push(AppConstants.categoriesManagementRoute),
                    icon: Icon(Icons.settings_rounded, size: 18, color: isDark ? AppPalette.darkPastelPrimaryBlue : AppPalette.primaryBlue),
                    label: Text(
                      'Gérer les catégories',
                      style: TextStyle(
                        color: isDark ? AppPalette.darkPastelPrimaryBlue : AppPalette.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        categoriesAsync.when(
          data: (categories) {
            final items = categoriesToItems(categories);
            final recipes = recipesAsync.value ?? [];
            return SliverPadding(
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
                    final cat = items[index];
                    final bg = isDark ? categoryDarkColor(index) : categoryLightColor(index);
                    final fg = isDark
                        ? AppPalette.darkPastelOnBackground
                        : AppPalette.darkGray;
                    final count = recipeCountForCategory(recipes, cat.id);
                    return CategoryCard(
                      emoji: cat.emoji,
                      name: cat.name,
                      count: count,
                      backgroundColor: bg,
                      foregroundColor: fg,
                      isDark: isDark,
                      onTap: () => context.push('${AppConstants.categoryRoute}?id=${Uri.encodeComponent(cat.id)}'),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(err.toString(), textAlign: TextAlign.center, style: TextStyle(color: onBg)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref.read(categoriesProvider.notifier).load(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String? _nullableString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

List<String>? _toStringList(dynamic v) {
  if (v == null) return null;
  if (v is! List || v.isEmpty) return null;
  return v.map((e) => e.toString()).toList();
}

List<Map<String, dynamic>> _toMapList(dynamic v) {
  if (v == null) return [];
  if (v is! List) return [];
  return v
      .map<Map<String, dynamic>>((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
      .toList();
}
