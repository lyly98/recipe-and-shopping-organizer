import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';

/// Card displaying a recipe category (e.g. Plats, Pains, Desserts) with emoji, name and count.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.count,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isDark,
    this.onTap,
  });

  final String emoji;
  final String name;
  final int count;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap ?? () => AppUtils.showSnackBar(context, message: 'Catégorie: $name'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: foregroundColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count recette${count > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: foregroundColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
