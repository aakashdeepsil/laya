class CommentLike {
  final int id;
  final DateTime createdAt;
  final int commentId;
  final bool isLike;
  final String userId;

  CommentLike({
    required this.id,
    required this.createdAt,
    required this.commentId,
    required this.isLike,
    required this.userId,
  });

  factory CommentLike.fromMap(Map<String, dynamic> map) {
    return CommentLike(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      commentId: map['comment_id'],
      isLike: map['is_like'],
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'comment_id': commentId,
      'is_like': isLike,
      'user_id': userId,
    };
  }
}
