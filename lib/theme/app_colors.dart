import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Dark Aesthetic
  static const Color primaryDark = Color(0xFF0D0221); // Deep Purple-Black
  static const Color primaryAccent = Color(0xFF6A0572); // Rich Purple
  static const Color secondaryAccent = Color(0xFFAB63FA); // Vibrant Purple
  
  // Background Colors
  static const Color bgDark = Color(0xFF0F0417); // Almost Black
  static const Color bgCard = Color(0xFF1A0A2E); // Dark Purple
  static const Color bgCardLight = Color(0xFF2D0E4E); // Lighter Purple
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5F5); // Off-white
  static const Color textSecondary = Color(0xFFB0B0B0); // Light Gray
  static const Color textMuted = Color(0xFF7A7A7A); // Muted Gray
  
  // Accent Colors
  static const Color accentGold = Color(0xFFD4AF37); // Gold
  static const Color accentPink = Color(0xFFFF006E); // Vibrant Pink
  static const Color accentCyan = Color(0xFF00F5FF); // Cyan
  
  // Status Colors
  static const Color success = Color(0xFF00D084); // Green
  static const Color error = Color(0xFFFF006E); // Pink/Red
  static const Color warning = Color(0xFFFFA500); // Orange
  static const Color info = Color(0xFF00B4D8); // Blue
  
  // Mood Colors
  static const Map<String, Color> moodColors = {
    'happy': Color(0xFFFFD700),        // Gold
    'sad': Color(0xFF4A90E2),          // Blue
    'peaceful': Color(0xFF7ED321),     // Green
    'thrilled': Color(0xFFFF006E),     // Pink
    'thoughtful': Color(0xFFAB63FA),   // Purple
    'adventurous': Color(0xFFFF8C42),  // Orange
    'melancholic': Color(0xFF9B59B6),  // Deep Purple
    'romantic': Color(0xFFFF69B4),     // Hot Pink
  };
}
