import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  /// Fetch categories (paginated). Returns list and total count.
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    int page = 1,
    int itemsPerPage = 50,
  });

  /// Get a single category by id.
  Future<Either<Failure, CategoryEntity>> getCategory(String id);

  /// Create a category (authenticated).
  Future<Either<Failure, CategoryEntity>> createCategory({
    required String name,
    String? description,
    String? emoji,
    String? color,
  });

  /// Update a category (authenticated).
  Future<Either<Failure, CategoryEntity>> updateCategory(
    String id, {
    String? name,
    String? description,
    String? emoji,
    String? color,
    int? displayOrder,
  });

  /// Delete a category (superuser only on backend; may return failure for normal users).
  Future<Either<Failure, void>> deleteCategory(String id);
}
