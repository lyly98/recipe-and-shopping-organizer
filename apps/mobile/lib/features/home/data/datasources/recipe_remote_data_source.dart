import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  /// Uploads an image file and returns the full URL to use in recipe image_urls.
  Future<String> uploadRecipeImage(String filePath);

  Future<List<RecipeModel>> getMyRecipes({
    int page = 1,
    int itemsPerPage = 50,
    String? categoryId,
    bool favoritesOnly = false,
  });
  Future<RecipeModel> getRecipe(String id);
  Future<RecipeModel> createRecipe(Map<String, dynamic> body);
  Future<RecipeModel> updateRecipe(String id, Map<String, dynamic> body);
  Future<void> deleteRecipe(String id);
  Future<RecipeModel> toggleFavorite(String id);
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  RecipeRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<String> uploadRecipeImage(String filePath) async {
    final result = await _apiClient.postMultipart('/api/v1/upload/image', filePath: filePath);
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) {
        final map = data as Map<String, dynamic>?;
        final path = map?['url'] as String?;
        if (path == null || path.isEmpty) throw ServerException(message: 'No URL in upload response');
        final base = AppConstants.apiBaseUrl.replaceFirst(RegExp(r'/$'), '');
        return base + path;
      },
    );
  }

  @override
  Future<List<RecipeModel>> getMyRecipes({
    int page = 1,
    int itemsPerPage = 50,
    String? categoryId,
    bool favoritesOnly = false,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'items_per_page': itemsPerPage,
      'favorites_only': favoritesOnly,
      if (categoryId != null && categoryId.isNotEmpty) 'category_id': categoryId,
    };
    final result = await _apiClient.get('/api/v1/recipes/my', queryParameters: query);
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) {
        final map = data as Map<String, dynamic>?;
        final list = map?['data'] as List<dynamic>?;
        if (list == null) return [];
        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => RecipeModel.fromJson(e))
            .toList();
      },
    );
  }

  @override
  Future<RecipeModel> getRecipe(String id) async {
    final result = await _apiClient.get('/api/v1/recipes/$id');
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) => RecipeModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<RecipeModel> createRecipe(Map<String, dynamic> body) async {
    final result = await _apiClient.post('/api/v1/recipes', data: body);
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) => RecipeModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<RecipeModel> updateRecipe(String id, Map<String, dynamic> body) async {
    final result = await _apiClient.patch('/api/v1/recipes/$id', data: body);
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) => RecipeModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<void> deleteRecipe(String id) async {
    final result = await _apiClient.delete('/api/v1/recipes/$id');
    result.fold(
      (failure) => throw ServerException(message: failure.message),
      (_) => null,
    );
  }

  @override
  Future<RecipeModel> toggleFavorite(String id) async {
    final result = await _apiClient.post('/api/v1/recipes/$id/favorite');
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) => RecipeModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
