import 'package:flutter/material.dart';

class AppColors {
  // Vibrant Pink & Purple Medical Theme Colors
  static const Color primaryPink = Color(0xFFEC4899);     // Vibrant Pink (Accent/Highlights)
  static const Color primaryPurple = Color(0xFF8B5CF6);   // Vibrant Purple (Brand Primary)
  static const Color primaryLight = Color(0xFFFDF4FF);    // Very light lavender/pink bg tint
  static const Color accentViolet = Color(0xFFA78BFA);    // Medium Soft Purple
  static const Color darkPurple = Color(0xFF5B21B6);      // Dark Brand Accent
  static const Color softPeach = Color(0xFFFCE7F3);       // Soft Pink/Peach container tint
  static const Color mintGreen = Color(0xFFD1FAE5);       // Ambient success highlight tint
  static const Color skyBlue = Color(0xFFE0F2FE);         // Ambient info highlight tint

  // Glassmorphic Specific Translucent Colors
  static Color get glassBgLight => Colors.white.withValues(alpha: 0.4);
  static Color get glassBgDark => const Color(0xFF1F1A2D).withValues(alpha: 0.55);
  static Color get glassBorderLight => Colors.white.withValues(alpha: 0.25);
  static Color get glassBorderDark => Colors.white.withValues(alpha: 0.08);

  // Functional Colors
  static const Color success = Color(0xFF10B981);       // Clean Green
  static const Color warning = Color(0xFFF59E0B);       // Warm Orange
  static const Color error = Color(0xFFEF4444);         // Vibrant Red
  static const Color info = Color(0xFF3B82F6);          // Vibrant Blue

  // Light Theme Palette
  static const Color lightBg = Color(0xFFFAF5FF);        // Cream orchid white background
  static const Color lightSurface = Color(0xFFFFFFFF);   // White Cards
  static const Color lightTextPrimary = Color(0xFF1F1A24); // Deep charcoal
  static const Color lightTextSecondary = Color(0xFF6B7280); // Medium cool grey
  static const Color lightBorder = Color(0xFFF3E8FF);    // Very light lavender border

  // Dark Theme Palette
  static const Color darkBg = Color(0xFF0F0B15);         // Deep Dark Orchid/Black Background
  static const Color darkSurface = Color(0xFF1A1326);    // Dark purple-grey Cards
  static const Color darkTextPrimary = Color(0xFFF3F4F6); // Soft white
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // Light grey text
  static const Color darkBorder = Color(0xFF2E2245);     // Dark orchid border
}
