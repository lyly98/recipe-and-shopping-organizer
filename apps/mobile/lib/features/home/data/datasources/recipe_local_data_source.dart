import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/sync_queue.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/logger.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/recipe_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/recipe_model.dart';

/// Extends [RecipeRemoteDataSource] with extra methods needed by the
/// offline adapter and the sync service.
abstract class RecipeLocalDataSource implements RecipeRemoteDataSource {
  Future<void> cacheRecipe(RecipeModel recipe);
  Future<void> cacheRecipes(List<RecipeModel> recipes);

  /// Removes the entry keyed by [localId] and stores [serverModel] under its
  /// real server ID. Called by [SyncService] after a successful create sync.
  Future<void> replaceLocalId(String localId, RecipeModel serverModel);
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  RecipeLocalDataSourceImpl(this._syncQueue);

  static const String _boxName = 'recipes_cache';

  /// Exposed so [main.dart] can open the box before the provider is created.
  static const String boxNameForInit = _boxName;

  static const Uuid _uuid = Uuid();

  final SyncQueue _syncQueue;

  Box<String> get _box => Hive.box<String>(_boxName);

  // ---------------------------------------------------------------------------
  // RecipeRemoteDataSource — read
  // ---------------------------------------------------------------------------

  @override
  Future<List<RecipeModel>> getMyRecipes({
    int page = 1,
    int itemsPerPage = 50,
    String? categoryId,
    bool favoritesOnly = false,
  }) async {
    try {
      var recipes = _box.values
          .map((v) {
            try {
              return RecipeModel.fromJson(
                jsonDecode(v) as Map<String, dynamic>,
              );
            } catch (e) {
              Logger.error('RecipeLocalDataSource: failed to parse recipe', e);
              return null;
            }
          })
          .whereType<RecipeModel>()
          .toList();

      if (categoryId != null && categoryId.isNotEmpty) {
        recipes = recipes.where((r) => r.categoryId == categoryId).toList();
      }
      if (favoritesOnly) {
        recipes = recipes.where((r) => r.isFavorite).toList();
      }

      return recipes;
    } catch (e) {
      Logger.error('RecipeLocalDataSource: getMyRecipes failed', e);
      throw CacheException(message: 'Failed to read recipes from cache: $e');
    }
  }

