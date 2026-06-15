class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverImageUrl;
  final List<String> genres;
  final double rating;
  final int pages;
  final String publishedYear;
  final String mood;
  final List<String> quotes;
  
  // New SQLite fields
  final String? gutenbergId;
  final String? language;
  final int? wordCount;
  final String? fullText;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImageUrl,
    required this.genres,
    required this.rating,
    required this.pages,
    required this.publishedYear,
    required this.mood,
    required this.quotes,
    this.gutenbergId,
    this.language,
    this.wordCount,
    this.fullText,
  });

  // Factory constructor for creating a Book instance from JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      description: json['description'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
      rating: (json['rating'] ?? 0.0).toDouble(),
      pages: json['pages'] ?? 0,
      publishedYear: json['publishedYear']?.toString() ?? '',
      mood: json['mood']?.toLowerCase() ?? '',
      quotes: json['quotes'] != null ? List<String>.from(json['quotes']) : [],
    );
  }

  // Factory constructor for creating a Book instance from SQLite Map
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? 'Unknown Title',
      author: map['author'] ?? 'Unknown Author',
      // Generate a short description from the text if available
      description: map['full_text'] != null && map['full_text'].length > 100 
          ? '${map['full_text'].substring(0, 100)}...' 
          : 'No description available.',
      coverImageUrl: map['cover_image_url'] != null 
          ? map['cover_image_url'].toString().contains('placehold.co') && !map['cover_image_url'].toString().contains('.png')
              ? map['cover_image_url'].toString().contains('?')
                  ? map['cover_image_url'].toString().replaceFirst('?', '.png?')
                  : '${map['cover_image_url']}.png'
              : map['cover_image_url'].toString()
          : '', // Parsed from database and formatted for PNG
      genres: [], // Add logic later if needed
      rating: (map['rating'] ?? 0).toDouble(),
      pages: map['word_count'] != null ? map['word_count'] ~/ 250 : 0, // Estimate pages from word count
      publishedYear: 'N/A', // PG metadata doesn't always have year
      mood: map['mood']?.toLowerCase() ?? '',
      quotes: [], // Will be extracted dynamically from full_text in UI
      gutenbergId: map['gutenberg_id']?.toString(),
      language: map['language'],
      wordCount: map['word_count'],
      fullText: map['full_text'],
    );
  }

  // Convert Book instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'genres': genres,
      'rating': rating,
      'pages': pages,
      'publishedYear': publishedYear,
      'mood': mood,
      'quotes': quotes,
      'gutenbergId': gutenbergId,
      'language': language,
      'wordCount': wordCount,
      // intentionally omitting fullText to avoid huge JSON payloads
    };
  }

  // Copy with method
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverImageUrl,
    List<String>? genres,
    double? rating,
    int? pages,
    String? publishedYear,
    String? mood,
    List<String>? quotes,
    String? gutenbergId,
    String? language,
    int? wordCount,
    String? fullText,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      genres: genres ?? this.genres,
      rating: rating ?? this.rating,
      pages: pages ?? this.pages,
      publishedYear: publishedYear ?? this.publishedYear,
      mood: mood ?? this.mood,
      quotes: quotes ?? this.quotes,
      gutenbergId: gutenbergId ?? this.gutenbergId,
      language: language ?? this.language,
      wordCount: wordCount ?? this.wordCount,
      fullText: fullText ?? this.fullText,
    );
  }
}
