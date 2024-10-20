class Post {
  final int id;
  final DateTime createdAt;
  final String description;
  final String media;
  final String userId;

  Post({
    required this.id,
    required this.createdAt,
    required this.description,
    required this.media,
    required this.userId,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      description: map['description'],
      media: map['media'],
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'media': media,
      'user_id': userId,
    };
  }
}
