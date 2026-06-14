import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Warm Paperback Earthtones
  static const Color primaryLight = Color(0xFFF5EADE); // Soft Parchment
  static const Color primaryAccent = Color(0xFF7A5A3E); // Leather Brown
  static const Color secondaryAccent = Color(0xFF8A6A4F); // Cedar Brown

  // Background Colors
  static const Color bgLight = Color(0xFFEEE5D8); // Warm Ivory
  static const Color bgDark = Color(0xFF3F362F); // Rich Cocoa
  static const Color bgCard = Color(0xFFF9F1E6); // Creamy Paper
  static const Color bgCardLight = Color(0xFFF1E7D9); // Light Parchment
  static const Color bgCardDarker = Color(0xFFD8C4B0); // Aged Paper

  // Text Colors
  static const Color textPrimary = Color(0xFF352A24); // Dark Espresso
  static const Color textSecondary = Color(0xFF5E4B3D); // Walnut
  static const Color textMuted = Color(0xFF8A7B6D); // Dusty Taupe

  // Accent Colors
  static const Color accentGold = Color(0xFFBA9166); // Antique Brass
  static const Color accentPink = Color(0xFFAC8E7D); // Dusty Rose
  static const Color accentRed = Color(0xFFD0694D); // Clay Red
  static const Color accentGreen = Color(0xFF6A826A); // Moss Green

  // Status Colors
  static const Color success = Color(0xFF6A826A); // Moss Green
  static const Color error = Color(0xFFD0694D); // Clay Red
  static const Color warning = Color(0xFFBA9166); // Antique Brass
  static const Color info = Color(0xFF8B9B8F); // Sage Mist

  // Mood Colors (Earthy & Natural variants)
  static const Map<String, Color> moodColors = {
    'happy': Color(0xFFBA9166), // Antique Brass
    'sad': Color(0xFF8B9B8F), // Sage Mist
    'peaceful': Color(0xFFA9B39C), // Soft Sage
    'thrilled': Color(0xFF7A5A3E), // Leather Brown
    'thoughtful': Color(0xFF5E4B3D), // Walnut
    'adventurous': Color(0xFFD0694D), // Clay Red
    'melancholic': Color(0xFF8A6A4F), // Cedar Brown
    'romantic': Color(0xFFAC8E7D), // Dusty Rose
    'mysterious': Color(0xFF3D322E), // Deep Espresso
    'inspiring': Color(0xFFBA9166), // Antique Brass
    'nostalgic': Color(0xFF9C826D), // Warm Tan
    'anxious': Color(0xFF5A7B8C), // Muted Slate
  };
}
