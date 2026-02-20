import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/recipes_provider.dart';
import 'package:go_router/go_router.dart';

/// Screen showing a single recipe: image, title, category, ingredients, steps.
class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider);
    final matching = recipes.where((r) => r.id == recipeId).toList();
    final recipe = matching.isEmpty ? null : matching.first;

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Recette'),
        ),
        body: const Center(child: Text('Recette introuvable')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            if (recipe.imagePath != null && File(recipe.imagePath!).existsSync())
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(
                  File(recipe.imagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: isDark ? AppPalette.darkPastelBorder : AppPalette.lightGray,
                  child: Icon(
                    Icons.restaurant,
                    size: 64,
                    color: onBg.withValues(alpha: 0.5),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & mot-clé
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(label: recipe.category, isDark: isDark),
                      if (recipe.motCle != null && recipe.motCle!.isNotEmpty)
                        _Chip(label: recipe.motCle!, isDark: isDark),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Ingrédients
                  if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty) ...[
                    _SectionTitle(title: 'Ingrédients', isDark: isDark),
                    const SizedBox(height: 8),
                    ...recipe.ingredients!.map((s) => _BulletRow(text: s, isDark: isDark)),
                    const SizedBox(height: 24),
                  ],
                  // Préparation
                  if (recipe.steps != null && recipe.steps!.isNotEmpty) ...[
                    _SectionTitle(title: 'Préparation', isDark: isDark),
                    const SizedBox(height: 8),
                    ...recipe.steps!.asMap().entries.map((e) {
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
                                '${e.key + 1}',
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
                                e.value,
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
                  if ((recipe.ingredients == null || recipe.ingredients!.isEmpty) &&
                      (recipe.steps == null || recipe.steps!.isEmpty))
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
