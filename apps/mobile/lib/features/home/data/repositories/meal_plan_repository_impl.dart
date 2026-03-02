import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/meal_plan_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/meal_plan_entry_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/repositories/meal_plan_repository.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  MealPlanRepositoryImpl(this._remote);

  final MealPlanRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<MealPlanEntryEntity>>> getMealPlan({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final list = await _remote.getMealPlan(start: start, end: end);
      return Right(list.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MealPlanEntryEntity>> addEntry({
    required DateTime date,
    required int slotIndex,
    required String recipeId,
  }) async {
    try {
      final model = await _remote.addEntry(
        date: date,
        slotIndex: slotIndex,
        recipeId: recipeId,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeEntry(String entryId) async {
    try {
      await _remote.removeEntry(entryId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
