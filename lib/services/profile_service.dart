import 'dart:developer' as developer;
import 'package:laya/models/user_model.dart';
import 'package:laya/services/auth_service.dart';

class ProfileService {
  final AuthService _authService;

  ProfileService(this._authService);

  /// Fetches a user profile by ID
  /// If userId is null or matches current user ID, returns current user
  Future<User?> getUserProfile(String? userId, User currentUser) async {
    try {
      developer.log(
        'ProfileService: Fetching profile data',
        name: 'ProfileService',
      );

      // If no userId provided or it matches current user, return current user
      if (userId == null || userId == currentUser.id) {
        developer.log(
          'ProfileService: Returning current user profile',
          name: 'ProfileService',
        );
        return currentUser;
      }

      // Otherwise fetch the specified user profile
      developer.log(
        'ProfileService: Fetching other user profile: $userId',
        name: 'ProfileService',
      );
      final user = await _authService.getUserById(userId);

      if (user == null) {
        developer.log(
          'ProfileService: User profile not found',
          name: 'ProfileService',
        );
      } else {
        developer.log(
          'ProfileService: User profile retrieved successfully',
          name: 'ProfileService',
        );
      }

      return user;
    } catch (e) {
      developer.log(
        'ProfileService: Error fetching profile: $e',
        name: 'ProfileService',
        error: e,
      );
      rethrow; // Rethrow to allow providers to handle errors
    }
  }

  // Add other profile-related methods here
  // e.g., updateUserBio(), followUser(), etc.
}
