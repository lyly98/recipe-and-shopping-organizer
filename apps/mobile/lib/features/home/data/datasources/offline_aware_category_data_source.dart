import 'package:flutter_riverpod_clean_architecture/core/network/connectivity_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/logger.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/category_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/category_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/category_model.dart';

/// Adapter that implements [CategoryRemoteDataSource] and transparently
/// delegates to the remote API when online, or to the local Hive cache when
/// offline.
class OfflineAwareCategoryDataSource implements CategoryRemoteDataSource {
  OfflineAwareCategoryDataSource({
    required CategoryRemoteDataSource remote,
    required CategoryLocalDataSource local,
    required ConnectivityService connectivity,
  })  : _remote = remote,
        _local = local,
        _connectivity = connectivity;

  final CategoryRemoteDataSource _remote;
  final CategoryLocalDataSource _local;
  final ConnectivityService _connectivity;

  // ---------------------------------------------------------------------------
  // Reads — remote first, cache fallback
  // ---------------------------------------------------------------------------

  @override
  Future<List<CategoryModel>> getCategories({
    int page = 1,
    int itemsPerPage = 50,
  }) async {
    if (await _connectivity.isOnline) {
      try {
        final categories =
            await _remote.getCategories(page: page, itemsPerPage: itemsPerPage);
        await _local.cacheCategories(categories);
        return categories;
      } catch (e) {
        Logger.warning(
          'OfflineAwareCategoryDataSource: remote getCategories failed, '
          'falling back to cache. Error: $e',
        );
        return _local.getCategories(page: page, itemsPerPage: itemsPerPage);
      }
    }
    return _local.getCategories(page: page, itemsPerPage: itemsPerPage);
  }

  @override
  Future<CategoryModel> getCategory(String id) async {
    if (await _connectivity.isOnline) {
      try {
        final category = await _remote.getCategory(id);
        await _local.cacheCategory(category);
        return category;
      } catch (e) {
        Logger.warning(
          'OfflineAwareCategoryDataSource: remote getCategory failed, '
          'falling back to cache. Error: $e',
        );
        return _local.getCategory(id);
      }
    }
    return _local.getCategory(id);
  }

  // ---------------------------------------------------------------------------
  // Writes — direct to API when online, local + queued when offline
  // ---------------------------------------------------------------------------

  @override
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? emoji,
    String? color,
  }) async {
    if (await _connectivity.isOnline) {
      final category = await _remote.createCategory(
        name: name,
        description: description,
        emoji: emoji,
        color: color,
      );
      await _local.cacheCategory(category);
      return category;
    }
    return _local.createCategory(
      name: name,
      description: description,
      emoji: emoji,
      color: color,
    );
  }

  @override
  Future<CategoryModel> updateCategory(
    String id, {
    String? name,
    String? description,
    String? emoji,
    String? color,
    int? displayOrder,
  }) async {
    if (await _connectivity.isOnline) {
      final category = await _remote.updateCategory(
        id,
        name: name,
        description: description,
        emoji: emoji,
        color: color,
        displayOrder: displayOrder,
      );
      await _local.cacheCategory(category);
      return category;
    }
    return _local.updateCategory(
      id,
      name: name,
      description: description,
      emoji: emoji,
      color: color,
      displayOrder: displayOrder,
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    if (await _connectivity.isOnline) {
      await _remote.deleteCategory(id);
      try {
        await _local.deleteCategory(id);
      } catch (_) {
        // Not in cache — that's fine
      }
      return;
    }
    await _local.deleteCategory(id);
  }
}
