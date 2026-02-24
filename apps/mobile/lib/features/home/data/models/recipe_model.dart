import 'package:flutter_riverpod_clean_architecture/features/home/data/models/ingredient_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/preparation_step_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/recipe_entity.dart';

class RecipeModel {
  const RecipeModel({
    required this.id,
    required this.userId,
    required this.title,
    this.categoryId,
    this.mealUsage,
    this.prepTimeMinutes = 0,
    this.cookTimeMinutes = 0,
    this.servings = 1,
    this.isFavorite = false,
    this.isPublic = false,
    this.imageUrls,
    this.tags,
    this.viewCount = 0,
    this.createdAt,
    this.updatedAt,
    this.ingredients = const [],
    this.preparationSteps = const [],
  });

  final String id;
  final String userId;
  final String title;
  final String? categoryId;
  final String? mealUsage;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final bool isFavorite;
  final bool isPublic;
  final List<String>? imageUrls;
  final List<String>? tags;
  final int viewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<IngredientModel> ingredients;
  final List<PreparationStepModel> preparationSteps;

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final ingredientsList = json['ingredients'] as List<dynamic>?;
    final stepsList = json['preparation_steps'] as List<dynamic>?;
    return RecipeModel(
      id: _stringFromDynamic(json['id']),
      userId: _stringFromDynamic(json['user_id']),
      title: (json['title'] as String?) ?? '',
      categoryId: _stringFromDynamic(json['category_id']).isEmpty ? null : _stringFromDynamic(json['category_id']),
      mealUsage: json['meal_usage'] as String?,
      prepTimeMinutes: (json['prep_time_minutes'] as num?)?.toInt() ?? 0,
      cookTimeMinutes: (json['cook_time_minutes'] as num?)?.toInt() ?? 0,
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      isFavorite: (json['is_favorite'] as bool?) ?? false,
      isPublic: (json['is_public'] as bool?) ?? false,
      imageUrls: (json['image_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      createdAt: _dateFromDynamic(json['created_at']),
      updatedAt: _dateFromDynamic(json['updated_at']),
      ingredients: ingredientsList != null
          ? ingredientsList
              .whereType<Map<String, dynamic>>()
              .map((e) => IngredientModel.fromJson(e))
              .toList()
          : [],
      preparationSteps: stepsList != null
          ? stepsList
              .whereType<Map<String, dynamic>>()
              .map((e) => PreparationStepModel.fromJson(e))
              .toList()
          : [],
    );
  }

  static String _stringFromDynamic(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  static DateTime? _dateFromDynamic(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  Map<String, dynamic> toCreateJson() => {
        'title': title,
        'category_id': categoryId,
        'meal_usage': mealUsage,
        'prep_time_minutes': prepTimeMinutes,
        'cook_time_minutes': cookTimeMinutes,
        'servings': servings,
        'is_favorite': isFavorite,
        'is_public': isPublic,
        'image_urls': imageUrls,
        'tags': tags,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'preparation_steps': preparationSteps.map((e) => e.toJson()).toList(),
      };

  RecipeEntity toEntity() => RecipeEntity(
        id: id,
        userId: userId,
        title: title,
        categoryId: categoryId,
        mealUsage: mealUsage,
        prepTimeMinutes: prepTimeMinutes,
        cookTimeMinutes: cookTimeMinutes,
        servings: servings,
        isFavorite: isFavorite,
        isPublic: isPublic,
        imageUrls: imageUrls,
        tags: tags,
        viewCount: viewCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
        ingredients: ingredients.map((e) => e.toEntity()).toList(),
        preparationSteps: preparationSteps.map((e) => e.toEntity()).toList(),
      );
}
