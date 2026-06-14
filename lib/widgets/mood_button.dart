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
        scale: isSelected ? 1.1 : 1.0,
        duration: AppConstants.shortDuration,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      moodColor.withValues(alpha: 0.8),
                      moodColor.withValues(alpha: 0.5),
                    ],
                  )
                : null,
            color: isSelected ? null : AppColors.bgCard,
            border: Border.all(
              color: isSelected ? moodColor : AppColors.bgCardLight,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: moodColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getMoodEmoji(mood),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 300.ms).scale(
          begin: const Offset(0.8, 0.8),
          curve: Curves.easeOutBack,
          duration: 400.ms,
        );
  }

  String getMoodEmoji(String mood) {
    const Map<String, String> emojis = {
      'happy': '😊',
      'sad': '😢',
      'peaceful': '😌',
      'thrilled': '🤩',
      'thoughtful': '🤔',
      'adventurous': '🚀',
      'melancholic': '🌙',
      'romantic': '💕',
      'mysterious': '🕯️',
      'inspiring': '✨',
      'nostalgic': '📜',
      'anxious': '⚡',
    };
    return emojis[mood] ?? '📚';
  }
}
