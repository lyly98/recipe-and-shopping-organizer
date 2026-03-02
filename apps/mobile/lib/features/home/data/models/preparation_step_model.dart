import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/preparation_step_entity.dart';

class PreparationStepModel {
  const PreparationStepModel({
    required this.id,
    required this.recipeId,
    required this.stepNumber,
    required this.instruction,
    this.durationMinutes,
  });

  final String id;
  final String recipeId;
  final int stepNumber;
  final String instruction;
  final int? durationMinutes;

  factory PreparationStepModel.fromJson(Map<String, dynamic> json) {
    return PreparationStepModel(
      id: _stringFromDynamic(json['id']),
      recipeId: _stringFromDynamic(json['recipe_id']),
      stepNumber: (json['step_number'] as num?)?.toInt() ?? 1,
      instruction: (json['instruction'] as String?) ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
    );
  }

  static String _stringFromDynamic(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  Map<String, dynamic> toJson() => {
        'step_number': stepNumber,
        'instruction': instruction,
        'duration_minutes': durationMinutes,
      };

  PreparationStepEntity toEntity() => PreparationStepEntity(
        id: id,
        recipeId: recipeId,
        stepNumber: stepNumber,
        instruction: instruction,
        durationMinutes: durationMinutes,
      );
}
