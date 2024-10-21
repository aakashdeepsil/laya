class Comment {
  final int id;
  final String commentText;
  final DateTime createdAt;
  final int postId;
  final String userId;

  Comment({
    required this.id,
    required this.commentText,
    required this.createdAt,
    required this.postId,
    required this.userId,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      commentText: map['comment_text'],
      createdAt: DateTime.parse(map['created_at']),
      postId: map['post_id'],
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'comment_text': commentText,
      'created_at': createdAt.toIso8601String(),
      'post_id': postId,
      'user_id': userId,
    };
  }
}
