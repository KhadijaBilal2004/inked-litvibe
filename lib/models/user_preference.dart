class UserPreference {
  final String userId;
  final List<String> favoriteBooks;
  final List<String> dismissedBooks;
  final List<String> toReadBooks;
  final List<String> readBooks;
  final Map<String, int> moodFrequency;
  final DateTime lastUpdated;

  UserPreference({
    required this.userId,
    required this.favoriteBooks,
    required this.dismissedBooks,
    required this.toReadBooks,
    required this.readBooks,
    required this.moodFrequency,
    required this.lastUpdated,
  });

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    return UserPreference(
      userId: json['userId'] ?? '',
      favoriteBooks: List<String>.from(json['favoriteBooks'] ?? []),
      dismissedBooks: List<String>.from(json['dismissedBooks'] ?? []),
      toReadBooks: List<String>.from(json['toReadBooks'] ?? []),
      readBooks: List<String>.from(json['readBooks'] ?? []),
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
      'toReadBooks': toReadBooks,
      'readBooks': readBooks,
      'moodFrequency': moodFrequency,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  UserPreference copyWith({
    String? userId,
    List<String>? favoriteBooks,
    List<String>? dismissedBooks,
    List<String>? toReadBooks,
    List<String>? readBooks,
    Map<String, int>? moodFrequency,
    DateTime? lastUpdated,
  }) {
    return UserPreference(
      userId: userId ?? this.userId,
      favoriteBooks: favoriteBooks ?? List<String>.from(this.favoriteBooks),
      dismissedBooks: dismissedBooks ?? List<String>.from(this.dismissedBooks),
      toReadBooks: toReadBooks ?? List<String>.from(this.toReadBooks),
      readBooks: readBooks ?? List<String>.from(this.readBooks),
      moodFrequency: moodFrequency ?? Map<String, int>.from(this.moodFrequency),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
