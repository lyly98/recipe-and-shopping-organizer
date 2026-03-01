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
  // Dark theme — Instagram-style: black, white, one accent
  // ---------------------------------------------------------------------------

  /// Background layers (black → dark gray)
  static const Color darkPastelBackground = Color(0xFF000000);
  static const Color darkPastelSurface = Color(0xFF121212);
  static const Color darkPastelSurfaceElevated = Color(0xFF1C1C1E);
  static const Color darkPastelBorder = Color(0xFF2C2C2E);

  /// Text (white / gray only)
  static const Color darkPastelOnBackground = Color(0xFFFFFFFF);
  static const Color darkPastelOnSurfaceMuted = Color(0xFF8E8E93);

  /// Single accent — Instagram-style pink (used for all accents)
  static const Color darkPastelAccent = Color(0xFFE1306C);

  /// Accent tints — same accent for icons & subtle UI (no extra colors)
  static const Color darkPastelSage = Color(0xFFE1306C);
  static const Color darkPastelMauve = Color(0xFFE1306C);
  static const Color darkPastelDustBlue = Color(0xFFE1306C);
  static const Color darkPastelTerracotta = Color(0xFFE1306C);
  static const Color darkPastelOlive = Color(0xFFE1306C);
  static const Color darkPastelDustyRose = Color(0xFFE1306C);
  static const Color darkPastelWarmBeige = Color(0xFFE1306C);
  static const Color darkPastelSlate = Color(0xFFE1306C);

  /// Category cards — dark grays only (no colored tints)
  static const Color darkPastelCategoryPlats = Color(0xFF1A1A1A);
  static const Color darkPastelCategoryPains = Color(0xFF1E1E1E);
  static const Color darkPastelCategoryDesserts = Color(0xFF222222);
  static const Color darkPastelCategoryJus = Color(0xFF1A1A1A);
  static const Color darkPastelCategorySnacks = Color(0xFF1E1E1E);
  static const Color darkPastelCategorySoupes = Color(0xFF222222);

  /// Primary actions — single accent for all (Instagram pink)
  static const Color darkPastelPrimaryOrange = Color(0xFFE1306C);
  static const Color darkPastelPrimaryPink = Color(0xFFE1306C);
  static const Color darkPastelPrimaryBlue = Color(0xFFE1306C);
}
