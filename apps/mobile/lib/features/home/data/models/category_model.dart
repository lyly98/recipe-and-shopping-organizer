import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/category_entity.dart';

class CategoryModel {
  const CategoryModel({
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

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _stringFromDynamic(json['id']),
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      emoji: json['emoji'] as String?,
      color: json['color'] as String?,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      userId: _stringFromDynamic(json['user_id']),
      createdAt: _dateFromDynamic(json['created_at']),
      updatedAt: _dateFromDynamic(json['updated_at']),
    );
  }

  static String _stringFromDynamic(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  static DateTime? _dateFromDynamic(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'emoji': emoji,
        'color': color,
        'display_order': displayOrder,
        'user_id': userId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        name: name,
        description: description,
        emoji: emoji,
        color: color,
        displayOrder: displayOrder,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