  @override
  Future<RecipeModel> getRecipe(String id) async {
    final raw = _box.get(id);
    if (raw == null) {
      throw ServerException(message: 'Recipe $id not found in cache');
    }
    try {
      return RecipeModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException(message: 'Failed to parse cached recipe: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // RecipeRemoteDataSource — write (enqueues to SyncQueue)
  // ---------------------------------------------------------------------------

  @override
  Future<RecipeModel> createRecipe(Map<String, dynamic> body) async {
    final localId = 'local_${_uuid.v4().replaceAll('-', '')}';
    final now = DateTime.now().toIso8601String();

    final recipeJson = <String, dynamic>{
      'id': localId,
      'user_id': '',
      'title': body['title'] ?? '',
      'category_id': body['category_id'],
      'meal_usage': body['meal_usage'],
      'prep_time_minutes': body['prep_time_minutes'] ?? 0,
      'cook_time_minutes': body['cook_time_minutes'] ?? 0,
      'servings': body['servings'] ?? 1,
      'is_favorite': body['is_favorite'] ?? false,
      'is_public': body['is_public'] ?? false,
      'image_urls': body['image_urls'] ?? <dynamic>[],
      'tags': body['tags'] ?? <dynamic>[],
      'view_count': 0,
      'created_at': now,
      'updated_at': now,
      'ingredients': _buildLocalIngredients(body['ingredients'], localId),
      'preparation_steps': _buildLocalSteps(body['preparation_steps'], localId),
    };

    await _box.put(localId, jsonEncode(recipeJson));

    await _syncQueue.enqueue(
      SyncOperation(
        id: _uuid.v4(),
        type: 'recipe',
        operation: 'create',
        entityId: localId,
        localId: localId,
        payload: body,
        createdAt: DateTime.now(),
      ),
    );

    Logger.info('RecipeLocalDataSource: created local recipe $localId');
    return RecipeModel.fromJson(recipeJson);
  }

  @override
  Future<RecipeModel> updateRecipe(
    String id,
    Map<String, dynamic> body,
  ) async {
    final raw = _box.get(id);
    if (raw == null) {
      throw ServerException(message: 'Recipe $id not found in cache');
    }

    final existingJson =
        Map<String, dynamic>.from(jsonDecode(raw) as Map<String, dynamic>);

    existingJson
      ..addAll(body)
      ..['updated_at'] = DateTime.now().toIso8601String();

    if (body.containsKey('ingredients')) {
      existingJson['ingredients'] =
          _buildLocalIngredients(body['ingredients'], id);
    }
    if (body.containsKey('preparation_steps')) {
      existingJson['preparation_steps'] =
          _buildLocalSteps(body['preparation_steps'], id);
    }

    await _box.put(id, jsonEncode(existingJson));

    await _syncQueue.enqueue(
      SyncOperation(
        id: _uuid.v4(),
        type: 'recipe',
        operation: 'update',
        entityId: id,
        payload: body,
        createdAt: DateTime.now(),
      ),
    );

    Logger.info('RecipeLocalDataSource: queued update for recipe $id');
    return RecipeModel.fromJson(existingJson);
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await _box.delete(id);

    await _syncQueue.enqueue(
      SyncOperation(
        id: _uuid.v4(),
        type: 'recipe',
        operation: 'delete',
        entityId: id,
        payload: const {},
        createdAt: DateTime.now(),
      ),
    );

    Logger.info('RecipeLocalDataSource: queued delete for recipe $id');
  }

  @override
  Future<RecipeModel> toggleFavorite(String id) async {
    final raw = _box.get(id);
    if (raw == null) {
      throw ServerException(message: 'Recipe $id not found in cache');
    }

    final recipeJson =
        Map<String, dynamic>.from(jsonDecode(raw) as Map<String, dynamic>);

    final isFavorite = !(recipeJson['is_favorite'] as bool? ?? false);
    recipeJson['is_favorite'] = isFavorite;
    recipeJson['updated_at'] = DateTime.now().toIso8601String();

    await _box.put(id, jsonEncode(recipeJson));

    await _syncQueue.enqueue(
      SyncOperation(
        id: _uuid.v4(),
        type: 'recipe',
        operation: 'update',
        entityId: id,
        payload: {'is_favorite': isFavorite},
        createdAt: DateTime.now(),
      ),
    );

    return RecipeModel.fromJson(recipeJson);
  }

  @override
  Future<String> uploadRecipeImage(String filePath) async {
    // Return the local path as-is. SyncService uploads the file and substitutes
    // the real URL when syncing the associated create/update op.
    return filePath;
  }

  // ---------------------------------------------------------------------------
  // RecipeLocalDataSource — cache helpers
  // ---------------------------------------------------------------------------

  @override
  Future<void> cacheRecipe(RecipeModel recipe) async {
    try {
      await _box.put(recipe.id, jsonEncode(_modelToJson(recipe)));
    } catch (e) {
      Logger.error(
        'RecipeLocalDataSource: failed to cache recipe ${recipe.id}',
        e,
      );
    }
  }

  @override
  Future<void> cacheRecipes(List<RecipeModel> recipes) async {
    try {
      final entries = {
        for (final r in recipes) r.id: jsonEncode(_modelToJson(r)),
      };
      await _box.putAll(entries);
    } catch (e) {
      Logger.error('RecipeLocalDataSource: failed to cache recipes', e);
    }
  }

  @override
  Future<void> replaceLocalId(String localId, RecipeModel serverModel) async {
    await _box.delete(localId);
    await cacheRecipe(serverModel);
    Logger.info(
      'RecipeLocalDataSource: replaced $localId → ${serverModel.id}',
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> _buildLocalIngredients(
    dynamic raw,
    String recipeId,
  ) {
    if (raw == null) return [];
    return (raw as List<dynamic>).asMap().entries.map((entry) {
      final item = entry.value as Map<String, dynamic>;
      return <String, dynamic>{
        'id': 'local_${_uuid.v4().replaceAll('-', '')}',
        'recipe_id': recipeId,
        'name': item['name'] ?? '',
        'quantity': item['quantity'] ?? '1',
        'unit': item['unit'],
        'display_order': item['display_order'] ?? entry.key,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildLocalSteps(dynamic raw, String recipeId) {
    if (raw == null) return [];
    return (raw as List<dynamic>).asMap().entries.map((entry) {
      final item = entry.value as Map<String, dynamic>;
      return <String, dynamic>{
        'id': 'local_${_uuid.v4().replaceAll('-', '')}',
        'recipe_id': recipeId,
        'step_number': item['step_number'] ?? (entry.key + 1),
        'instruction': item['instruction'] ?? '',
        'duration_minutes': item['duration_minutes'],
      };
    }).toList();
  }

  Map<String, dynamic> _modelToJson(RecipeModel recipe) => {
        'id': recipe.id,
        'user_id': recipe.userId,
        'title': recipe.title,
        'category_id': recipe.categoryId,
        'meal_usage': recipe.mealUsage,
        'prep_time_minutes': recipe.prepTimeMinutes,
        'cook_time_minutes': recipe.cookTimeMinutes,
        'servings': recipe.servings,
        'is_favorite': recipe.isFavorite,
        'is_public': recipe.isPublic,
        'image_urls': recipe.imageUrls ?? <String>[],
        'tags': recipe.tags ?? <String>[],
        'view_count': recipe.viewCount,
        'created_at': recipe.createdAt?.toIso8601String(),
        'updated_at': recipe.updatedAt?.toIso8601String(),
        'ingredients': recipe.ingredients
            .map(
              (i) => {
                'id': i.id,
                'recipe_id': i.recipeId,
                'name': i.name,
                'quantity': i.quantity,
                'unit': i.unit,
                'display_order': i.displayOrder,
              },
            )
            .toList(),
        'preparation_steps': recipe.preparationSteps
            .map(
              (s) => {
                'id': s.id,
                'recipe_id': s.recipeId,
                'step_number': s.stepNumber,
                'instruction': s.instruction,
                'duration_minutes': s.durationMinutes,
              },
            )
            .toList(),
      };
}
