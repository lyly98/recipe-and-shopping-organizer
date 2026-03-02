import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/sync_queue.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/logger.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/category_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/category_model.dart';

/// Extends [CategoryRemoteDataSource] with extra methods needed by the
/// offline adapter and the sync service.
abstract class CategoryLocalDataSource implements CategoryRemoteDataSource {
  Future<void> cacheCategory(CategoryModel category);
  Future<void> cacheCategories(List<CategoryModel> categories);

  /// Removes the entry keyed by [localId] and stores [serverModel] under its
  /// real server ID. Called by [SyncService] after a successful create sync.
  Future<void> replaceLocalId(String localId, CategoryModel serverModel);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  CategoryLocalDataSourceImpl(this._syncQueue);

  static const String _boxName = 'categories_cache';

  /// Exposed so [main.dart] can open the box before the provider is created.
  static const String boxNameForInit = _boxName;

  static const Uuid _uuid = Uuid();

  final SyncQueue _syncQueue;

  Box<String> get _box => Hive.box<String>(_boxName);

  // ---------------------------------------------------------------------------
  // CategoryRemoteDataSource — read
  // ---------------------------------------------------------------------------

  @override
  Future<List<CategoryModel>> getCategories({
    int page = 1,
    int itemsPerPage = 50,
  }) async {
    try {
      return _box.values
          .map((v) {
            try {
              return CategoryModel.fromJson(
                jsonDecode(v) as Map<String, dynamic>,
              );
            } catch (e) {
              Logger.error(
                'CategoryLocalDataSource: failed to parse category',
                e,
              );
              return null;
            }
          })
          .whereType<CategoryModel>()
          .toList();
    } catch (e) {
      Logger.error('CategoryLocalDataSource: getCategories failed', e);
      throw CacheException(message: 'Failed to read categories from cache: $e');
    }
  }

  @override
  Future<CategoryModel> getCategory(String id) async {
    final raw = _box.get(id);
    if (raw == null) {
      throw ServerException(message: 'Category $id not found in cache');
    }
    try {
      return CategoryModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException(message: 'Failed to parse cached category: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // CategoryRemoteDataSource — write (enqueues to SyncQueue)
  // ---------------------------------------------------------------------------

  @override
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? emoji,
    String? color,
  }) async {
    final localId = 'local_${_uuid.v4().replaceAll('-', '')}';
    final now = DateTime.now().toIso8601String();

    final categoryJson = <String, dynamic>{
      'id': localId,
      'name': name,
      'description': description,
      'emoji': emoji,
      'color': color,
      'display_order': 0,
      'user_id': '',
      'created_at': now,
      'updated_at': now,
    };

    await _box.put(localId, jsonEncode(categoryJson));

    await _syncQueue.enqueue(
      SyncOperation(
        id: _uuid.v4(),
        type: 'category',
        operation: 'create',
        entityId: localId,
        localId: localId,
        payload: {
          'name': name,
          'description': ?description,
          'emoji': ?emoji,
          'color': ?color,
        },
        createdAt: DateTime.now(),
      ),
    );

    Logger.info('CategoryLocalDataSource: created local category $localId');
    return CategoryModel.fromJson(categoryJson);
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
    final raw = _box.get(id);
    if (raw == null) {
      throw ServerException(message: 'Category $id not found in cache');
    }

    final existingJson =
        Map<String, dynamic>.from(jsonDecode(raw) as Map<String, dynamic>);

    if (name != null) existingJson['name'] = name;
    if (description != null) existingJson['description'] = description;
    if (emoji != null) existingJson['emoji'] = emoji;
    if (color != null) existingJson['color'] = color;
    if (displayOrder != null) existingJson['display_order'] = displayOrder;
    existingJson['updated_at'] = DateTime.now().toIso8601String();

    await _box.put(id, jsonEncode(existingJson));

    await _syncQueue.enqueue(
      SyncOperation(
        id: _uuid.v4(),
        type: 'category',
        operation: 'update',
        entityId: id,
        payload: {
          'name': ?name,
          'description': ?description,
          'emoji': ?emoji,
          'color': ?color,
          'display_order': ?displayOrder,
        },
        createdAt: DateTime.now(),
      ),
    );

    Logger.info('CategoryLocalDataSource: queued update for category $id');
    return CategoryModel.fromJson(existingJson);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _box.delete(id);

    await _syncQueue.enqueue(
      SyncOperation(
        id: _uuid.v4(),
        type: 'category',
        operation: 'delete',
        entityId: id,
        payload: const {},
        createdAt: DateTime.now(),
      ),
    );

    Logger.info('CategoryLocalDataSource: queued delete for category $id');
  }

  // ---------------------------------------------------------------------------
  // CategoryLocalDataSource — cache helpers
  // ---------------------------------------------------------------------------

  @override
  Future<void> cacheCategory(CategoryModel category) async {
    try {
      await _box.put(category.id, jsonEncode(category.toJson()));
    } catch (e) {
      Logger.error(
        'CategoryLocalDataSource: failed to cache category ${category.id}',
        e,
      );
    }
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    try {
      final entries = {
        for (final c in categories) c.id: jsonEncode(c.toJson()),
      };
      await _box.putAll(entries);
    } catch (e) {
      Logger.error('CategoryLocalDataSource: failed to cache categories', e);
    }
  }

  @override
  Future<void> replaceLocalId(
    String localId,
    CategoryModel serverModel,
  ) async {
    await _box.delete(localId);
    await cacheCategory(serverModel);
    Logger.info(
      'CategoryLocalDataSource: replaced $localId → ${serverModel.id}',
    );
  }
}
