import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/ingredient_entity.dart';

class IngredientModel {
  const IngredientModel({
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

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: _stringFromDynamic(json['id']),
      recipeId: _stringFromDynamic(json['recipe_id']),
      name: (json['name'] as String?) ?? '',
      quantity: (json['quantity'] as String?) ?? '',
      unit: json['unit'] as String?,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
    );
  }

  static String _stringFromDynamic(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'display_order': displayOrder,
      };

  IngredientEntity toEntity() => IngredientEntity(
        id: id,
        recipeId: recipeId,
        name: name,
        quantity: quantity,
        unit: unit,
        displayOrder: displayOrder,
      );
}
