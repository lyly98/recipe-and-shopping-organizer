import 'package:flutter_riverpod_clean_architecture/core/network/connectivity_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/logger.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/recipe_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/recipe_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/recipe_model.dart';

/// Adapter that implements [RecipeRemoteDataSource] and transparently
/// delegates to the remote API when online, or to the local Hive cache when
/// offline.
///
/// Read operations always try the remote first, write-through to cache on
/// success, and fall back to the cache on failure.
///
/// Write operations are sent directly to the API when online; when offline they
/// are applied to the local cache and queued for later sync.
class OfflineAwareRecipeDataSource implements RecipeRemoteDataSource {
  OfflineAwareRecipeDataSource({
    required RecipeRemoteDataSource remote,
    required RecipeLocalDataSource local,
    required ConnectivityService connectivity,
  })  : _remote = remote,
        _local = local,
        _connectivity = connectivity;

  final RecipeRemoteDataSource _remote;
  final RecipeLocalDataSource _local;
  final ConnectivityService _connectivity;

  // ---------------------------------------------------------------------------
  // Reads — remote first, cache fallback
  // ---------------------------------------------------------------------------

  @override
  Future<List<RecipeModel>> getMyRecipes({
    int page = 1,
    int itemsPerPage = 50,
    String? categoryId,
    bool favoritesOnly = false,
  }) async {
    if (await _connectivity.isOnline) {
      try {
        final recipes = await _remote.getMyRecipes(
          page: page,
          itemsPerPage: itemsPerPage,
          categoryId: categoryId,
          favoritesOnly: favoritesOnly,
        );
        await _local.cacheRecipes(recipes);
        return recipes;
      } catch (e) {
        Logger.warning(
          'OfflineAwareRecipeDataSource: remote getMyRecipes failed, '
          'falling back to cache. Error: $e',
        );
        return _local.getMyRecipes(
          page: page,
          itemsPerPage: itemsPerPage,
          categoryId: categoryId,
          favoritesOnly: favoritesOnly,
        );
      }
    }
    return _local.getMyRecipes(
      page: page,
      itemsPerPage: itemsPerPage,
      categoryId: categoryId,
      favoritesOnly: favoritesOnly,
    );
  }

  @override
  Future<RecipeModel> getRecipe(String id) async {
    if (await _connectivity.isOnline) {
      try {
        final recipe = await _remote.getRecipe(id);
        await _local.cacheRecipe(recipe);
        return recipe;
      } catch (e) {
        Logger.warning(
          'OfflineAwareRecipeDataSource: remote getRecipe failed, '
          'falling back to cache. Error: $e',
        );
        return _local.getRecipe(id);
      }
    }
    return _local.getRecipe(id);
  }

  // ---------------------------------------------------------------------------
  // Writes — direct to API when online, local + queued when offline
  // ---------------------------------------------------------------------------

  @override
  Future<RecipeModel> createRecipe(Map<String, dynamic> body) async {
    if (await _connectivity.isOnline) {
      final recipe = await _remote.createRecipe(body);
      await _local.cacheRecipe(recipe);
      return recipe;
    }
    return _local.createRecipe(body);
  }

  @override
  Future<RecipeModel> updateRecipe(String id, Map<String, dynamic> body) async {
    if (await _connectivity.isOnline) {
      final recipe = await _remote.updateRecipe(id, body);
      await _local.cacheRecipe(recipe);
      return recipe;
    }
    return _local.updateRecipe(id, body);
  }

  @override
  Future<void> deleteRecipe(String id) async {
    if (await _connectivity.isOnline) {
      await _remote.deleteRecipe(id);
      // Also remove from local cache so it doesn't reappear
      try {
        await _local.deleteRecipe(id);
      } catch (_) {
        // Not in cache — that's fine
      }
      return;
    }
    await _local.deleteRecipe(id);
  }

  @override
  Future<RecipeModel> toggleFavorite(String id) async {
    if (await _connectivity.isOnline) {
      final recipe = await _remote.toggleFavorite(id);
      await _local.cacheRecipe(recipe);
      return recipe;
    }
    return _local.toggleFavorite(id);
  }

  @override
  Future<String> uploadRecipeImage(String filePath) async {
    if (await _connectivity.isOnline) {
      return _remote.uploadRecipeImage(filePath);
    }
    // Return local path; SyncService will upload on reconnect
    return _local.uploadRecipeImage(filePath);
  }
}
