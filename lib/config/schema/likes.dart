class Like {
  final int id;
  final DateTime createdAt;
  final int postId;
  final String userId;

  Like({
    required this.id,
    required this.createdAt,
    required this.postId,
    required this.userId,
  });

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      postId: map['post_id'],
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'post_id': postId,
      'user_id': userId,
    };
  }
}
