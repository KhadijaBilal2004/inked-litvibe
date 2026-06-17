class Review {
  final String id;
  final String bookId;
  final String bookTitle;
  final double rating;
  final String text;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.rating,
    required this.text,
    required this.timestamp,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      bookTitle: json['bookTitle'] as String? ?? 'Unknown',
      rating: (json['rating'] as num).toDouble(),
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'rating': rating,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
