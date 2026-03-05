import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';

/// Modal to import a recipe from a video link (TikTok, Instagram, YouTube, etc.).
/// Figma: Video Import Modal – pink header, URL input, platform suggestions, "Transcrire la recette".
class ImportFromLinkModal extends StatefulWidget {
  const ImportFromLinkModal({
    super.key,
    required this.isDark,
  });

  final bool isDark;

  /// Shows the modal and returns when dismissed.
  static Future<void> show(BuildContext context, {required bool isDark}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImportFromLinkModal(isDark: isDark),
    );
  }

  @override
  State<ImportFromLinkModal> createState() => _ImportFromLinkModalState();
}

class _ImportFromLinkModalState extends State<ImportFromLinkModal> {
  final _linkController = TextEditingController();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _transcrire() {
    // Feature not yet implemented — no API endpoint exists
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 Fonctionnalité en cours de développement'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final pink = isDark ? AppPalette.darkPastelPrimaryPink : AppPalette.primaryPink;
    final surface = isDark ? AppPalette.darkPastelSurfaceElevated : AppPalette.white;
    final onBg = isDark ? AppPalette.darkPastelOnBackground : AppPalette.darkGray;
    final muted = isDark ? AppPalette.darkPastelOnSurfaceMuted : AppPalette.mediumGray;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      pink,
                      pink.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link, color: AppPalette.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Importer depuis un lien',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: AppPalette.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Collez un lien de vidéo TikTok, Instagram, YouTube...',
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
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppPalette.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppPalette.white.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.construction, color: AppPalette.white, size: 14),
                          const SizedBox(width: 6),
                          const Text(
                            'En cours de développement',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppPalette.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                        decoration: InputDecoration(
                          hintText: 'https://...',
                          hintStyle: TextStyle(color: muted),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDark ? AppPalette.darkPastelSurface : AppPalette.lightGray.withValues(alpha: 0.5),
                        ),
                        keyboardType: TextInputType.url,
                        autofillHints: const [AutofillHints.url],
                      ),
                      const SizedBox(height: 16),
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
                        children: [
                          _PlatformChip(label: 'TikTok'),
                          _PlatformChip(label: 'Instagram'),
                          _PlatformChip(label: 'YouTube'),
                          _PlatformChip(label: 'Facebook'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _transcrire,
                          icon: const Icon(Icons.construction, size: 18),
                          label: const Text('Transcrire la recette — Bientôt disponible'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pink.withValues(alpha: 0.45),
                            foregroundColor: AppPalette.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
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
