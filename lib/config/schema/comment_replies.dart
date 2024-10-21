class CommentReply {
  final int id;
  final DateTime createdAt;
  final int commentId;
  final String userId;
  final String replyText;

  CommentReply({
    required this.id,
    required this.createdAt,
    required this.commentId,
    required this.userId,
    required this.replyText,
  });

  factory CommentReply.fromMap(Map<String, dynamic> map) {
    return CommentReply(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      commentId: map['comment_id'],
      userId: map['user_id'],
      replyText: map['reply_text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'comment_id': commentId,
      'user_id': userId,
      'reply_text': replyText,
    };
  }
}
