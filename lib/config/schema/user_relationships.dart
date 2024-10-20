class UserRelationship {
  final int id;
  final DateTime createdAt;
  final String followerId;
  final String followedId;

  UserRelationship({
    required this.id,
    required this.createdAt,
    required this.followerId,
    required this.followedId,
  });

  factory UserRelationship.fromMap(Map<String, dynamic> map) {
    return UserRelationship(
        id: map['id'],
        createdAt: DateTime.parse(map['created_at']),
        followerId: map['follower_id'],
        followedId: map['followed_id']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'follower_id': followerId,
      'followed_id': followedId
    };
  }
}
