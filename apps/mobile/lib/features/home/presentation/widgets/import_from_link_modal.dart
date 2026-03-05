import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/ingredient_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/preparation_step_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/entities/recipe_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/providers/video_import_provider.dart';

// ---------------------------------------------------------------------------
// Language / dialect list
// ---------------------------------------------------------------------------

const _kLanguages = <String>[
  'Auto-detect',
  // Major world languages
  'Français',
  'English',
  'Español',
  'Português',
  'Deutsch',
  'Italiano',
  'Nederlands',
  'Русский',
  'Türkçe',
  'Polski',
  'Svenska',
  'Norsk',
  'Dansk',
  'Suomi',
  'Čeština',
  'Română',
  'Magyar',
  'Ελληνικά',
  // Arabic (standard + dialects)
  'Arabe standard (MSA)',
  'Darija (Marocain)',
  'Darja (Algérien)',
  'Arabe tunisien',
  'Arabe égyptien',
  'Arabe levantin',
  'Arabe du Golfe',
  'Arabe irakien',
  // Asian languages
  'Mandarin (中文)',
  'Cantonais (粵語)',
  'Japonais (日本語)',
  'Coréen (한국어)',
  'Hindi (हिन्दी)',
  'Bengali (বাংলা)',
  'Ourdou (اردو)',
  'Persan / Farsi (فارسی)',
  'Indonésien',
  'Malais',
  'Thaï (ภาษาไทย)',
  'Vietnamien (Tiếng Việt)',
  'Tagalog',
  // African / Middle Eastern
  'Hébreu (עברית)',
  'Swahili',
  'Haoussa',
  'Yorouba',
  'Wolof',
  'Amharique (አማርኛ)',
  'Amazigh / Tamazight',
  // Regional / creole variants
  'Français québécois',
  'Alemand suisse',
  'Pidjin nigérian',
  'Créole haïtien',
];

// ---------------------------------------------------------------------------
// Helper: map Gemini JSON → RecipeEntity (unsaved, placeholder IDs)
// ---------------------------------------------------------------------------

RecipeEntity _mapToRecipeEntity(Map<String, dynamic> data) {
  final rawIngredients = (data['ingredients'] as List<dynamic>? ?? [])
      .whereType<Map<String, dynamic>>()
      .toList();

  final rawSteps = (data['preparation_steps'] as List<dynamic>? ?? [])
      .whereType<Map<String, dynamic>>()
      .toList();

  final ingredients = rawIngredients.asMap().entries.map((e) {
    final m = e.value;
    return IngredientEntity(
      id: '',
      recipeId: '',
      name: m['name'] as String? ?? '',
      quantity: (m['quantity'] ?? '').toString(),
      unit: m['unit'] as String?,
      displayOrder: e.key,
    );
  }).toList();

  final steps = rawSteps.map((s) {
    return PreparationStepEntity(
      id: '',
      recipeId: '',
      stepNumber: (s['step_number'] as int?) ?? 1,
      instruction: s['description'] as String? ?? '',
    );
  }).toList();

  final rawThumb = data['thumbnail_url'] as String?;
  // Resolve relative /static/uploads/… paths to the full API base URL
  final resolvedThumb = AppConstants.resolveRecipeImageUrl(rawThumb);

  return RecipeEntity(
    id: '',
    userId: '',
    title: data['title'] as String? ?? 'Recette importée',
    servings: (data['servings'] as int?) ?? 1,
    ingredients: ingredients,
    preparationSteps: steps,
    imageUrls: resolvedThumb != null && resolvedThumb.isNotEmpty
        ? [resolvedThumb]
        : null,
  );
}

// ---------------------------------------------------------------------------
// Modal widget
// ---------------------------------------------------------------------------

/// Modal to import a recipe from a social media video link.
/// Returns the extracted [RecipeEntity] (not yet saved) when the user confirms,
/// or null if cancelled. The caller should open [NewRecipeModal] with the result.
class ImportFromLinkModal extends ConsumerStatefulWidget {
  const ImportFromLinkModal({super.key, required this.isDark});

  final bool isDark;

  /// Shows the modal and returns the extracted [RecipeEntity] on success, or null.
  static Future<RecipeEntity?> show(
    BuildContext context, {
    required bool isDark,
  }) {
    return showModalBottomSheet<RecipeEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImportFromLinkModal(isDark: isDark),
    );
  }

  @override
  ConsumerState<ImportFromLinkModal> createState() =>
      _ImportFromLinkModalState();
}

