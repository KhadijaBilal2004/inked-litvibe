import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Warm Aesthetic
  static const Color primaryLight = Color(0xFFFDFBF7); // Warm Cream
  static const Color primaryAccent = Color(0xFFE07A5F); // Warm Terracotta
  static const Color secondaryAccent = Color(0xFFF2CC8F); // Sunset Orange
  
  // Background Colors
  static const Color bgLight = Color(0xFFF4EFE6); // Soft Beige
  static const Color bgCard = Color(0xFFFFFFFF); // White for cards
  static const Color bgCardDarker = Color(0xFFEAE2D6); // Slightly darker beige
  
  // Text Colors
  static const Color textPrimary = Color(0xFF3D405B); // Charcoal / Dark Blue-Gray
  static const Color textSecondary = Color(0xFF815B5B); // Soft Brown
  static const Color textMuted = Color(0xFFAFAFAF); // Muted Gray
  
  // Accent Colors
  static const Color accentGold = Color(0xFFE9C46A); // Warm Gold
  static const Color accentRed = Color(0xFFE63946); // Muted Red (Nope/Error)
  static const Color accentGreen = Color(0xFF2A9D8F); // Soft Green (Like/Success)
  
  // Status Colors
  static const Color success = Color(0xFF2A9D8F); // Green
  static const Color error = Color(0xFFE63946); // Red
  static const Color warning = Color(0xFFE9C46A); // Gold/Yellow
  static const Color info = Color(0xFF8ECAE6); // Light Blue
  
  // Mood Colors (Warm and Cozy variants)
  static const Map<String, Color> moodColors = {
    'happy': Color(0xFFF2CC8F),        // Sunset Orange
    'sad': Color(0xFF8ECAE6),          // Light Blue
    'peaceful': Color(0xFF81B29A),     // Soft Mint Green
    'thrilled': Color(0xFFE07A5F),     // Terracotta
    'thoughtful': Color(0xFF3D405B),   // Charcoal
    'adventurous': Color(0xFFE63946),  // Muted Red
    'melancholic': Color(0xFF815B5B),  // Soft Brown
    'romantic': Color(0xFFF4A261),     // Soft Peach
  };
}
