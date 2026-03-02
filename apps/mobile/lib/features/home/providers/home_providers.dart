import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/connectivity_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/sync_queue.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/category_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/category_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/offline_aware_category_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/offline_aware_recipe_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/recipe_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/recipe_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/meal_plan_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/repositories/category_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/repositories/meal_plan_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/repositories/recipe_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/services/sync_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/repositories/category_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/repositories/meal_plan_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/repositories/recipe_repository.dart';

// ---------------------------------------------------------------------------
// Core infrastructure
// ---------------------------------------------------------------------------

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(Connectivity());
});

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue();
});

// ---------------------------------------------------------------------------
// Local (Hive) data sources
// ---------------------------------------------------------------------------

final recipeLocalDataSourceProvider = Provider<RecipeLocalDataSource>((ref) {
  return RecipeLocalDataSourceImpl(ref.watch(syncQueueProvider));
});

final categoryLocalDataSourceProvider =
    Provider<CategoryLocalDataSource>((ref) {
  return CategoryLocalDataSourceImpl(ref.watch(syncQueueProvider));
});

// ---------------------------------------------------------------------------
// Remote (HTTP) data sources
// ---------------------------------------------------------------------------

final recipeRemoteOnlyDataSourceProvider =
    Provider<RecipeRemoteDataSource>((ref) {
  return RecipeRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final categoryRemoteOnlyDataSourceProvider =
    Provider<CategoryRemoteDataSource>((ref) {
  return CategoryRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

// ---------------------------------------------------------------------------
// Offline-aware adapters (what the repositories actually use)
// ---------------------------------------------------------------------------

final categoryRemoteDataSourceProvider =
    Provider<CategoryRemoteDataSource>((ref) {
  return OfflineAwareCategoryDataSource(
    remote: ref.watch(categoryRemoteOnlyDataSourceProvider),
    local: ref.watch(categoryLocalDataSourceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

final recipeRemoteDataSourceProvider = Provider<RecipeRemoteDataSource>((ref) {
  return OfflineAwareRecipeDataSource(
    remote: ref.watch(recipeRemoteOnlyDataSourceProvider),
    local: ref.watch(recipeLocalDataSourceProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Repositories (unchanged — depend only on the abstract data source interface)
// ---------------------------------------------------------------------------

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryRemoteDataSourceProvider));
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl(ref.watch(recipeRemoteDataSourceProvider));
});

// ---------------------------------------------------------------------------
// Meal plan data source and repository
// ---------------------------------------------------------------------------

final mealPlanRemoteDataSourceProvider =
    Provider<MealPlanRemoteDataSource>((ref) {
  return MealPlanRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return MealPlanRepositoryImpl(ref.watch(mealPlanRemoteDataSourceProvider));
});

// ---------------------------------------------------------------------------
// Sync service
// ---------------------------------------------------------------------------

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    remoteRecipe: ref.watch(recipeRemoteOnlyDataSourceProvider),
    localRecipe: ref.watch(recipeLocalDataSourceProvider),
    remoteCategory: ref.watch(categoryRemoteOnlyDataSourceProvider),
    localCategory: ref.watch(categoryLocalDataSourceProvider),
    syncQueue: ref.watch(syncQueueProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

/// Listens to connectivity changes and triggers [SyncService.syncPending]
/// whenever the device comes back online.
///
/// This provider must be watched by at least one active widget to stay alive.
/// [RecipesNotifier] watches it automatically when the recipes screen is open.
final syncListenerProvider = Provider<void>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  final syncService = ref.watch(syncServiceProvider);

  final subscription = connectivity.onConnectivityChanged.listen((isOnline) {
    if (isOnline) {
      syncService.syncPending();
    }
  });

  ref.onDispose(subscription.cancel);
});
