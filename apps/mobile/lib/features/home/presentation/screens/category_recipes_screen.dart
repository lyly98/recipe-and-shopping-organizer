import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/recipes_provider.dart';
import 'package:go_router/go_router.dart';

/// Screen showing all recipes in a category, with search and image grid.
class CategoryRecipesScreen extends ConsumerStatefulWidget {
  const CategoryRecipesScreen({
    super.key,
    required this.categoryName,
  });

  final String categoryName;

  @override
  ConsumerState<CategoryRecipesScreen> createState() => _CategoryRecipesScreenState();
}

class _CategoryRecipesScreenState extends ConsumerState<CategoryRecipesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inCategory = recipes.where((r) => r.category == widget.categoryName).toList();
    final filtered = _query.isEmpty
        ? inCategory
        : inCategory.where((r) => r.title.toLowerCase().contains(_query)).toList();

    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final surface = isDark ? AppPalette.darkPastelSurface : AppPalette.cream;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.categoryName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: onBg,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une recette...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      _query.isEmpty ? 'Aucune recette dans cette catégorie' : 'Aucun résultat',
                      style: TextStyle(color: onBg.withValues(alpha: 0.7)),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final recipe = filtered[index];
                      return _RecipeGridCard(
                        recipe: recipe,
                        isDark: isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecipeGridCard extends StatelessWidget {
  const _RecipeGridCard({
    required this.recipe,
    required this.isDark,
  });

  final RecipeItem recipe;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final surface = isDark ? AppPalette.darkPastelSurface : AppPalette.cream;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black12,
        child: InkWell(
        onTap: () => context.push('${AppConstants.recipeRoute}?id=${Uri.encodeComponent(recipe.id)}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: recipe.imagePath != null && File(recipe.imagePath!).existsSync()
                    ? Image.file(
                        File(recipe.imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: isDark ? AppPalette.darkPastelBorder : AppPalette.lightGray,
                        child: Icon(
                          Icons.restaurant,
                          size: 48,
                          color: onBg.withValues(alpha: 0.5),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                recipe.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: onBg,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
