import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/categories_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Modal to create a new recipe. Sends create params to [onSave] for API.
class NewRecipeModal extends StatefulWidget {
  const NewRecipeModal({
    super.key,
    required this.isDark,
    required this.onSave,
    required this.categoryItems,
    this.uploadImage,
  });

  final bool isDark;
  final Future<String?> Function(Map<String, dynamic> params) onSave;
  final List<CategoryItem> categoryItems;
  /// If provided, called with the picked image path; returns URL to use in recipe or null on failure.
  final Future<String?> Function(String filePath)? uploadImage;

  /// Shows the modal and returns when dismissed. [onSave] returns null on success or error message.
  static Future<void> show(
    BuildContext context, {
    required bool isDark,
    required List<CategoryItem> categoryItems,
    required Future<String?> Function(Map<String, dynamic> params) onSave,
    Future<String?> Function(String filePath)? uploadImage,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewRecipeModal(
        isDark: isDark,
        onSave: onSave,
        categoryItems: categoryItems,
        uploadImage: uploadImage,
      ),
    );
  }

  @override
  State<NewRecipeModal> createState() => _NewRecipeModalState();
}

class _NewRecipeModalState extends State<NewRecipeModal> {
  final _titreController = TextEditingController();
  final _motCleController = TextEditingController();
  final _ingredientsControllers = <TextEditingController>[TextEditingController()];
  final _stepsControllers = <TextEditingController>[TextEditingController()];

  String? _selectedCategoryId;
  String? _imagePath;
  final _picker = ImagePicker();

  List<CategoryItem> get _categories => widget.categoryItems.isNotEmpty ? widget.categoryItems : [const CategoryItem(id: '', name: 'Plats', emoji: '🍽️')];

  @override
  void dispose() {
    _titreController.dispose();
    _motCleController.dispose();
    for (final c in _ingredientsControllers) {
      c.dispose();
    }
    for (final c in _stepsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredientsControllers.add(TextEditingController());
    });
  }

  void _addStep() {
    setState(() {
      _stepsControllers.add(TextEditingController());
    });
  }

  Future<void> _pickImage() async {
    try {
      final xFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (xFile == null || !mounted) return;
      try {
        final dir = await getApplicationDocumentsDirectory();
        final name = 'recipe_${DateTime.now().millisecondsSinceEpoch}${p.extension(xFile.path)}';
        final dest = File(p.join(dir.path, name));
        await File(xFile.path).copy(dest.path);
        if (mounted) setState(() => _imagePath = dest.path);
      } catch (_) {
        if (mounted) setState(() => _imagePath = xFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible d\'ouvrir la galerie. Redémarrez l\'app (pas de hot reload).',
            ),
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    final titre = _titreController.text.trim();
    if (titre.isEmpty) return;
    final categoryId = _selectedCategoryId ?? (_categories.isNotEmpty && _categories.first.id.isNotEmpty ? _categories.first.id : null);
    final ingredients = _ingredientsControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final steps = _stepsControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final ingredientMaps = ingredients.asMap().entries.map((e) => {
      'name': e.value,
      'quantity': '1',
      'unit': null,
      'display_order': e.key,
    }).toList();
    final stepMaps = steps.asMap().entries.map((e) => {
      'step_number': e.key + 1,
      'instruction': e.value,
      'duration_minutes': null,
    }).toList();

    List<String>? imageUrls;
    if (_imagePath != null && _imagePath!.trim().isNotEmpty && widget.uploadImage != null) {
      final url = await widget.uploadImage!(_imagePath!);
      if (url != null && url.isNotEmpty) imageUrls = [url];
    }

    final err = await widget.onSave({
      'title': titre,
      'categoryId': categoryId,
      'mealUsage': _motCleController.text.trim().isEmpty ? null : _motCleController.text.trim(),
      'imageUrls': imageUrls,
      'ingredients': ingredientMaps,
      'preparationSteps': stepMaps,
    });
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recette enregistrée')));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final orange = isDark ? AppPalette.darkPastelPrimaryOrange : AppPalette.primaryOrange;
    final pink = isDark ? AppPalette.darkPastelPrimaryPink : AppPalette.primaryPink;
    final surface = isDark ? AppPalette.darkPastelSurfaceElevated : AppPalette.white;
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Text(
                  'Nouvelle recette',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppPalette.white,
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLabel('Image'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: isDark ? AppPalette.darkPastelSurface : AppPalette.lightGray.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? AppPalette.darkPastelBorder : AppPalette.mediumGray.withValues(alpha: 0.5)),
                          ),
                          child: _imagePath != null && File(_imagePath!).existsSync()
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(_imagePath!), fit: BoxFit.cover, width: double.infinity),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined, size: 40, color: onBg.withValues(alpha: 0.5)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ajouter une image',
                                      style: TextStyle(fontSize: 13, color: onBg.withValues(alpha: 0.7)),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Titre'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _titreController,
                        decoration: _inputDecoration(context, isDark, 'Ex. Tarte aux pommes'),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Catégorie'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: _inputDecoration(context, isDark, null),
                        items: _categories
                            .where((c) => c.id.isNotEmpty)
                            .map((c) => DropdownMenuItem(value: c.id, child: Text('${c.emoji} ${c.name}')))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCategoryId = v),
                        hint: const Text('Choisir une catégorie'),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Mot-clé pour l\'usage'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _motCleController,
                        maxLines: 2,
                        decoration: _inputDecoration(context, isDark, 'Ex. Apéritif, Brunch...'),
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Ingrédients'),
                      const SizedBox(height: 8),
                      ...List.generate(_ingredientsControllers.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextField(
                            controller: _ingredientsControllers[i],
                            decoration: _inputDecoration(
                              context,
                              isDark,
                              'Ingrédient ${i + 1}',
                            ),
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: _addIngredient,
                        icon: Icon(Icons.add, size: 20, color: orange),
                        label: Text('Ajouter', style: TextStyle(color: orange, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Préparation'),
                      const SizedBox(height: 8),
                      ...List.generate(_stepsControllers.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextField(
                            controller: _stepsControllers[i],
                            maxLines: 2,
                            decoration: _inputDecoration(
                              context,
                              isDark,
                              'Étape ${i + 1}',
                            ),
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: _addStep,
                        icon: Icon(Icons.add, size: 20, color: orange),
                        label: Text('Ajouter', style: TextStyle(color: orange, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.spellcheck, color: pink),
                            tooltip: 'Corriger l\'orthographe',
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Annuler'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _submit(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orange,
                              foregroundColor: AppPalette.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Enregistrer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    final isDark = widget.isDark;
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: onBg,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, bool isDark, String? hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: isDark ? AppPalette.darkPastelSurface : AppPalette.lightGray.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
