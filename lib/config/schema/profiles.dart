class Profile {
  final String id;
  final String avatarUrl;
  final String bio;
  final DateTime createdAt;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime updatedAt;
  final String username;

  Profile({
    required this.id,
    required this.avatarUrl,
    required this.bio,
    required this.createdAt,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.updatedAt,
    required this.username,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      avatarUrl: map['avatar_url'],
      bio: map['bio'],
      createdAt: DateTime.parse(map['created_at']),
      email: map['email'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      updatedAt: DateTime.parse(map['updated_at']),
      username: map['username'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'avatar_url': avatarUrl,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'updated_at': updatedAt.toIso8601String(),
      'username': username,
    };
  }
}