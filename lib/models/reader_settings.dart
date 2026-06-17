class ReaderSettings {
  final double fontSize;
  final String fontFamily;
  final String themeMode;
  final String readingMode;
  final double lineSpacing;
  final double margin;

  ReaderSettings({
    this.fontSize = 18.0,
    this.fontFamily = 'Georgia',
    this.themeMode = 'light',
    this.readingMode = 'paged',
    this.lineSpacing = 1.5,
    this.margin = 16.0,
  });

  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    return ReaderSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 18.0,
      fontFamily: json['fontFamily'] as String? ?? 'Georgia',
      themeMode: json['themeMode'] as String? ?? 'light',
      readingMode: json['readingMode'] as String? ?? 'paged',
      lineSpacing: (json['lineSpacing'] as num?)?.toDouble() ?? 1.5,
      margin: (json['margin'] as num?)?.toDouble() ?? 16.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'themeMode': themeMode,
      'readingMode': readingMode,
      'lineSpacing': lineSpacing,
      'margin': margin,
    };
  }

  ReaderSettings copyWith({
    double? fontSize,
    String? fontFamily,
    String? themeMode,
    String? readingMode,
    double? lineSpacing,
    double? margin,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      themeMode: themeMode ?? this.themeMode,
      readingMode: readingMode ?? this.readingMode,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      margin: margin ?? this.margin,
    );
  }
}
