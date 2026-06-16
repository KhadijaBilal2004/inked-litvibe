import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MoodButton extends StatelessWidget {
  final String mood;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodButton({
    super.key,
    required this.mood,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final moodColor = AppColors.moodColors[mood] ?? AppColors.secondaryAccent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: AppConstants.shortDuration,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.0),
            color: isSelected ? moodColor.withValues(alpha: 0.15) : AppColors.bgCard,
            border: Border.all(
              color: isSelected 
                  ? moodColor.withValues(alpha: 0.5) 
                  : Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                      ? moodColor.withValues(alpha: 0.2) 
                      : AppColors.primaryAccent.withValues(alpha: 0.08),
                ),
                child: Center(
                  child: Icon(
                    getMoodIcon(mood),
                    size: 30,
                    color: isSelected ? moodColor : AppColors.primaryAccent,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mood[0].toUpperCase() + mood.substring(1),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16), // Give some breathing room on the right
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 300.ms).slideX(
          begin: 0.1,
          curve: Curves.easeOutCubic,
          duration: 400.ms,
        );
  }

  IconData getMoodIcon(String mood) {
    // Map to outlined, warm, welcoming icons
    const Map<String, IconData> icons = {
      'cheerful': Icons.sentiment_satisfied_outlined,
      'melancholic': Icons.bedtime_outlined, // Moon
      'pensive': Icons.psychology_outlined, // Head with gears/question
      'anxious': Icons.bolt_outlined, // Lightning
      'calm': Icons.spa_outlined, // Lotus
      'romantic': Icons.favorite_outline_rounded,
      'adventurous': Icons.explore_outlined,
      'happy': Icons.sentiment_satisfied_outlined,
      'sad': Icons.water_drop_outlined,
      'peaceful': Icons.spa_outlined,
      'thrilled': Icons.celebration_outlined,
      'thoughtful': Icons.lightbulb_outline_rounded,
      'mysterious': Icons.search_rounded,
      'inspiring': Icons.auto_awesome_outlined,
      'nostalgic': Icons.history_edu_outlined,
    };
    return icons[mood] ?? Icons.book_outlined;
  }
}
