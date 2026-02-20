import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Simple recipe model for in-memory storage (until backend exists).
class RecipeItem {
  const RecipeItem({
    required this.id,
    required this.title,
    required this.category,
    this.imagePath,
    this.motCle,
    this.ingredients,
    this.steps,
  });

  final String id;
  final String title;
  final String category;
  final String? imagePath;
  final String? motCle;
  final List<String>? ingredients;
  final List<String>? steps;

  RecipeItem copyWith({
    String? id,
    String? title,
    String? category,
    String? imagePath,
    String? motCle,
    List<String>? ingredients,
    List<String>? steps,
  }) {
    return RecipeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      motCle: motCle ?? this.motCle,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
    );
  }
}

class RecipesNotifier extends Notifier<List<RecipeItem>> {
  @override
  List<RecipeItem> build() => [];

  void addRecipe(RecipeItem recipe) {
    state = [...state, recipe];
  }

  void removeRecipe(String id) {
    state = state.where((r) => r.id != id).toList();
  }
}

final recipesProvider = NotifierProvider<RecipesNotifier, List<RecipeItem>>(RecipesNotifier.new);

/// Count of recipes per category.
int recipeCountForCategory(List<RecipeItem> recipes, String category) {
  return recipes.where((r) => r.category == category).length;
}

/// Create a new recipe with a generated id.
RecipeItem createRecipe({
  required String title,
  required String category,
  String? imagePath,
  String? motCle,
  List<String>? ingredients,
  List<String>? steps,
}) {
  return RecipeItem(
    id: const Uuid().v4(),
    title: title,
    category: category,
    imagePath: imagePath,
    motCle: motCle,
    ingredients: ingredients,
    steps: steps,
  );
}
