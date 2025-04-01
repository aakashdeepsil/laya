class Bookmark {
  final String id;
  final int page;
  final DateTime timestamp;
  final String note;

  const Bookmark({
    required this.id,
    required this.page,
    required this.timestamp,
    required this.note,
  });

  Bookmark copyWith({
    String? id,
    int? page,
    DateTime? timestamp,
    String? note,
  }) {
    return Bookmark(
      id: id ?? this.id,
      page: page ?? this.page,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }
}
