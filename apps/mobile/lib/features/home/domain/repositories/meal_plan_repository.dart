import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/meal_plan_entry_entity.dart';

abstract class MealPlanRepository {
  /// Fetch all meal plan entries for the current user within [start, end].
  Future<Either<Failure, List<MealPlanEntryEntity>>> getMealPlan({
    required DateTime start,
    required DateTime end,
  });

  /// Add a recipe to a specific date and slot.
  Future<Either<Failure, MealPlanEntryEntity>> addEntry({
    required DateTime date,
    required int slotIndex,
    required String recipeId,
  });

  /// Remove a meal plan entry by its id.
  Future<Either<Failure, void>> removeEntry(String entryId);
}
