import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories({int page = 1, int itemsPerPage = 50});
  Future<CategoryModel> getCategory(String id);
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? emoji,
    String? color,
  });
  Future<CategoryModel> updateCategory(
    String id, {
    String? name,
    String? description,
    String? emoji,
    String? color,
    int? displayOrder,
  });
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  CategoryRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<CategoryModel>> getCategories({
    int page = 1,
    int itemsPerPage = 50,
  }) async {
    final result = await _apiClient.get(
      '/api/v1/categories',
      queryParameters: {'page': page, 'items_per_page': itemsPerPage},
    );
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) {
        final map = data as Map<String, dynamic>?;
        final list = map?['data'] as List<dynamic>?;
        if (list == null) return [];
        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => CategoryModel.fromJson(e))
            .toList();
      },
    );
  }

  @override
  Future<CategoryModel> getCategory(String id) async {
    final result = await _apiClient.get('/api/v1/categories/$id');
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) => CategoryModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? emoji,
    String? color,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
      if (emoji != null && emoji.isNotEmpty) 'emoji': emoji,
      if (color != null && color.isNotEmpty) 'color': color,
    };
    final result = await _apiClient.post('/api/v1/categories', data: body);
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) => CategoryModel.fromJson(data as Map<String, dynamic>),
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
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
      if (displayOrder != null) 'display_order': displayOrder,
    };
    final result = await _apiClient.patch('/api/v1/categories/$id', data: body);
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) => CategoryModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final result = await _apiClient.delete('/api/v1/categories/$id');
    result.fold(
      (failure) => throw ServerException(message: failure.message),
      (_) => null,
    );
  }
}
