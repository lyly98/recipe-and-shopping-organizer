import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/recipe_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/categories_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Per-ingredient form state: name, quantity, and unit.
class _IngredientEntry {
  _IngredientEntry({String name = '', String quantity = '', this.selectedUnit})
      : nameController = TextEditingController(text: name),
        quantityController = TextEditingController(text: quantity);

  final TextEditingController nameController;
  final TextEditingController quantityController;
  String? selectedUnit;

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
  }
}

/// Modal to create or edit a recipe. Sends params to [onSave] for API.
class NewRecipeModal extends StatefulWidget {
  const NewRecipeModal({
    super.key,
    required this.isDark,
    required this.onSave,
    required this.categoryItems,
    this.uploadImage,
    this.existingRecipe,
  });

  final bool isDark;
  final Future<String?> Function(Map<String, dynamic> params) onSave;
  final List<CategoryItem> categoryItems;

  /// If provided, called with the picked image path; returns URL to use in recipe or null on failure.
  final Future<String?> Function(String filePath)? uploadImage;

  /// When set, the modal opens in edit mode pre-filled with this recipe's data.
  final RecipeEntity? existingRecipe;

  /// Shows the modal and returns when dismissed. [onSave] returns null on success or error message.
  static Future<void> show(
    BuildContext context, {
    required bool isDark,
    required List<CategoryItem> categoryItems,
    required Future<String?> Function(Map<String, dynamic> params) onSave,
    Future<String?> Function(String filePath)? uploadImage,
    RecipeEntity? existingRecipe,
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
        existingRecipe: existingRecipe,
      ),
    );
  }

  @override
  State<NewRecipeModal> createState() => _NewRecipeModalState();
}

/// Available units for ingredient quantities.
const _kUnits = <String?>[
  null,
  'g',
  'kg',
  'mL',
  'L',
  'tasse',
  'c. à s.',
  'c. à c.',
  'pièce(s)',
];

class _NewRecipeModalState extends State<NewRecipeModal> {
  final _titreController = TextEditingController();
  final _motCleController = TextEditingController();
  final _stepsControllers = <TextEditingController>[];
  final _ingredients = <_IngredientEntry>[];

  String? _selectedCategoryId;
  String? _imagePath;
  String? _imageUrl;
  int _servings = 1;
  final _picker = ImagePicker();

  bool get _isEditing => widget.existingRecipe != null;

  List<CategoryItem> get _categories =>
      widget.categoryItems.isNotEmpty ? widget.categoryItems : [const CategoryItem(id: '', name: 'Plats', emoji: '🍽️')];

