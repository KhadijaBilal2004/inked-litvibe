class ReaderSettings {
  final double fontSize;
  final String fontFamily;
  final String themeMode;

  ReaderSettings({
    this.fontSize = 18.0,
    this.fontFamily = 'Georgia',
    this.themeMode = 'light',
  });

  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    return ReaderSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 18.0,
      fontFamily: json['fontFamily'] as String? ?? 'Georgia',
      themeMode: json['themeMode'] as String? ?? 'light',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'themeMode': themeMode,
    };
  }

  ReaderSettings copyWith({
    double? fontSize,
    String? fontFamily,
    String? themeMode,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
