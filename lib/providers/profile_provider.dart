import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/models/user_model.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/services/profile_service.dart';

// Provider for the profile service
final profileServiceProvider = Provider<ProfileService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ProfileService(authService);
});

// Profile user notifier to manage the currently viewed profile
class ProfileNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // Initially return null, will be loaded when fetchProfile is called
    return null;
  }

  Future<void> fetchProfile(String? userId) async {
    state = const AsyncValue.loading();

    try {
      // Get current authenticated user
      final authState = ref.read(authStateProvider);
      final currentUser = authState.valueOrNull;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the profile service and force a fresh fetch
      final profileService = ref.read(profileServiceProvider);

      // Always fetch fresh data from the service
      final user = await profileService.getUserProfile(userId, currentUser);

      if (user == null) {
        throw Exception('Failed to fetch profile data');
      }

      state = AsyncValue.data(user);
      return;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update cached profile data after edits
  void updateProfileData(User updatedUser) {
    if (state.value?.id == updatedUser.id) {
      state = AsyncValue.data(updatedUser);
    }
  }

  Future<User?> getProfileByUserId(String? userId) async {
    // Don't modify state directly if we're just getting data
    try {
      // Get current authenticated user
      final authState = ref.read(authStateProvider);
      final currentUser = authState.valueOrNull;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the profile service
      final profileService = ref.read(profileServiceProvider);

      // Fetch the user profile
      return await profileService.getUserProfile(userId, currentUser);
    } catch (e) {
      // Handle error but don't modify state
      return null;
    }
  }
}

// Profile provider using AsyncNotifier
final profileProvider = AsyncNotifierProvider<ProfileNotifier, User?>(() {
  return ProfileNotifier();
});

// Add a provider to get profile data without modifying state
final userProfileProvider =
    FutureProvider.family<User?, String?>((ref, userId) {
  final profileNotifier = ref.watch(profileProvider.notifier);
  return profileNotifier.getProfileByUserId(userId);
});
