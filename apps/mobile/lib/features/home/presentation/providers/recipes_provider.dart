import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/category_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/recipe_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/providers/home_providers.dart';

class RecipesNotifier extends AsyncNotifier<List<RecipeEntity>> {
  @override
  Future<List<RecipeEntity>> build() async {
    // Keep the sync listener alive while the recipes screen is active.
    ref.watch(syncListenerProvider);
    return _load();
  }

  Future<List<RecipeEntity>> _load() async {
    final repo = ref.read(recipeRepositoryProvider);
    final result = await repo.getMyRecipes(page: 1, itemsPerPage: 100);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (list) => list,
    );
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<String?> addRecipe({
    required String title,
    String? categoryId,
    String? mealUsage,
    int prepTimeMinutes = 0,
    int cookTimeMinutes = 0,
    int servings = 1,
    List<String>? imageUrls,
    List<String>? tags,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> preparationSteps,
  }) async {
    final repo = ref.read(recipeRepositoryProvider);
    final result = await repo.createRecipe(
      title: title,
      categoryId: categoryId,
      mealUsage: mealUsage,
      prepTimeMinutes: prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes,
      servings: servings,
      imageUrls: imageUrls,
      tags: tags,
      ingredients: ingredients,
      preparationSteps: preparationSteps,
    );
    return result.fold(
      (failure) => failure.message,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }

  Future<String?> updateRecipeFull({
    required String id,
    required String title,
    String? categoryId,
    String? mealUsage,
    int? servings,
    List<String>? imageUrls,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> preparationSteps,
  }) async {
    final repo = ref.read(recipeRepositoryProvider);
    final result = await repo.updateRecipeFull(
      id,
      title: title,
      categoryId: categoryId,
      mealUsage: mealUsage,
      servings: servings,
      imageUrls: imageUrls,
      ingredients: ingredients,
      preparationSteps: preparationSteps,
    );
    return result.fold(
      (failure) => failure.message,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }

  Future<String?> removeRecipe(String id) async {
    final repo = ref.read(recipeRepositoryProvider);
    final result = await repo.deleteRecipe(id);
    return result.fold(
      (failure) => failure.message,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }

  /// Reassign all recipes in category [fromCategoryId] to [toCategoryId].
  Future<String?> reassignCategory(String fromCategoryId, String toCategoryId) async {
    if (fromCategoryId == toCategoryId) return null;
    final value = state.value;
    if (value == null) return null;
    final repo = ref.read(recipeRepositoryProvider);
    final toUpdate = value.where((r) => r.categoryId == fromCategoryId).toList();
    for (final recipe in toUpdate) {
      final result = await repo.updateRecipe(recipe.id, categoryId: toCategoryId);
      if (result.isLeft()) return result.fold((f) => f.message, (_) => null);
    }
    ref.invalidateSelf();
    return null;
  }

  Future<String?> toggleFavorite(String id) async {
    final repo = ref.read(recipeRepositoryProvider);
    final result = await repo.toggleFavorite(id);
    return result.fold(
      (failure) => failure.message,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }
}

final recipesProvider =
    AsyncNotifierProvider<RecipesNotifier, List<RecipeEntity>>(
  RecipesNotifier.new,
);

/// Count of recipes per category (by category id).
int recipeCountForCategory(List<RecipeEntity> recipes, String categoryId) {
  return recipes.where((r) => r.categoryId == categoryId).length;
}

/// Find category name from categories list for a recipe's categoryId.
String? categoryNameForRecipe(String? categoryId, List<CategoryEntity> categories) {
  if (categoryId == null || categoryId.isEmpty) return null;
  try {
    return categories.firstWhere((c) => c.id == categoryId).name;
  } catch (_) {
    return null;
  }
}
