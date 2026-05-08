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
  final String mongodbId;

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
    required this.mongodbId,
  });

  // Factory constructor for creating a Book instance from JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      description: json['description'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      pages: json['pages'] ?? 0,
      publishedYear: json['publishedYear'] ?? '',
      mood: json['mood'] ?? '',
      quotes: List<String>.from(json['quotes'] ?? []),
      mongodbId: json['_id'] ?? '',
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
      '_id': mongodbId,
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
    String? mongodbId,
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
      mongodbId: mongodbId ?? this.mongodbId,
    );
  }
}
