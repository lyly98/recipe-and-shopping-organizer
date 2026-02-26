import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/recipe_entity.dart';

class MealPlanEntryEntity extends Equatable {
  const MealPlanEntryEntity({
    required this.id,
    required this.planDate,
    required this.slotIndex,
    required this.recipe,
  });

  final String id;
  final DateTime planDate;
  final int slotIndex;
  final RecipeEntity recipe;

  @override
  List<Object?> get props => [id, planDate, slotIndex, recipe];
}
