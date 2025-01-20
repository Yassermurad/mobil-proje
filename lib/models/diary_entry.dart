class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final String date;
  final String mood;
  final int color;

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'date': date,
        'mood': mood,
        'color': color,
      };

  static DiaryEntry fromJson(Map<String, dynamic> json) => DiaryEntry(
        id: json['id'] as int?,
        title: json['title'] as String,
        content: json['content'] as String,
        date: json['date'] as String,
        mood: json['mood'] as String,
        color: json['color'] as int,
      );

  DiaryEntry copy({
    int? id,
    String? title,
    String? content,
    String? date,
    String? mood,
    int? color,
  }) =>
      DiaryEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        date: date ?? this.date,
        mood: mood ?? this.mood,
        color: color ?? this.color,
      );
}
