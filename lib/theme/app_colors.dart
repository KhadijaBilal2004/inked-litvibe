import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Earthy Paperback Touch
  static const Color primaryLight = Color(0xFFFBF7F0); // Natural Paper Cream
  static const Color primaryAccent = Color(0xFF8B6F47); // Rich Warm Brown
  static const Color secondaryAccent = Color(0xFF6B8E71); // Earthy Sage Green
  
  // Background Colors
  static const Color bgLight = Color(0xFFF5F0E8); // Aged Paper Beige
  static const Color bgDark = Color(0xFF2B2620); // Deep Warm Brown (dark bg)
  static const Color bgCard = Color(0xFFFCF9F4); // Off-white Paper
  static const Color bgCardLight = Color(0xFFF8F3EB); // Very light warm paper
  static const Color bgCardDarker = Color(0xFFEBE1D3); // Slightly aged beige
  
  // Text Colors
  static const Color textPrimary = Color(0xFF3D3C3A); // Deep warm charcoal
  static const Color textSecondary = Color(0xFF6B5B47); // Natural brown
  static const Color textMuted = Color(0xFFA89F88); // Muted taupe
  
  // Accent Colors
  static const Color accentGold = Color(0xFFD4A574); // Aged Gold
  static const Color accentPink = Color(0xFFB89B8C); // Warm Taupe-Pink (Favorites)
  static const Color accentRed = Color(0xFF8B5A5A); // Muted Terracotta (Error)
  static const Color accentGreen = Color(0xFF6B8E71); // Earthy Green (Success)
  
  // Status Colors
  static const Color success = Color(0xFF6B8E71); // Green
  static const Color error = Color(0xFF8B5A5A); // Red
  static const Color warning = Color(0xFFD4A574); // Gold
  static const Color info = Color(0xFF8FA8A0); // Soft Blue-Green
  
  // Mood Colors (Earthy & Natural variants)
  static const Map<String, Color> moodColors = {
    'happy': Color(0xFFD4A574),        // Warm Gold
    'sad': Color(0xFF8FA8A0),          // Muted Blue-Green
    'peaceful': Color(0xFF9FB5A1),     // Soft Sage
    'thrilled': Color(0xFF8B6F47),     // Rich Brown
    'thoughtful': Color(0xFF5A5348),   // Deep Brown
    'adventurous': Color(0xFF8B5A5A),  // Warm Terracotta
    'melancholic': Color(0xFF6B5B47),  // Natural Brown
    'romantic': Color(0xFFB89B8C),     // Warm Taupe
    'mysterious': Color(0xFF4A4340),   // Deep Charcoal
    'inspiring': Color(0xFFD4A574),    // Warm Gold
    'nostalgic': Color(0xFF9F8880),    // Warm Tan
    'anxious': Color(0xFF5A7C8F),      // Muted Navy
  };
}
