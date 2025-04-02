class ReadingProgress {
  final String id;
  final String contentId;
  final String userId;
  final int currentPage;
  final double progress;
  final DateTime lastRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReadingProgress({
    required this.id,
    required this.contentId,
    required this.userId,
    required this.currentPage,
    required this.progress,
    required this.lastRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      id: json['id'],
      contentId: json['content_id'],
      userId: json['user_id'],
      currentPage: json['current_page'],
      progress: json['progress'].toDouble(),
      lastRead: DateTime.parse(json['last_read']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content_id': contentId,
        'user_id': userId,
        'current_page': currentPage,
        'progress': progress,
        'last_read': lastRead.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ReadingProgress copyWith({
    String? id,
    String? contentId,
    String? userId,
    int? currentPage,
    double? progress,
    DateTime? lastRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReadingProgress(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      userId: userId ?? this.userId,
      currentPage: currentPage ?? this.currentPage,
      progress: progress ?? this.progress,
      lastRead: lastRead ?? this.lastRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReadingProgress(id: $id, contentId: $contentId, userId: $userId, currentPage: $currentPage, progress: $progress, lastRead: $lastRead)';
  }
}
