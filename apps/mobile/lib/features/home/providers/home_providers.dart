import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/category_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/recipe_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/repositories/category_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/repositories/recipe_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/repositories/category_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/repositories/recipe_repository.dart';

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((ref) {
  return CategoryRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryRemoteDataSourceProvider));
});

final recipeRemoteDataSourceProvider = Provider<RecipeRemoteDataSource>((ref) {
  return RecipeRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl(ref.watch(recipeRemoteDataSourceProvider));
});
