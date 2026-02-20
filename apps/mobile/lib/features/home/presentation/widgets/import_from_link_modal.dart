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
    final link = _linkController.text.trim();
    if (link.isEmpty) return;
    Navigator.of(context).pop();
    // TODO: call API to transcribe recipe from link
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
                          _PlatformChip(label: 'TikTok', onTap: () {}),
                          _PlatformChip(label: 'Instagram', onTap: () {}),
                          _PlatformChip(label: 'YouTube', onTap: () {}),
                          _PlatformChip(label: 'Facebook', onTap: () {}),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _transcrire,
                          icon: const Text('✨', style: TextStyle(fontSize: 18)),
                          label: const Text('Transcrire la recette'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pink,
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
  const _PlatformChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}
