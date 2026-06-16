class Bookmark {
  final String id;
  final String bookId;
  final String bookTitle;
  final String textSnippet;
  final double offset; // character offset or scroll offset
  final DateTime timestamp;

  Bookmark({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.textSnippet,
    required this.offset,
    required this.timestamp,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] ?? '',
      bookId: json['bookId'] ?? '',
      bookTitle: json['bookTitle'] ?? '',
      textSnippet: json['textSnippet'] ?? '',
      offset: (json['offset'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'textSnippet': textSnippet,
      'offset': offset,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
