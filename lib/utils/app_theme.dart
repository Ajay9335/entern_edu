import 'package:flutter/material.dart';

/// Design tokens matched from the Intern-Edu website
/// (login, register, and dashboard screenshots).
class AppTheme {
  // Core palette
  static const Color background = Color(0xFFF8F1E7); // warm cream
  static const Color cardFill = Color(0xFFFBF6EF); // input / card fill
  static const Color primaryOrange = Color(0xFFF2924A); // accent orange
  static const Color primaryOrangeLight = Color(0xFFFBE6D3); // badge bg
  static const Color black = Color(0xFF1A1714); // headings, CTA buttons
  static const Color sidebarDark = Color(0xFF1C1712); // dashboard sidebar
  static const Color textGray = Color(0xFF8B8B8B); // subtitles
  static const Color borderColor = Color(0xFFE7DFD2);

  // Kept as `primaryColor` for backward-compat with existing widgets
  // (e.g. DashboardScreen references AppTheme.primaryColor).
  static const Color primaryColor = primaryOrange;
  static const Color secondaryColor = Color(0xFFF59E0B);
  static const Color backgroundColor = background;

  static ThemeData themeData = ThemeData(
    useMaterial3: true,
    primaryColor: primaryOrange,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryOrange,
      primary: primaryOrange,
      surface: background,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryOrange, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    ),
  );

  /// Small pill badge like "SECURE ACCESS" / "JOIN THE NEXUS".
  static Widget pillBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: primaryOrangeLight,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: primaryOrange,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// Two-tone heading e.g. "Welcome" + "Back" in orange.
  static Widget twoToneHeading(String plain, String accent, {double fontSize = 32}) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: black),
        children: [
          TextSpan(text: '$plain '),
          TextSpan(text: accent, style: const TextStyle(color: primaryOrange)),
        ],
      ),
    );
  }
}