import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/category_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/categories_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/recipes_provider.dart';
import 'package:go_router/go_router.dart';

/// Screen to add and delete recipe categories (backend-backed).
class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  static const _defaultEmojis = [
    // Repas & plats
    '🍽️', '🍲', '🥘', '🍛', '🍜', '🍝', '🥗', '🫕',
    // Boulangerie & petit-déj
    '🍞', '🥐', '🥖', '🧇', '🥞', '🍳',
    // Desserts & snacks
    '🍰', '🎂', '🍮', '🍩', '🍪', '🍫', '🍿', '🧁',
    // Fruits & légumes
    '🥦', '🥕', '🍅', '🫑', '🧅', '🧄', '🥑', '🍋',
    // Viandes & poissons
    '🥩', '🍗', '🍖', '🦐', '🐟', '🦞',
    // Boissons
    '☕', '🍵', '🥤', '🧃', '🍹', '🍷', '🧋',
    // Cuisine du monde
    '🌮', '🌯', '🍕', '🍔', '🥪', '🥙', '🫔',
    // Divers
    '🧑‍🍳', '📁', '⭐', '❤️', '🌿', '🫙',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final recipesAsync = ref.watch(recipesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppPalette.darkPastelBackground : AppPalette.cream;
    final surface = isDark ? AppPalette.darkPastelSurface : AppPalette.white;
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final onMuted = isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'Gérer les catégories',
          style: TextStyle(fontWeight: FontWeight.w600, color: onBg, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onBg),
          onPressed: () => context.pop(),
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Aucune catégorie. Ajoutez-en une avec le bouton ci-dessous.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: onMuted),
                ),
              ),
            );
          }
          final recipes = recipesAsync.value ?? [];
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final count = recipeCountForCategory(recipes, cat.id);
              final cardLight = categoryLightColor(index);
              final cardDark = categoryDarkColor(index);
              final cardBg = isDark ? cardDark : cardLight;
              return Material(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                elevation: isDark ? 0 : 2,
                shadowColor: Colors.black12,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Text(cat.emoji ?? '📁', style: const TextStyle(fontSize: 32)),
                  title: Text(
                    cat.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray,
                    ),
                  ),
                  subtitle: count > 0
                      ? Text(
                          '$count recette${count > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: (isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray)
                                .withValues(alpha: 0.8),
                          ),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: isDark ? AppPalette.darkPastelPrimaryBlue : AppPalette.primaryBlue,
                        ),
                        onPressed: () => _showEditCategoryDialog(context, ref, cat, isDark, surface, onBg, onMuted),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                        onPressed: () => _confirmDelete(context, ref, cat, count, isDark, categories),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(err.toString(), textAlign: TextAlign.center, style: TextStyle(color: onBg)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.read(categoriesProvider.notifier).load(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context, ref, isDark, surface, onBg, onMuted),
        backgroundColor: isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange,
        foregroundColor: AppPalette.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter une catégorie'),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity cat,
    int recipeCount,
    bool isDark,
    List<CategoryEntity> categories,
  ) {
    final others = categories.where((c) => c.id != cat.id).toList();
    final message = recipeCount > 0
        ? '« ${cat.name} » contient $recipeCount recette(s). Elles seront déplacées vers la première catégorie. Supprimer quand même ?'
        : 'Supprimer la catégorie « ${cat.name} » ?';
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppPalette.darkPastelSurface : AppPalette.white,
        title: Text(
          'Supprimer la catégorie',
          style: TextStyle(color: isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray),
        ),
        content: Text(
          message,
          style: TextStyle(color: isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Annuler', style: TextStyle(color: isDark ? AppPalette.darkPastelPrimaryBlue : AppPalette.primaryBlue)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      if (others.isNotEmpty && recipeCount > 0) {
        await ref.read(recipesProvider.notifier).reassignCategory(cat.id, others.first.id);
      }
      final err = await ref.read(categoriesProvider.notifier).removeCategory(cat.id);
      if (context.mounted && err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    });
  }

  void _showEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity cat,
    bool isDark,
    Color surface,
    Color onBg,
    Color onMuted,
  ) {
    final nameController = TextEditingController(text: cat.name);
    String selectedEmoji = cat.emoji ?? _defaultEmojis.first;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: surface,
          title: Text(
            'Modifier la catégorie',
            style: TextStyle(color: onBg, fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    labelStyle: TextStyle(color: onMuted),
                    filled: true,
                    fillColor: isDark ? AppPalette.darkPastelBackground : AppPalette.lightGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: onBg),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                Text(
                  'Emoji',
                  style: TextStyle(fontSize: 14, color: onMuted, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _defaultEmojis.map((emoji) {
                    final selected = selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () => setState(() => selectedEmoji = emoji),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? (isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange)
                              : (isDark ? AppPalette.darkPastelBorder : AppPalette.lightGray),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Annuler', style: TextStyle(color: onMuted)),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final err = await ref
                    .read(categoriesProvider.notifier)
                    .updateCategory(cat.id, name, selectedEmoji);
                if (!ctx.mounted) return;
                if (err != null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(err)));
                  return;
                }
                Navigator.of(ctx).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange,
                foregroundColor: AppPalette.white,
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    Color surface,
    Color onBg,
    Color onMuted,
  ) {
    final nameController = TextEditingController();
    String selectedEmoji = _defaultEmojis.first;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: surface,
          title: Text(
            'Nouvelle catégorie',
            style: TextStyle(color: onBg, fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    hintText: 'ex. Entrées',
                    labelStyle: TextStyle(color: onMuted),
                    filled: true,
                    fillColor: isDark ? AppPalette.darkPastelBackground : AppPalette.lightGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: onBg),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                Text(
                  'Emoji',
                  style: TextStyle(fontSize: 14, color: onMuted, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _defaultEmojis.map((emoji) {
                    final selected = selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () => setState(() => selectedEmoji = emoji),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? (isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange)
                              : (isDark ? AppPalette.darkPastelBorder : AppPalette.lightGray),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Annuler', style: TextStyle(color: onMuted)),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final err = await ref.read(categoriesProvider.notifier).addCategory(name, selectedEmoji);
                if (!ctx.mounted) return;
                if (err != null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(err)));
                  return;
                }
                Navigator.of(ctx).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange,
                foregroundColor: AppPalette.white,
              ),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
