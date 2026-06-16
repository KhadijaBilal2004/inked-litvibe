class ReaderSettings {
  final double fontSize;
  final String fontFamily;
  final String themeMode;
  final String readingMode;

  ReaderSettings({
    this.fontSize = 18.0,
    this.fontFamily = 'Georgia',
    this.themeMode = 'light',
    this.readingMode = 'paged',
  });

  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    return ReaderSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 18.0,
      fontFamily: json['fontFamily'] as String? ?? 'Georgia',
      themeMode: json['themeMode'] as String? ?? 'light',
      readingMode: json['readingMode'] as String? ?? 'paged',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'themeMode': themeMode,
      'readingMode': readingMode,
    };
  }

  ReaderSettings copyWith({
    double? fontSize,
    String? fontFamily,
    String? themeMode,
    String? readingMode,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      themeMode: themeMode ?? this.themeMode,
      readingMode: readingMode ?? this.readingMode,
    );
  }
}
