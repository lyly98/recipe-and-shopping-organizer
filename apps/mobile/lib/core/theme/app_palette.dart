import 'package:flutter/material.dart';

/// Central color palette for the app.
/// Includes design system colors (from Figma) and dark pastel tones
/// for backgrounds, surfaces, and category cards.
class AppPalette {
  AppPalette._();

  // ---------------------------------------------------------------------------
  // Design system (Figma)
  // ---------------------------------------------------------------------------

  /// Primary action: buttons like "Nouvelle recette"
  static const Color primaryOrange = Color(0xFFFF8C42);

  /// Secondary action: "Depuis un lien", "Transcrire la recette"
  static const Color primaryPink = Color(0xFFE74C9A);

  /// Information / navigation: "Gérer catégories", modal headers
  static const Color primaryBlue = Color(0xFF4A90E2);

  /// Neutrals (light theme)
  static const Color white = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFFFF8F0);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF999999);
  static const Color darkGray = Color(0xFF333333);
  static const Color black = Color(0xFF000000);

  /// Category card backgrounds (soft pastels - light theme)
  static const Color categoryPlats = Color(0xFFFFF8DC);
  static const Color categoryPains = Color(0xFFFFE4C4);
  static const Color categoryDesserts = Color(0xFFFFF0E6);
  static const Color categoryJus = Color(0xFFF0F0F0);
  static const Color categorySnacks = Color(0xFFFFE4E1);
  static const Color categorySoupes = Color(0xFFFAF0E6);

  // ---------------------------------------------------------------------------
  // Dark pastels (backgrounds, surfaces, cards)
  // ---------------------------------------------------------------------------

  /// Dark pastel background (main scaffold)
  static const Color darkPastelBackground = Color(0xFF2C292E);

  /// Dark pastel surface (cards, app bar, bottom nav)
  static const Color darkPastelSurface = Color(0xFF3A363D);

  /// Dark pastel surface elevated (dialogs, menus)
  static const Color darkPastelSurfaceElevated = Color(0xFF454148);

  /// Dark pastel border / divider
  static const Color darkPastelBorder = Color(0xFF4D4950);

  /// Text on dark pastel
  static const Color darkPastelOnBackground = Color(0xFFE8E4E9);
  static const Color darkPastelOnSurfaceMuted = Color(0xFFB0ACB2);

  /// Dark pastel accent tints (for category cards and subtle UI)
  static const Color darkPastelSage = Color(0xFF7D8B7A);
  static const Color darkPastelMauve = Color(0xFF8B7D8B);
  static const Color darkPastelDustBlue = Color(0xFF7A8B9A);
  static const Color darkPastelTerracotta = Color(0xFF9A7A6B);
  static const Color darkPastelOlive = Color(0xFF6B7A6B);
  static const Color darkPastelDustyRose = Color(0xFF8B7A7D);
  static const Color darkPastelWarmBeige = Color(0xFF8B857A);
  static const Color darkPastelSlate = Color(0xFF7A858B);

  /// Category card backgrounds (dark pastel variant)
  static const Color darkPastelCategoryPlats = Color(0xFF5C5A4A);
  static const Color darkPastelCategoryPains = Color(0xFF6B5A4A);
  static const Color darkPastelCategoryDesserts = Color(0xFF6B5A5A);
  static const Color darkPastelCategoryJus = Color(0xFF4A5A5C);
  static const Color darkPastelCategorySnacks = Color(0xFF6B5A5C);
  static const Color darkPastelCategorySoupes = Color(0xFF5A5A4A);

  /// Primary actions on dark pastel (slightly softened for contrast)
  static const Color darkPastelPrimaryOrange = Color(0xFFE07A38);
  static const Color darkPastelPrimaryPink = Color(0xFFD1438A);
  static const Color darkPastelPrimaryBlue = Color(0xFF4A7BC2);
}
