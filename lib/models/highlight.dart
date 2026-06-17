class Highlight {
  final String id;
  final String bookId;
  final String bookTitle;
  final String textSnippet;
  final String colorHex;
  final String note;
  final DateTime timestamp;

  Highlight({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.textSnippet,
    this.colorHex = '#FFFF00', // default yellow
    this.note = '',
    required this.timestamp,
  });

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      bookTitle: json['bookTitle'] as String? ?? 'Unknown Book',
      textSnippet: json['textSnippet'] as String,
      colorHex: json['colorHex'] as String? ?? '#FFFF00',
      note: json['note'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'textSnippet': textSnippet,
      'colorHex': colorHex,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
