class Quote {
  final String id;
  final String text;
  final String author;
  final String bookId;
  final String mood;
  final DateTime createdAt;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.bookId,
    required this.mood,
    required this.createdAt,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      author: json['author'] ?? 'Unknown',
      bookId: json['bookId'] ?? '',
      mood: json['mood'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'bookId': bookId,
      'mood': mood,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
