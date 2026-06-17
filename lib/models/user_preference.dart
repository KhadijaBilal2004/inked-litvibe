import 'reader_settings.dart';
import 'saved_quote.dart';
import 'bookmark.dart';
import 'highlight.dart';
import 'custom_collection.dart';
import 'review.dart';

class UserPreference {
  final String userId;
  final List<String> favoriteBooks;
  final List<String> dismissedBooks;
  final List<String> toReadBooks;
  final List<String> readBooks;
  final Map<String, int> moodFrequency;
  final DateTime lastUpdated;
  final Map<String, double> readingProgress;
  final ReaderSettings readerSettings;
  final List<SavedQuote> savedQuotes;
  final List<Bookmark> bookmarks;
  final List<Highlight> highlights;
  final List<CustomCollection> collections;
  final List<Review> reviews;

  UserPreference({
    required this.userId,
    required this.favoriteBooks,
    required this.dismissedBooks,
    required this.toReadBooks,
    required this.readBooks,
    required this.moodFrequency,
    required this.lastUpdated,
    required this.readingProgress,
    required this.readerSettings,
    required this.savedQuotes,
    required this.bookmarks,
    required this.highlights,
    required this.collections,
    required this.reviews,
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
      readingProgress: Map<String, double>.from(json['readingProgress'] ?? {}),
      readerSettings: json['readerSettings'] != null 
          ? ReaderSettings.fromJson(Map<String, dynamic>.from(json['readerSettings']))
          : ReaderSettings(),
      savedQuotes: json['savedQuotes'] != null
          ? (json['savedQuotes'] as List).map((e) => SavedQuote.fromJson(Map<String, dynamic>.from(e))).toList()
          : [],
      bookmarks: json['bookmarks'] != null
          ? (json['bookmarks'] as List).map((e) => Bookmark.fromJson(Map<String, dynamic>.from(e))).toList()
          : [],
      highlights: json['highlights'] != null
          ? (json['highlights'] as List).map((e) => Highlight.fromJson(Map<String, dynamic>.from(e))).toList()
          : [],
      collections: json['collections'] != null
          ? (json['collections'] as List).map((e) => CustomCollection.fromJson(Map<String, dynamic>.from(e))).toList()
          : [],
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((e) => Review.fromJson(Map<String, dynamic>.from(e))).toList()
          : [],
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
      'readingProgress': readingProgress,
      'readerSettings': readerSettings.toJson(),
      'savedQuotes': savedQuotes.map((q) => q.toJson()).toList(),
      'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
      'highlights': highlights.map((h) => h.toJson()).toList(),
      'collections': collections.map((c) => c.toJson()).toList(),
      'reviews': reviews.map((r) => r.toJson()).toList(),
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
    Map<String, double>? readingProgress,
    ReaderSettings? readerSettings,
    List<SavedQuote>? savedQuotes,
    List<Bookmark>? bookmarks,
    List<Highlight>? highlights,
    List<CustomCollection>? collections,
    List<Review>? reviews,
  }) {
    return UserPreference(
      userId: userId ?? this.userId,
      favoriteBooks: favoriteBooks ?? List<String>.from(this.favoriteBooks),
      dismissedBooks: dismissedBooks ?? List<String>.from(this.dismissedBooks),
      toReadBooks: toReadBooks ?? List<String>.from(this.toReadBooks),
      readBooks: readBooks ?? List<String>.from(this.readBooks),
      moodFrequency: moodFrequency ?? Map<String, int>.from(this.moodFrequency),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      readingProgress: readingProgress ?? Map<String, double>.from(this.readingProgress),
      readerSettings: readerSettings ?? this.readerSettings,
      savedQuotes: savedQuotes ?? List<SavedQuote>.from(this.savedQuotes),
      bookmarks: bookmarks ?? List<Bookmark>.from(this.bookmarks),
      highlights: highlights ?? List<Highlight>.from(this.highlights),
      collections: collections ?? List<CustomCollection>.from(this.collections),
      reviews: reviews ?? List<Review>.from(this.reviews),
    );
  }
}
