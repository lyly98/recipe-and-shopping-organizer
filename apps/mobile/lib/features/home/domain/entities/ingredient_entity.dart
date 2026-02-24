import 'package:equatable/equatable.dart';

class IngredientEntity extends Equatable {
  const IngredientEntity({
    required this.id,
    required this.recipeId,
    required this.name,
    required this.quantity,
    this.unit,
    this.displayOrder = 0,
  });

  final String id;
  final String recipeId;
  final String name;
  final String quantity;
  final String? unit;
  final int displayOrder;

  @override
  List<Object?> get props => [id, recipeId, name, quantity, unit, displayOrder];
}