class _ImportFromLinkModalState extends ConsumerState<ImportFromLinkModal> {
  final _linkController = TextEditingController();
  final _languageController = TextEditingController();
  String _selectedLanguage = 'Auto-detect';

  @override
  void dispose() {
    _linkController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  void _transcrire() {
    final url = _linkController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez coller un lien vidéo'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ref.read(videoImportProvider.notifier).submitJob(url, _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final pink =
        isDark ? AppPalette.darkPastelPrimaryPink : AppPalette.primaryPink;
    final surface =
        isDark ? AppPalette.darkPastelSurfaceElevated : AppPalette.white;
    final onBg =
        isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final muted =
        isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;
    final fieldFill = isDark
        ? AppPalette.darkPastelSurface
        : AppPalette.lightGray.withValues(alpha: 0.5);

    // ---------- side-effect listener ----------
    ref.listen<VideoImportState>(videoImportProvider, (_, next) {
      if (!mounted) return;
      if (next is VideoImportDone) {
        final entity = _mapToRecipeEntity(next.recipeData);
        Navigator.of(context).pop(entity);
      } else if (next is VideoImportError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        ref.read(videoImportProvider.notifier).reset();
      }
    });

    final importState = ref.watch(videoImportProvider);
    final isProcessing = importState is VideoImportSubmitting ||
        importState is VideoImportPolling;

    final statusLabel = switch (importState) {
      VideoImportSubmitting() => 'Envoi en cours...',
      VideoImportPolling() => 'Analyse de la vidéo en cours...',
      _ => '',
    };

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
              // ---------- header ----------
              _buildHeader(isDark, pink),

              // ---------- progress bar (visible while processing) ----------
              if (isProcessing) ...[
                LinearProgressIndicator(
                  backgroundColor: pink.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(pink),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: pink,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              // ---------- body ----------
              Flexible(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // URL field
                      Text(
                        'Lien de la vidéo',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: onBg,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _linkController,
                        enabled: !isProcessing,
                        decoration: InputDecoration(
                          hintText: 'https://...',
                          hintStyle: TextStyle(color: muted),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: fieldFill,
                        ),
                        keyboardType: TextInputType.url,
                        autofillHints: const [AutofillHints.url],
                      ),
                      const SizedBox(height: 16),

                      // Platform chips (informational only)
                      Text(
                        'Plateforme',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: onBg,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _PlatformChip(label: 'TikTok'),
                          _PlatformChip(label: 'Instagram'),
                          _PlatformChip(label: 'YouTube'),
                          _PlatformChip(label: 'Facebook'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Language autocomplete
                      Text(
                        'Langue / dialecte de la vidéo',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: onBg,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Autocomplete<String>(
                        initialValue:
                            TextEditingValue(text: _selectedLanguage),
                        optionsBuilder: (TextEditingValue value) {
                          if (value.text.isEmpty) return _kLanguages;
                          return _kLanguages.where(
                            (lang) => lang.toLowerCase().contains(
                                  value.text.toLowerCase(),
                                ),
                          );
                        },
                        onSelected: (String selection) {
                          setState(() => _selectedLanguage = selection);
                        },
                        fieldViewBuilder: (
                          context,
                          controller,
                          focusNode,
                          onSubmitted,
                        ) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            enabled: !isProcessing,
                            decoration: InputDecoration(
                              hintText: 'Ex: Darija, Français, English…',
                              hintStyle: TextStyle(color: muted),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: fieldFill,
                              suffixIcon: Icon(
                                Icons.language,
                                color: muted,
                                size: 18,
                              ),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final lang = options.elementAt(index);
                                    return ListTile(
                                      dense: true,
                                      title: Text(lang,
                                          style:
                                              const TextStyle(fontSize: 14)),
                                      onTap: () => onSelected(lang),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Limité à 15 minutes. Gemini Flash détectera automatiquement la langue si non spécifiée.',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      const SizedBox(height: 24),

                      // Transcribe button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: isProcessing ? null : _transcrire,
                          icon: isProcessing
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppPalette.white,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome, size: 18),
                          label: Text(
                            isProcessing
                                ? 'Analyse en cours...'
                                : 'Transcrire la recette',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isProcessing
                                ? pink.withValues(alpha: 0.45)
                                : pink,
                            foregroundColor: AppPalette.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: isProcessing
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

  Widget _buildHeader(bool isDark, Color pink) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [pink, pink.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppPalette.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Importer depuis un lien',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppPalette.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TikTok, Instagram, YouTube, Facebook — max 15 min',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppPalette.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  const _PlatformChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: TextStyle(
        color: Theme.of(context).disabledColor,
        fontSize: 13,
      ),
    );
  }
}
