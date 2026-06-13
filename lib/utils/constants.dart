class AppConstants {
  // App Info
  static const String appName = 'Inked';
  static const String appVersion = '1.0.0';
  
  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 500);
  static const Duration longDuration = Duration(milliseconds: 800);
  
  // Swipe Threshold
  static const double swipeThreshold = 0.3;
  static const double swipeVelocityThreshold = 300;
  
  // Padding & Spacing
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  // Moods
  static const List<String> moods = [
    'happy',
    'sad',
    'peaceful',
    'thrilled',
    'thoughtful',
    'adventurous',
    'melancholic',
    'romantic',
    'mysterious',
    'inspiring',
    'nostalgic',
    'anxious',
  ];
  
  // Mood Descriptions
  static const Map<String, String> moodDescriptions = {
    'happy': 'Uplifting & Feel-Good',
    'sad': 'Deep & Reflective',
    'peaceful': 'Calm & Serene',
    'thrilled': 'Exciting & Thrilling',
    'thoughtful': 'Intellectual & Inspiring',
    'adventurous': 'Bold & Daring',
    'melancholic': 'Bittersweet & Haunting',
    'romantic': 'Love & Connection',
    'mysterious': 'Dark & Intriguing',
    'inspiring': 'Uplifting & Empowering',
    'nostalgic': 'Warm & Reflective',
    'anxious': 'Edgy & Suspenseful',
  };
}
