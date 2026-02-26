import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/connectivity_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/sync_queue.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/logger.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/category_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/category_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/recipe_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/recipe_remote_data_source.dart';

/// Replays queued offline operations against the remote API when connectivity
/// is restored.
///
/// Call [syncPending] after detecting connectivity. The service is guarded
/// against concurrent runs and stops immediately on [UnauthorizedException]
/// (expired token) so the caller can redirect to login.
class SyncService {
  SyncService({
    required RecipeRemoteDataSource remoteRecipe,
    required RecipeLocalDataSource localRecipe,
    required CategoryRemoteDataSource remoteCategory,
    required CategoryLocalDataSource localCategory,
    required SyncQueue syncQueue,
    required ConnectivityService connectivity,
  })  : _remoteRecipe = remoteRecipe,
        _localRecipe = localRecipe,
        _remoteCategory = remoteCategory,
        _localCategory = localCategory,
        _syncQueue = syncQueue,
        _connectivity = connectivity;

  final RecipeRemoteDataSource _remoteRecipe;
  final RecipeLocalDataSource _localRecipe;
  final CategoryRemoteDataSource _remoteCategory;
  final CategoryLocalDataSource _localCategory;
  final SyncQueue _syncQueue;
  final ConnectivityService _connectivity;

  bool _isSyncing = false;

  /// Whether there is anything waiting to be synced.
  bool get hasPendingOps => !_syncQueue.isEmpty;

  /// Attempts to flush all queued operations to the remote API in order.
  ///
  /// Returns `true` if the queue is fully drained, `false` if at least one op
  /// was skipped due to a transient error (will be retried on next call).
  ///
  /// Throws [UnauthorizedException] if the token has expired so the caller can
  /// trigger re-authentication.
  Future<bool> syncPending() async {
    if (_isSyncing) return false;
    if (_syncQueue.isEmpty) return true;
    if (!await _connectivity.isOnline) return false;

    _isSyncing = true;
    bool fullyDrained = true;

    // In-memory map that resolves temporary 'local_…' IDs to real server IDs
    // within a single sync run.
    final localToServer = <String, String>{};

    Logger.info(
      'SyncService: starting sync — ${_syncQueue.length} ops pending',
    );

    try {
      final ops = _syncQueue.getAll();

      for (final op in ops) {
        // Resolve the entity ID in case a prior create in this same run already
        // mapped the local ID to a real server ID.
        final resolvedId = localToServer[op.entityId] ?? op.entityId;

        try {
          if (op.type == 'recipe') {
            await _syncRecipeOp(op, resolvedId, localToServer);
          } else if (op.type == 'category') {
            await _syncCategoryOp(op, resolvedId, localToServer);
          }
          await _syncQueue.remove(op.id);
        } on UnauthorizedException {
          // Expired token: stop everything, caller must re-authenticate.
          Logger.warning(
            'SyncService: unauthorized — stopping sync, queue intact',
          );
          rethrow;
        } catch (e, st) {
          fullyDrained = false;
          Logger.error(
            'SyncService: failed to sync op ${op.id} '
            '(${op.type}/${op.operation}/$resolvedId)',
            e,
            st,
          );
          // Leave op in queue for the next retry.
        }
      }
    } finally {
      _isSyncing = false;
      Logger.info(
        'SyncService: sync finished — '
        '${_syncQueue.length} ops remaining',
      );
    }

    return fullyDrained;
  }

  // ---------------------------------------------------------------------------
  // Recipe sync
  // ---------------------------------------------------------------------------

