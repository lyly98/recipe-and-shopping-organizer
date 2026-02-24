import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/recipe_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/recipe_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  RecipeRepositoryImpl(this._remote);

  final RecipeRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<RecipeEntity>>> getMyRecipes({
    int page = 1,
    int itemsPerPage = 50,
    String? categoryId,
    bool favoritesOnly = false,
  }) async {
    try {
      final list = await _remote.getMyRecipes(
        page: page,
        itemsPerPage: itemsPerPage,
        categoryId: categoryId,
        favoritesOnly: favoritesOnly,
      );
      return Right(list.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity>> getRecipe(String id) async {
    try {
      final model = await _remote.getRecipe(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      // Normalize: backend expects UUID | null, not empty string
      final effectiveCategoryId = (categoryId != null && categoryId.trim().isNotEmpty) ? categoryId : null;

      final ingredientsList = <Map<String, dynamic>>[];
      for (var i = 0; i < ingredients.length; i++) {
        final m = ingredients[i];
        final name = (m['name'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;
        final q = (m['quantity'] as String?)?.trim();
        ingredientsList.add({
          'name': name,
          'quantity': (q != null && q.isNotEmpty) ? q : '1',
          'unit': m['unit'] as String?,
          'display_order': i,
        });
      }

      final stepsList = <Map<String, dynamic>>[];
      for (var i = 0; i < preparationSteps.length; i++) {
        final m = preparationSteps[i];
        final instruction = (m['instruction'] as String?)?.trim() ?? '';
        if (instruction.isEmpty) continue;
        stepsList.add({
          'step_number': i + 1,
          'instruction': instruction,
          'duration_minutes': m['duration_minutes'] as int?,
        });
      }

      final body = <String, dynamic>{
        'title': title.trim(),
        'meal_usage': mealUsage?.trim().isNotEmpty == true ? mealUsage!.trim() : null,
        'prep_time_minutes': prepTimeMinutes,
        'cook_time_minutes': cookTimeMinutes,
        'servings': servings,
        'is_favorite': isFavorite,
        'is_public': isPublic,
        'ingredients': ingredientsList,
        'preparation_steps': stepsList,
      };
      if (effectiveCategoryId != null) body['category_id'] = effectiveCategoryId;
      if (imageUrls != null && imageUrls.isNotEmpty) body['image_urls'] = imageUrls;
      if (tags != null && tags.isNotEmpty) body['tags'] = tags;
      final model = await _remote.createRecipe(body);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final body = <String, dynamic>{
        if (title != null) 'title': title,
        if (categoryId != null) 'category_id': categoryId,
        if (mealUsage != null) 'meal_usage': mealUsage,
        if (prepTimeMinutes != null) 'prep_time_minutes': prepTimeMinutes,
        if (cookTimeMinutes != null) 'cook_time_minutes': cookTimeMinutes,
        if (servings != null) 'servings': servings,
        if (imageUrls != null) 'image_urls': imageUrls,
        if (tags != null) 'tags': tags,
        if (isFavorite != null) 'is_favorite': isFavorite,
        if (isPublic != null) 'is_public': isPublic,
      };
      final model = await _remote.updateRecipe(id, body);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity>> updateRecipeFull(
    String id, {
    required String title,
    String? categoryId,
    String? mealUsage,
    List<String>? imageUrls,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> preparationSteps,
  }) async {
    try {
      final effectiveCategoryId =
          (categoryId != null && categoryId.trim().isNotEmpty) ? categoryId : null;

      final ingredientsList = <Map<String, dynamic>>[];
      for (var i = 0; i < ingredients.length; i++) {
        final m = ingredients[i];
        final name = (m['name'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;
        final q = (m['quantity'] as String?)?.trim();
        ingredientsList.add({
          'name': name,
          'quantity': (q != null && q.isNotEmpty) ? q : '1',
          'unit': m['unit'] as String?,
          'display_order': i,
        });
      }

      final stepsList = <Map<String, dynamic>>[];
      for (var i = 0; i < preparationSteps.length; i++) {
        final m = preparationSteps[i];
        final instruction = (m['instruction'] as String?)?.trim() ?? '';
        if (instruction.isEmpty) continue;
        stepsList.add({
          'step_number': i + 1,
          'instruction': instruction,
          'duration_minutes': m['duration_minutes'] as int?,
        });
      }

      final body = <String, dynamic>{
        'title': title.trim(),
        if (mealUsage != null && mealUsage.trim().isNotEmpty) 'meal_usage': mealUsage.trim(),
        'ingredients': ingredientsList,
        'preparation_steps': stepsList,
        if (imageUrls != null && imageUrls.isNotEmpty) 'image_urls': imageUrls,
      };
      if (effectiveCategoryId != null) body['category_id'] = effectiveCategoryId;

      final model = await _remote.updateRecipe(id, body);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecipe(String id) async {
    try {
      await _remote.deleteRecipe(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadRecipeImage(String filePath) async {
    try {
      final url = await _remote.uploadRecipeImage(filePath);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity>> toggleFavorite(String id) async {
    try {
      final model = await _remote.toggleFavorite(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
