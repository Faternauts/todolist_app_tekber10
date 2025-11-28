import 'package:flutter/material.dart';

/// TaskFlow UI Color Palette (Matching Screenshot)
class AppColors {
  // Primary Colors - Light Pastel Purple Theme
  static const Color primaryDark = Color(0xFF2D2144); // Dark text
  static const Color primaryPurple = Color(0xFFC8B8E8); // Light purple header
  static const Color primaryLight = Color(0xFFE8E0F5); // Very light purple
  static const Color accentBlue = Color(0xFF6B7FE8); // Soft blue
  static const Color accentPurple = Color(0xFF9759C4); // Accent purple for links

  // Background Colors
  static const Color backgroundLight = Color(0xFFF6F4FA); // Light lavender background
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color.fromARGB(255, 52, 46, 84); // Almost black
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Priority Colors (Soft Pastel from Screenshot)
  static const Color priorityHigh = Color(0xFFE57373); // Soft coral/salmon
  static const Color priorityHighBg = Color(0xFFFFE4E1); // Very light coral
  static const Color priorityMedium = Color(0xFF7B9EF1); // Soft blue
  static const Color priorityMediumBg = Color(0xFFE3EFFF); // Very light blue
  static const Color priorityLow = Color(0xFF9E9E9E); // Soft gray
  static const Color priorityLowBg = Color(0xFFF5F5F5); // Very light gray

  // Status Colors
  static const Color statusOngoing = Color(0xFF3B82F6);
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusMissed = Color(0xFFEF4444);

  // UI Elements
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color shadowColor = Color(0x1A000000);

  // Gradient Colors
  static const LinearGradient purpleGradient = LinearGradient(colors: [Color(0xFF9A7DDA), Color(0xFF866AC2)], begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const LinearGradient pinkGradient = LinearGradient(colors: [Color(0xFFC084FC), Color(0xFFEC4899)], begin: Alignment.topLeft, end: Alignment.bottomRight);
}

/// TaskFlow UI Text Styles
class AppTextStyles {
  static const String fontFamily = 'SFProDisplay';

  // Headings
  static const TextStyle h1 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.2, fontFamily: fontFamily);

  static const TextStyle h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3, fontFamily: fontFamily);

  static const TextStyle h3 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.4, fontFamily: fontFamily);

  static const TextStyle h4 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.4, fontFamily: fontFamily);

  // Body Text
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.5, fontFamily: fontFamily);

  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondary, height: 1.5, fontFamily: fontFamily);

  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary, height: 1.4, fontFamily: fontFamily);

  // Special
  static const TextStyle caption = TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textHint, height: 1.4, fontFamily: fontFamily);

  static const TextStyle button = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2, fontFamily: fontFamily);

  static const TextStyle timer = TextStyle(fontSize: 60, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 2);
}

/// TaskFlow UI Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// TaskFlow UI Border Radius
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 30.0;
  static const double full = 9999.0;
}

/// TaskFlow UI Shadows
class AppShadows {
  static const BoxShadow small = BoxShadow(color: AppColors.shadowColor, blurRadius: 6, offset: Offset(0, 2));

  static const BoxShadow medium = BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: Offset(0, 4));

  static const BoxShadow large = BoxShadow(color: AppColors.shadowColor, blurRadius: 20, offset: Offset(0, 8));
}
