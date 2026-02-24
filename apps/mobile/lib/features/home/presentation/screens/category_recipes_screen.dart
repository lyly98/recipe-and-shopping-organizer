import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/recipe_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/categories_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/recipes_provider.dart';
import 'package:go_router/go_router.dart';

/// Screen showing all recipes in a category (by id or name), with search and image grid.
class CategoryRecipesScreen extends ConsumerStatefulWidget {
  const CategoryRecipesScreen({
    super.key,
    this.categoryId,
    this.categoryName = '',
  });

  final String? categoryId;
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
    final recipesAsync = ref.watch(recipesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recipes = recipesAsync.value ?? [];
    final categories = categoriesAsync.value ?? [];
    final displayName = widget.categoryId != null && widget.categoryId!.isNotEmpty
        ? (categories.where((c) => c.id == widget.categoryId).firstOrNull?.name ?? widget.categoryName)
        : widget.categoryName;
    final inCategory = widget.categoryId != null && widget.categoryId!.isNotEmpty
        ? recipes.where((r) => r.categoryId == widget.categoryId).toList()
        : recipes.where((r) {
            final name = categoryNameForRecipe(r.categoryId, categories);
            return name != null && name.toLowerCase() == widget.categoryName.toLowerCase();
          }).toList();
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
          displayName.isNotEmpty ? displayName : 'Recettes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: onBg,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: recipesAsync.when(
        data: (_) => Column(
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.toString(), textAlign: TextAlign.center, style: TextStyle(color: onBg)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.read(recipesProvider.notifier).load(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}

class _RecipeGridCard extends StatelessWidget {
  const _RecipeGridCard({
    required this.recipe,
    required this.isDark,
  });

  final RecipeEntity recipe;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final surface = isDark ? AppPalette.darkPastelSurface : AppPalette.cream;
    final rawImageUrl = recipe.imageUrls != null && recipe.imageUrls!.isNotEmpty
        ? recipe.imageUrls!.first
        : null;
    final imageUrl = AppConstants.resolveRecipeImageUrl(rawImageUrl) ?? rawImageUrl;
    final isLocalFile = imageUrl != null && !imageUrl.startsWith('http') && imageUrl.startsWith('/') && File(imageUrl).existsSync();

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
                child: isLocalFile
                    ? Image.file(
                        File(imageUrl),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : (imageUrl != null && imageUrl.startsWith('http')
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _placeholder(onBg),
                          )
                        : _placeholder(onBg)),
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

  Widget _placeholder(Color onBg) {
    return Container(
      color: isDark ? AppPalette.darkPastelBorder : AppPalette.lightGray,
      child: Icon(
        Icons.restaurant,
        size: 48,
        color: onBg.withValues(alpha: 0.5),
      ),
    );
  }
}
