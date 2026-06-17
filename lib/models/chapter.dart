class Chapter {
  final String id;
  final String title;
  final int offset;

  Chapter({
    required this.id,
    required this.title,
    required this.offset,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      title: json['title'] as String,
      offset: json['offset'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'offset': offset,
    };
  }
}
