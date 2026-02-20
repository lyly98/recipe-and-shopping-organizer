import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/recipes_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/category_card.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/import_from_link_modal.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/new_recipe_modal.dart';
import 'package:go_router/go_router.dart';

/// "Mes Recettes" tab: page title, action buttons, then grid of recipe category cards.
class RecipesTabScreen extends ConsumerWidget {
  const RecipesTabScreen({super.key, required this.isDark});

  final bool isDark;

  static const List<({String emoji, String name, Color light, Color dark})> _categories = [
    (emoji: '🍽️', name: 'Plats', light: AppPalette.categoryPlats, dark: AppPalette.darkPastelCategoryPlats),
    (emoji: '🍞', name: 'Pains', light: AppPalette.categoryPains, dark: AppPalette.darkPastelCategoryPains),
    (emoji: '🍰', name: 'Desserts', light: AppPalette.categoryDesserts, dark: AppPalette.darkPastelCategoryDesserts),
    (emoji: '🥤', name: 'Jus', light: AppPalette.categoryJus, dark: AppPalette.darkPastelCategoryJus),
    (emoji: '🍿', name: 'Snacks', light: AppPalette.categorySnacks, dark: AppPalette.darkPastelCategorySnacks),
    (emoji: '🍲', name: 'Soupes', light: AppPalette.categorySoupes, dark: AppPalette.darkPastelCategorySoupes),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider);
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
                  'Mes Recettes',
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
                            NewRecipeModal.show(
                              context,
                              isDark: isDark,
                              onSave: (recipe) => ref.read(recipesProvider.notifier).addRecipe(recipe),
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
                          onPressed: () {
                            ImportFromLinkModal.show(context, isDark: isDark);
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
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
                final count = recipeCountForCategory(recipes, cat.name);
                return CategoryCard(
                  emoji: cat.emoji,
                  name: cat.name,
                  count: count,
                  backgroundColor: bg,
                  foregroundColor: fg,
                  isDark: isDark,
                  onTap: () => context.push('${AppConstants.categoryRoute}?name=${Uri.encodeComponent(cat.name)}'),
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