  @override
  void initState() {
    super.initState();
    final recipe = widget.existingRecipe;
    if (recipe != null) {
      _titreController.text = recipe.title;
      _motCleController.text = recipe.mealUsage ?? '';
      _selectedCategoryId = recipe.categoryId;
      _servings = recipe.servings > 0 ? recipe.servings : 1;
      final firstUrl = recipe.imageUrls?.isNotEmpty == true ? recipe.imageUrls!.first : null;
      _imageUrl = firstUrl;

      if (recipe.ingredients.isNotEmpty) {
        for (final ing in recipe.ingredients) {
          _ingredients.add(_IngredientEntry(
            name: ing.name,
            quantity: ing.quantity,
            selectedUnit: ing.unit,
          ));
        }
      } else {
        _ingredients.add(_IngredientEntry());
      }

      if (recipe.preparationSteps.isNotEmpty) {
        for (final step in recipe.preparationSteps) {
          _stepsControllers.add(TextEditingController(text: step.instruction));
        }
      } else {
        _stepsControllers.add(TextEditingController());
      }
    } else {
      _ingredients.add(_IngredientEntry());
      _stepsControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _motCleController.dispose();
    for (final entry in _ingredients) {
      entry.dispose();
    }
    for (final c in _stepsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(_IngredientEntry());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredients.length <= 1) return;
    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
  }

  void _addStep() {
    setState(() {
      _stepsControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    if (_stepsControllers.length <= 1) return;
    setState(() {
      _stepsControllers[index].dispose();
      _stepsControllers.removeAt(index);
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
    final categoryId = _selectedCategoryId ??
        (_categories.isNotEmpty && _categories.first.id.isNotEmpty ? _categories.first.id : null);

    final ingredientMaps = <Map<String, dynamic>>[];
    for (var i = 0; i < _ingredients.length; i++) {
      final entry = _ingredients[i];
      final name = entry.nameController.text.trim();
      if (name.isEmpty) continue;
      final qty = entry.quantityController.text.trim();
      ingredientMaps.add({
        'name': name,
        'quantity': qty.isEmpty ? '1' : qty,
        'unit': entry.selectedUnit,
        'display_order': i,
      });
    }

    final stepMaps = <Map<String, dynamic>>[];
    for (var i = 0; i < _stepsControllers.length; i++) {
      final instruction = _stepsControllers[i].text.trim();
      if (instruction.isEmpty) continue;
      stepMaps.add({
        'step_number': i + 1,
        'instruction': instruction,
        'duration_minutes': null,
      });
    }

    List<String>? imageUrls;
    if (_imagePath != null && _imagePath!.trim().isNotEmpty && widget.uploadImage != null) {
      final url = await widget.uploadImage!(_imagePath!);
      if (url != null && url.isNotEmpty) {
        imageUrls = [url];
      }
    } else if (_imagePath == null && _imageUrl != null && _imageUrl!.isNotEmpty) {
      imageUrls = [_imageUrl!];
    }

    final err = await widget.onSave({
      'id': widget.existingRecipe?.id,
      'title': titre,
      'categoryId': categoryId,
      'mealUsage': _motCleController.text.trim().isEmpty ? null : _motCleController.text.trim(),
      'servings': _servings,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Recette modifiée' : 'Recette enregistrée')),
    );
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
                  _isEditing ? 'Modifier la recette' : 'Nouvelle recette',
                  style: const TextStyle(
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
                            color: isDark
                                ? AppPalette.darkPastelSurface
                                : AppPalette.lightGray.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppPalette.darkPastelBorder
                                  : AppPalette.mediumGray.withValues(alpha: 0.5),
                            ),
                          ),
                          child: _buildImagePreview(isDark, onBg),
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
                      _buildLabel('Nombre de personnes'),
                      const SizedBox(height: 8),
                      _buildServingsStepper(isDark, orange),
                      const SizedBox(height: 20),
                      _buildLabel('Ingrédients'),
                      const SizedBox(height: 4),
                      _buildIngredientHeader(isDark, onBg),
                      const SizedBox(height: 4),
                      ...List.generate(_ingredients.length, (i) => _buildIngredientRow(i, isDark, onBg, orange)),
                      TextButton.icon(
                        onPressed: _addIngredient,
                        icon: Icon(Icons.add, size: 20, color: orange),
                        label: Text('Ajouter', style: TextStyle(color: orange, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Préparation'),
                      const SizedBox(height: 8),
                      ...List.generate(_stepsControllers.length, (i) => _buildStepRow(i, isDark, orange)),
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
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orange,
                              foregroundColor: AppPalette.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(_isEditing ? 'Modifier' : 'Enregistrer'),
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

  Widget _buildImagePreview(bool isDark, Color onBg) {
    if (_imagePath != null && File(_imagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(_imagePath!), fit: BoxFit.cover, width: double.infinity),
      );
    }
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => _imagePlaceholder(isDark, onBg),
        ),
      );
    }
    return _imagePlaceholder(isDark, onBg);
  }

  Widget _imagePlaceholder(bool isDark, Color onBg) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 40, color: onBg.withValues(alpha: 0.5)),
        const SizedBox(height: 8),
        Text(
          'Ajouter une image',
          style: TextStyle(fontSize: 13, color: onBg.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  Widget _buildIngredientHeader(bool isDark, Color onBg) {
    final muted = onBg.withValues(alpha: 0.5);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text('Nom', style: TextStyle(fontSize: 12, color: muted)),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 60,
          child: Text('Qté', style: TextStyle(fontSize: 12, color: muted)),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 90,
          child: Text('Unité', style: TextStyle(fontSize: 12, color: muted)),
        ),
        const SizedBox(width: 36),
      ],
    );
  }

  Widget _buildIngredientRow(int i, bool isDark, Color onBg, Color orange) {
    final entry = _ingredients[i];
    final canRemove = _ingredients.length > 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: entry.nameController,
              decoration: _inputDecoration(context, isDark, 'Ingrédient ${i + 1}'),
              style: TextStyle(fontSize: 14, color: onBg),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 60,
            child: TextField(
              controller: entry.quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: _inputDecoration(context, isDark, '1'),
              style: TextStyle(fontSize: 14, color: onBg),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 90,
            child: _buildUnitDropdown(i, isDark, onBg),
          ),
          SizedBox(
            width: 36,
            child: canRemove
                ? IconButton(
                    onPressed: () => _removeIngredient(i),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.remove_circle_outline, size: 20, color: onBg.withValues(alpha: 0.4)),
                  )
                : const SizedBox(width: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitDropdown(int i, bool isDark, Color onBg) {
    final entry = _ingredients[i];
    final fillColor = isDark ? AppPalette.darkPastelSurface : AppPalette.lightGray.withValues(alpha: 0.5);
    final borderColor = isDark ? AppPalette.darkPastelBorder : AppPalette.mediumGray.withValues(alpha: 0.5);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: entry.selectedUnit,
          isExpanded: true,
          hint: Text('-', style: TextStyle(fontSize: 13, color: onBg.withValues(alpha: 0.5))),
          dropdownColor: isDark ? AppPalette.darkPastelSurface : AppPalette.white,
          style: TextStyle(fontSize: 13, color: onBg),
          items: _kUnits.map((unit) {
            return DropdownMenuItem<String?>(
              value: unit,
              child: Text(unit ?? '-', style: TextStyle(fontSize: 13, color: onBg)),
            );
          }).toList(),
          onChanged: (v) => setState(() => entry.selectedUnit = v),
        ),
      ),
    );
  }

  Widget _buildStepRow(int i, bool isDark, Color orange) {
    final isDark0 = widget.isDark;
    final onBg = isDark0 ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final canRemove = _stepsControllers.length > 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _stepsControllers[i],
              maxLines: 2,
              decoration: _inputDecoration(context, isDark, 'Étape ${i + 1}'),
            ),
          ),
          if (canRemove) ...[
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: IconButton(
                onPressed: () => _removeStep(i),
                padding: EdgeInsets.zero,
                icon: Icon(Icons.remove_circle_outline, size: 20, color: onBg.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServingsStepper(bool isDark, Color orange) {
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final bg = isDark ? AppPalette.darkPastelSurface : AppPalette.lightGray;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onBg.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _servings > 1 ? () => setState(() => _servings--) : null,
            icon: Icon(Icons.remove, color: _servings > 1 ? orange : onBg.withOpacity(0.3)),
            splashRadius: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$_servings personne${_servings > 1 ? 's' : ''}',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: onBg),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => setState(() => _servings++),
            icon: Icon(Icons.add, color: orange),
            splashRadius: 20,
          ),
        ],
      ),
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
