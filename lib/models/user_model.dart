/// Defines the possible roles a user can have in the system
enum UserRole { user, creator, admin }

/// Represents a user in the application with their profile information
class User {
  /// Unique identifier for the user
  final String id;
  /// User's email address
  final String email;
  /// Username for display and identification
  final String username;
  /// User's first name
  final String firstName;
  /// User's last name
  final String lastName;
  /// URL to user's profile picture
  final String avatarUrl;
  /// Whether the user's email has been verified
  final bool isVerified;
  /// User's permission level in the system
  final UserRole role;
  /// When the user account was created
  final DateTime createdAt;
  /// When the user account was last updated
  final DateTime updatedAt;
  /// When the user last logged in (null if never)
  final DateTime? lastLoginAt;

  /// Creates a new User instance
  const User({
    required this.id,
    required this.email,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.avatarUrl = '',
    this.isVerified = false,
    this.role = UserRole.user,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  /// Creates a User from Firebase authentication data
  factory User.fromFirebase(dynamic firebaseUser,
      {Map<String, dynamic>? userData}) {
    final now = DateTime.now();

    // Use provided userData or create default values
    final data = userData ?? {};

    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: data['username'] ?? firebaseUser.email?.split('@').first ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      avatarUrl: data['avatarUrl'] ?? firebaseUser.photoURL ?? '',
      isVerified: firebaseUser.emailVerified,
      role: _parseRole(data['role']),
      createdAt:
          data['createdAt'] != null ? DateTime.parse(data['createdAt']) : now,
      updatedAt: now,
      lastLoginAt: now,
    );
  }

  /// Converts string role to UserRole enum
  static UserRole _parseRole(dynamic role) {
    if (role == 'admin') return UserRole.admin;
    if (role == 'creator') return UserRole.creator;
    return UserRole.user;
  }

  /// Converts user data to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  /// Creates a new User with some updated properties
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    bool? isVerified,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

/// Extension providing helpful user properties
extension UserX on User {
  /// User's full name (first + last)
  String get fullName => '$firstName $lastName'.trim();
  /// Whether user has a profile picture
  bool get hasAvatar => avatarUrl.isNotEmpty;
  /// Whether user has required profile data
  bool get isComplete => username.isNotEmpty && email.isNotEmpty;
  /// Whether user has admin privileges
  bool get isAdmin => role == UserRole.admin;
  /// Whether user has creator privileges
  bool get isCreator => role == UserRole.creator;
}
