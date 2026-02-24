import 'package:equatable/equatable.dart';

class PreparationStepEntity extends Equatable {
  const PreparationStepEntity({
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

  @override
  List<Object?> get props => [id, recipeId, stepNumber, instruction, durationMinutes];
}
