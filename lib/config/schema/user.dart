enum UserRole {
  user,
  creator,
  admin;

  bool get isAdmin => this == UserRole.admin;
  bool get isCreator => this == UserRole.creator;
  bool get isUser => this == UserRole.user;
}

class User {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String avatarUrl;
  final String bio;
  final bool isVerified;
  final bool isActive;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.avatarUrl = '',
    this.bio = '',
    this.isVerified = false,
    this.isActive = true,
    this.role = UserRole.user,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get hasAvatar => avatarUrl.isNotEmpty;
  bool get isComplete => username.isNotEmpty && email.isNotEmpty;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        username: json['username'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        isVerified: json['is_verified'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        role: UserRole.values.firstWhere(
          (role) => role.name == (json['role'] as String?),
          orElse: () => UserRole.user,
        ),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        lastLoginAt: json['last_login_at'] != null
            ? DateTime.parse(json['last_login_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'avatar_url': avatarUrl,
        'bio': bio,
        'is_verified': isVerified,
        'is_active': isActive,
        'role': role.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'last_login_at': lastLoginAt?.toIso8601String(),
      };

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? bio,
    bool? isVerified,
    bool? isActive,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        username: username ?? this.username,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        bio: bio ?? this.bio,
        isVerified: isVerified ?? this.isVerified,
        isActive: isActive ?? this.isActive,
        role: role ?? this.role,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          username == other.username;

  @override
  int get hashCode => Object.hash(id, email, username);

  @override
  String toString() => 'User(id: $id, username: $username, email: $email)';
}
