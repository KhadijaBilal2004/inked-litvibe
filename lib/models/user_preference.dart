class UserPreference {
  final String userId;
  final List<String> favoriteBooks;
  final List<String> dismissedBooks;
  final Map<String, int> moodFrequency;
  final DateTime lastUpdated;

  UserPreference({
    required this.userId,
    required this.favoriteBooks,
    required this.dismissedBooks,
    required this.moodFrequency,
    required this.lastUpdated,
  });

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    return UserPreference(
      userId: json['userId'] ?? '',
      favoriteBooks: List<String>.from(json['favoriteBooks'] ?? []),
      dismissedBooks: List<String>.from(json['dismissedBooks'] ?? []),
      moodFrequency: Map<String, int>.from(json['moodFrequency'] ?? {}),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'favoriteBooks': favoriteBooks,
      'dismissedBooks': dismissedBooks,
      'moodFrequency': moodFrequency,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
