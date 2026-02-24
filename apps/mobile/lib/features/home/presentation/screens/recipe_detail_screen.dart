import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/recipe_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/categories_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/recipes_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/new_recipe_modal.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/providers/home_providers.dart';
import 'package:go_router/go_router.dart';

/// Screen showing a single recipe: image, title, category, ingredients, steps.
class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  final String recipeId;

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  RecipeEntity? _recipe;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    // Always fetch full recipe by ID so we get ingredients, preparation_steps, and image_urls
    final repo = ref.read(recipeRepositoryProvider);
    final result = await repo.getRecipe(widget.recipeId);
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _loading = false;
        _recipe = null;
      }),
      (entity) => setState(() {
        _recipe = entity;
        _error = null;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Recette'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _recipe == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Recette'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Recette introuvable'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() => _loading = true);
                  _loadRecipe();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final recipe = _recipe!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final categories = ref.watch(categoriesProvider).value ?? [];
    final categoryItems = categoriesToItems(categories);
    final categoryName = categoryNameForRecipe(recipe.categoryId, categories);

    // Resolve so images load from current API host (fixes localhost on device/emulator)
    final rawImageUrl = recipe.imageUrls != null && recipe.imageUrls!.isNotEmpty
        ? recipe.imageUrls!.first
        : null;
    final imageUrl = AppConstants.resolveRecipeImageUrl(rawImageUrl) ?? rawImageUrl;
    final isLocalFile = imageUrl != null && (imageUrl.startsWith('/') || !imageUrl.startsWith('http'));

    return Scaffold(
      backgroundColor: isDark ? AppPalette.darkPastelBackground : AppPalette.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          recipe.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: onBg,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: onBg),
            tooltip: 'Modifier la recette',
            onPressed: () => _openEditModal(context, recipe, isDark, categoryItems),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLocalFile && File(imageUrl).existsSync())
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(
                  File(imageUrl),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            else if (imageUrl != null && imageUrl.startsWith('http'))
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _placeholder(isDark, onBg),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _placeholder(isDark, onBg),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (categoryName != null && categoryName.isNotEmpty)
                        _Chip(label: categoryName, isDark: isDark),
                      if (recipe.mealUsage != null && recipe.mealUsage!.isNotEmpty)
                        _Chip(label: recipe.mealUsage!, isDark: isDark),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (recipe.ingredients.isNotEmpty) ...[
                    _SectionTitle(title: 'Ingrédients', isDark: isDark),
                    const SizedBox(height: 8),
                    ...recipe.ingredients.map(
                      (i) => _BulletRow(
                        text: i.unit != null && i.unit!.isNotEmpty
                            ? '${i.quantity} ${i.unit} ${i.name}'
                            : '${i.quantity} ${i.name}',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (recipe.preparationSteps.isNotEmpty) ...[
                    _SectionTitle(title: 'Préparation', isDark: isDark),
                    const SizedBox(height: 8),
                    ...recipe.preparationSteps.asMap().entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isDark ? AppPalette.darkPastelBorder : AppPalette.lightGray,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${e.value.stepNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: onBg,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                e.value.instruction,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  color: onBg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  if (recipe.ingredients.isEmpty && recipe.preparationSteps.isEmpty)
                    Text(
                      'Aucun ingrédient ni étape renseignés.',
                      style: TextStyle(color: onBg.withValues(alpha: 0.7), fontSize: 15),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditModal(
    BuildContext context,
    RecipeEntity recipe,
    bool isDark,
    List<CategoryItem> categoryItems,
  ) async {
    bool wasSaved = false;

    await NewRecipeModal.show(
      context,
      isDark: isDark,
      categoryItems: categoryItems,
      existingRecipe: recipe,
      uploadImage: (path) async {
        final repo = ref.read(recipeRepositoryProvider);
        final result = await repo.uploadRecipeImage(path);
        return result.fold((_) => null, (url) => url);
      },
      onSave: (params) async {
        final id = params['id'] as String?;
        if (id == null || id.isEmpty) return 'Identifiant de recette manquant';
        final err = await ref.read(recipesProvider.notifier).updateRecipeFull(
              id: id,
              title: params['title'] as String? ?? '',
              categoryId: params['categoryId'] as String?,
              mealUsage: params['mealUsage'] as String?,
              imageUrls: _toStringList(params['imageUrls']),
              ingredients: _toMapList(params['ingredients']),
              preparationSteps: _toMapList(params['preparationSteps']),
            );
        if (err != null) return err;
        wasSaved = true;
        return null;
      },
    );

    // Reload only after the modal is fully dismissed so the freshly-built
    // detail screen picks up the new state without any overlay interference.
    if (wasSaved && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
      await _loadRecipe();
    }
  }

  Widget _placeholder(bool isDark, Color onBg) {
    return Container(
      color: isDark ? AppPalette.darkPastelBorder : AppPalette.lightGray,
      child: Icon(
        Icons.restaurant,
        size: 64,
        color: onBg.withValues(alpha: 0.5),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppPalette.darkPastelSurfaceElevated : AppPalette.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: onBg,
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.text, required this.isDark});

  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(fontSize: 16, color: onBg, height: 1.4),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: onBg, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
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
      .map<Map<String, dynamic>>(
        (e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{},
      )
      .toList();
}
