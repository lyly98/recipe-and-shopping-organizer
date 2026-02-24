import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/ingredient_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/preparation_step_entity.dart';

class RecipeEntity extends Equatable {
  const RecipeEntity({
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
  final List<IngredientEntity> ingredients;
  final List<PreparationStepEntity> preparationSteps;

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        categoryId,
        mealUsage,
        prepTimeMinutes,
        cookTimeMinutes,
        servings,
        isFavorite,
        isPublic,
        imageUrls,
        tags,
        viewCount,
        createdAt,
        updatedAt,
        ingredients,
        preparationSteps,
      ];
}
