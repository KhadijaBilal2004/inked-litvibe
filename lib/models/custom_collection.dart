class CustomCollection {
  final String id;
  final String name;
  final List<String> bookIds;

  CustomCollection({
    required this.id,
    required this.name,
    required this.bookIds,
  });

  factory CustomCollection.fromJson(Map<String, dynamic> json) {
    return CustomCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      bookIds: List<String>.from(json['bookIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bookIds': bookIds,
    };
  }

  CustomCollection copyWith({
    String? id,
    String? name,
    List<String>? bookIds,
  }) {
    return CustomCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      bookIds: bookIds ?? List<String>.from(this.bookIds),
    );
  }
}
