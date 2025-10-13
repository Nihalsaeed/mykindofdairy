class JournalEntry {
  final String id; // Date in YYYY-MM-DD format
  String content;

  JournalEntry({
    required this.id,
    required this.content,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
    };
  }

  // Create from JSON
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      content: json['content'],
    );
  }
}