  Future<void> _syncRecipeOp(
    SyncOperation op,
    String entityId,
    Map<String, String> localToServer,
  ) async {
    switch (op.operation) {
      case 'create':
        final payload = await _resolveImageUrls(
          Map<String, dynamic>.from(op.payload),
        );
        final serverModel = await _remoteRecipe.createRecipe(payload);

        // Persist: remove local entry, store server entry
        await _localRecipe.replaceLocalId(op.entityId, serverModel);

        // Update the in-memory map AND the persisted queue so a restart after a
        // partial sync will still work correctly.
        localToServer[op.entityId] = serverModel.id;
        await _syncQueue.replaceEntityId(op.entityId, serverModel.id);

        Logger.info(
          'SyncService: recipe created ${op.entityId} → ${serverModel.id}',
        );

      case 'update':
        // If the entity is still a local ID, its create op either failed or
        // hasn't run yet (unusual ordering). Skip and let create handle it.
        if (entityId.startsWith('local_')) {
          Logger.info(
            'SyncService: skipping update for unresolved local recipe $entityId',
          );
          return;
        }
        await _remoteRecipe.updateRecipe(entityId, op.payload);
        Logger.info('SyncService: recipe updated $entityId');

      case 'delete':
        if (entityId.startsWith('local_')) {
          // Was never on the server — nothing to delete remotely.
          Logger.info(
            'SyncService: skipping delete for local-only recipe $entityId',
          );
          return;
        }
        await _remoteRecipe.deleteRecipe(entityId);
        Logger.info('SyncService: recipe deleted $entityId');
    }
  }

  // ---------------------------------------------------------------------------
  // Category sync
  // ---------------------------------------------------------------------------

  Future<void> _syncCategoryOp(
    SyncOperation op,
    String entityId,
    Map<String, String> localToServer,
  ) async {
    switch (op.operation) {
      case 'create':
        final p = op.payload;
        final serverModel = await _remoteCategory.createCategory(
          name: p['name'] as String,
          description: p['description'] as String?,
          emoji: p['emoji'] as String?,
          color: p['color'] as String?,
        );

        await _localCategory.replaceLocalId(op.entityId, serverModel);

        localToServer[op.entityId] = serverModel.id;
        await _syncQueue.replaceEntityId(op.entityId, serverModel.id);

        Logger.info(
          'SyncService: category created ${op.entityId} → ${serverModel.id}',
        );

      case 'update':
        if (entityId.startsWith('local_')) {
          Logger.info(
            'SyncService: skipping update for unresolved local category $entityId',
          );
          return;
        }
        final p = op.payload;
        await _remoteCategory.updateCategory(
          entityId,
          name: p['name'] as String?,
          description: p['description'] as String?,
          emoji: p['emoji'] as String?,
          color: p['color'] as String?,
          displayOrder: p['display_order'] as int?,
        );
        Logger.info('SyncService: category updated $entityId');

      case 'delete':
        if (entityId.startsWith('local_')) {
          Logger.info(
            'SyncService: skipping delete for local-only category $entityId',
          );
          return;
        }
        await _remoteCategory.deleteCategory(entityId);
        Logger.info('SyncService: category deleted $entityId');
    }
  }

  // ---------------------------------------------------------------------------
  // Image URL resolution
  // ---------------------------------------------------------------------------

  /// If a create payload contains local file paths in `image_urls`, uploads
  /// them to the remote storage and replaces the paths with real URLs.
  Future<Map<String, dynamic>> _resolveImageUrls(
    Map<String, dynamic> payload,
  ) async {
    final imageUrls = payload['image_urls'];
    if (imageUrls == null) return payload;

    final rawList = imageUrls as List<dynamic>;
    final resolvedUrls = <String>[];

    for (final url in rawList) {
      final urlStr = url.toString();
      if (_isLocalPath(urlStr)) {
        try {
          final remoteUrl = await _remoteRecipe.uploadRecipeImage(urlStr);
          resolvedUrls.add(remoteUrl);
          Logger.info('SyncService: uploaded image $urlStr → $remoteUrl');
        } catch (e) {
          Logger.error('SyncService: failed to upload image $urlStr', e);
          // Keep the local path in payload so we can retry later.
          resolvedUrls.add(urlStr);
        }
      } else {
        resolvedUrls.add(urlStr);
      }
    }

    return {...payload, 'image_urls': resolvedUrls};
  }

  bool _isLocalPath(String url) {
    return url.startsWith('/') ||
        url.startsWith('file://') ||
        (!url.startsWith('http://') && !url.startsWith('https://'));
  }
}
