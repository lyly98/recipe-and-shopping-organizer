import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/meal_plan_entry_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/recipe_entity.dart';

/// Light recipe embedded in a meal plan API response.
class RecipeLightModel {
  const RecipeLightModel({
    required this.id,
    required this.title,
    required this.servings,
    this.imageUrls,
  });

  final String id;
  final String title;
  final int servings;
  final List<String>? imageUrls;

  factory RecipeLightModel.fromJson(Map<String, dynamic> json) =>
      RecipeLightModel(
        id: json['id'].toString(),
        title: (json['title'] as String?) ?? '',
        servings: (json['servings'] as num?)?.toInt() ?? 1,
        imageUrls: (json['image_urls'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
      );

  RecipeEntity toEntity() => RecipeEntity(
        id: id,
        userId: '',
        title: title,
        servings: servings,
        imageUrls: imageUrls,
      );
}

class MealPlanEntryModel {
  const MealPlanEntryModel({
    required this.id,
    required this.planDate,
    required this.slotIndex,
    required this.recipe,
  });

  final String id;
  final DateTime planDate;
  final int slotIndex;
  final RecipeLightModel recipe;

  factory MealPlanEntryModel.fromJson(Map<String, dynamic> json) =>
      MealPlanEntryModel(
        id: json['id'].toString(),
        planDate: DateTime.parse(json['plan_date'] as String),
        slotIndex: (json['slot_index'] as num).toInt(),
        recipe: RecipeLightModel.fromJson(
            json['recipe'] as Map<String, dynamic>),
      );

  MealPlanEntryEntity toEntity() => MealPlanEntryEntity(
        id: id,
        planDate: planDate,
        slotIndex: slotIndex,
        recipe: recipe.toEntity(),
      );
}
