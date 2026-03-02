import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/meal_plan_entry_model.dart';
import 'package:intl/intl.dart';

abstract class MealPlanRemoteDataSource {
  Future<List<MealPlanEntryModel>> getMealPlan({
    required DateTime start,
    required DateTime end,
  });

  Future<MealPlanEntryModel> addEntry({
    required DateTime date,
    required int slotIndex,
    required String recipeId,
  });

  Future<void> removeEntry(String entryId);
}

class MealPlanRemoteDataSourceImpl implements MealPlanRemoteDataSource {
  MealPlanRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;
  final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  Future<List<MealPlanEntryModel>> getMealPlan({
    required DateTime start,
    required DateTime end,
  }) async {
    final result = await _apiClient.get(
      '/api/v1/meal-plan',
      queryParameters: {
        'start_date': _dateFmt.format(start),
        'end_date': _dateFmt.format(end),
      },
    );
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) {
        final list = data as List<dynamic>?;
        if (list == null) return [];
        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => MealPlanEntryModel.fromJson(e))
            .toList();
      },
    );
  }

  @override
  Future<MealPlanEntryModel> addEntry({
    required DateTime date,
    required int slotIndex,
    required String recipeId,
  }) async {
    final result = await _apiClient.post(
      '/api/v1/meal-plan',
      data: {
        'plan_date': _dateFmt.format(date),
        'slot_index': slotIndex,
        'recipe_id': recipeId,
      },
    );
    return result.fold(
      (failure) => throw ServerException(message: failure.message),
      (data) => MealPlanEntryModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<void> removeEntry(String entryId) async {
    final result = await _apiClient.delete('/api/v1/meal-plan/$entryId');
    result.fold(
      (failure) => throw ServerException(message: failure.message),
      (_) => null,
    );
  }
}
