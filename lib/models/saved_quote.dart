class SavedQuote {
  final String id;
  final String bookId;
  final String bookTitle;
  final String author;
  final String text;
  final DateTime timestamp;

  SavedQuote({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.author,
    required this.text,
    required this.timestamp,
  });

  factory SavedQuote.fromJson(Map<String, dynamic> json) {
    return SavedQuote(
      id: json['id'] ?? '',
      bookId: json['bookId'] ?? '',
      bookTitle: json['bookTitle'] ?? '',
      author: json['author'] ?? '',
      text: json['text'] ?? '',
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
      'author': author,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
