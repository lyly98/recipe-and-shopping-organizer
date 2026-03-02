import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    this.description,
    this.emoji,
    this.color,
    this.displayOrder = 0,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? emoji;
  final String? color;
  final int displayOrder;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, name, description, emoji, color, displayOrder, userId, createdAt, updatedAt];

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    String? color,
    int? displayOrder,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      displayOrder: displayOrder ?? this.displayOrder,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
