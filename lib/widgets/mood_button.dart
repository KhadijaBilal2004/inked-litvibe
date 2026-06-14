import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

class MoodButton extends StatelessWidget {
  final String mood;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodButton({
    Key? key,
    required this.mood,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

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
                      moodColor.withOpacity(0.8),
                      moodColor.withOpacity(0.5),
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
                      color: moodColor.withOpacity(0.35),
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
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(height: AppConstants.paddingSmall),
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
