import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/category_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/providers/home_providers.dart';

/// Light and dark background colors for category cards (by index).
const List<(Color light, Color dark)> _categoryColors = [
  (AppPalette.categoryPlats, AppPalette.darkPastelCategoryPlats),
  (AppPalette.categoryPains, AppPalette.darkPastelCategoryPains),
  (AppPalette.categoryDesserts, AppPalette.darkPastelCategoryDesserts),
  (AppPalette.categoryJus, AppPalette.darkPastelCategoryJus),
  (AppPalette.categorySnacks, AppPalette.darkPastelCategorySnacks),
  (AppPalette.categorySoupes, AppPalette.darkPastelCategorySoupes),
];

Color categoryLightColor(int index) =>
    _categoryColors[index % _categoryColors.length].$1;
Color categoryDarkColor(int index) =>
    _categoryColors[index % _categoryColors.length].$2;

class CategoriesNotifier extends AsyncNotifier<List<CategoryEntity>> {
  @override
  Future<List<CategoryEntity>> build() async {
    return _load();
  }

  Future<List<CategoryEntity>> _load() async {
    final repo = ref.read(categoryRepositoryProvider);
    final result = await repo.getCategories(page: 1, itemsPerPage: 100);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (list) => list,
    );
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<String?> addCategory(String name, String emoji) async {
    final repo = ref.read(categoryRepositoryProvider);
    final result = await repo.createCategory(
      name: name.trim(),
      emoji: emoji.trim().isEmpty ? null : emoji.trim(),
    );
    return result.fold(
      (failure) => failure.message,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }

  Future<String?> removeCategory(String id) async {
    final repo = ref.read(categoryRepositoryProvider);
    final result = await repo.deleteCategory(id);
    return result.fold(
      (failure) => failure.message,
      (_) {
        ref.invalidateSelf();
        return null;
      },
    );
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<CategoryEntity>>(
  CategoriesNotifier.new,
);

/// Legacy [CategoryItem]-style access: id, name, emoji for UI that expects it.
class CategoryItem {
  const CategoryItem({required this.id, required this.name, required this.emoji});
  final String id;
  final String name;
  final String emoji;
}

List<CategoryItem> categoriesToItems(List<CategoryEntity> list) {
  return list
      .map((e) => CategoryItem(
            id: e.id,
            name: e.name,
            emoji: e.emoji ?? '📁',
          ))
      .toList();
}
