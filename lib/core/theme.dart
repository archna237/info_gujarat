import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF1E3A8A); // Deep Blue
  static const Color secondaryColor = Color(0xFFD97706); // Amber
  
  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF111827);
  static const Color textSecondaryColor = Color(0xFF6B7280);
  static const Color dividerColor = Color(0xFFE5E7EB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: cardColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: textPrimaryColor, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(color: textPrimaryColor, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.inter(color: textPrimaryColor, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.inter(color: textPrimaryColor, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textPrimaryColor),
        bodyMedium: GoogleFonts.inter(color: textSecondaryColor),
        labelLarge: GoogleFonts.inter(color: primaryColor, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      // cardTheme: CardTheme(
      //   color: cardColor,
      //   elevation: 2,
      //   shadowColor: Colors.black.withOpacity(0.05),
      //   margin: EdgeInsets.zero,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      // ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        disabledColor: dividerColor,
        selectedColor: primaryColor,
        secondarySelectedColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.inter(color: textSecondaryColor, fontWeight: FontWeight.w500),
        secondaryLabelStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: dividerColor),
        ),
      ),
    );
  }
}
