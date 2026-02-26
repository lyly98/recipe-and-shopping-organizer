import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/recipe_entity.dart';

abstract class RecipeRepository {
  /// Fetch current user's recipes (authenticated).
  Future<Either<Failure, List<RecipeEntity>>> getMyRecipes({
    int page = 1,
    int itemsPerPage = 50,
    String? categoryId,
    bool favoritesOnly = false,
  });

  /// Fetch a single recipe by id.
  Future<Either<Failure, RecipeEntity>> getRecipe(String id);

  /// Create a recipe (authenticated).
  Future<Either<Failure, RecipeEntity>> createRecipe({
    required String title,
    String? categoryId,
    String? mealUsage,
    int prepTimeMinutes = 0,
    int cookTimeMinutes = 0,
    int servings = 1,
    bool isFavorite = false,
    bool isPublic = false,
    List<String>? imageUrls,
    List<String>? tags,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> preparationSteps,
  });

  /// Update a recipe's metadata (authenticated).
  Future<Either<Failure, RecipeEntity>> updateRecipe(
    String id, {
    String? title,
    String? categoryId,
    String? mealUsage,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    List<String>? imageUrls,
    List<String>? tags,
    bool? isFavorite,
    bool? isPublic,
  });

  /// Full update: replaces recipe metadata, ingredients, and preparation steps (authenticated).
  Future<Either<Failure, RecipeEntity>> updateRecipeFull(
    String id, {
    required String title,
    String? categoryId,
    String? mealUsage,
    int? servings,
    List<String>? imageUrls,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> preparationSteps,
  });

  /// Delete a recipe (authenticated).
  Future<Either<Failure, void>> deleteRecipe(String id);

  /// Toggle favorite (authenticated).
  Future<Either<Failure, RecipeEntity>> toggleFavorite(String id);

  /// Upload a recipe image file; returns the full URL to use in image_urls.
  Future<Either<Failure, String>> uploadRecipeImage(String filePath);
}
