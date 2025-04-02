import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/profile/presentation/components/profile_header.dart';
import 'package:laya/features/profile/presentation/components/profile_tabs.dart';
import 'package:laya/models/user_model.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/providers/profile_provider.dart';
import 'package:laya/providers/series_provider.dart';
import 'package:laya/features/profile/presentation/components/create_content_bottom_sheet.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    developer.log('ProfileScreen initialized', name: 'ProfileScreen');
    // Schedule the profile data load for after the build
    Future.microtask(() {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    try {
      // Get user ID from auth provider instead of potentially null profile
      final userId = ref.read(authStateProvider).valueOrNull?.id;

      if (userId != null) {
        // Use Future to delay the provider modification
        await Future(() {
          ref.read(profileProvider.notifier).fetchProfile(userId);
          // Refresh the user's series list
          ref.read(userSeriesProvider(userId).notifier).refresh();
        });

        if (mounted) {
          setState(() => _initialLoadDone = true);
        }

        developer.log('Profile refreshed successfully', name: 'ProfileScreen');
      } else {
        developer.log(
          'Cannot load profile: User ID is null',
          name: 'ProfileScreen',
        );
        // Don't show error for initial auth state being null
        if (_initialLoadDone) {
          _showErrorSnackBar('Cannot load profile: Not authenticated');
        }
      }
    } catch (e) {
      developer.log('Error refreshing profile: $e', name: 'ProfileScreen');
      // Only show error if it's not the initial load
      if (_initialLoadDone) {
        _showErrorSnackBar('Failed to refresh profile data');
      }
    }
  }

  // Extract error handling to a separate method
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Remove the direct provider modification from here
    // The profile data will be loaded through the provider's watch
  }

  void createContentBottomSheet(BuildContext context, User user) {
    developer.log('Showing add post modal', name: 'ProfileScreen');
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) => const CreateContentBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building ProfileScreen UI', name: 'ProfileScreen');

    // Watch auth and profile providers
    final authState = ref.watch(authStateProvider);
    final profileState = ref.watch(profileProvider);

    // Get current user and profile user
    final currentUser = authState.valueOrNull;
    final profileUser = profileState.valueOrNull;

    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surface;
    final secondaryColor = colorScheme.secondary;
    final surfaceColor = colorScheme.surface;

    // Handle loading state
    if (authState.isLoading || profileState.isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => context.go('/home'),
          ),
          title: Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        body: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: secondaryColor,
            ),
          ),
        ),
      );
    }

    // Handle error state
    if (profileState.hasError || currentUser == null || profileUser == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => context.go('/home'),
          ),
          title: const Text('Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: ${profileState.hasError ? profileState.error.toString() : "User not found"}',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfileData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final isCurrentUser = profileUser.id == currentUser.id;
    developer.log(
      'Viewing ${isCurrentUser ? "own" : "other user's"} profile',
      name: 'ProfileScreen',
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          profileUser.username,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          // Only show these buttons if viewing own profile
          if (isCurrentUser) ...[
            IconButton(
              onPressed: () => createContentBottomSheet(context, profileUser),
              icon: Icon(
                LucideIcons.plusCircle,
                size: 20,
                color: colorScheme.onSurface,
              ),
              tooltip: 'Create content',
              style: IconButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                backgroundColor: Colors.transparent,
              ),
            ),
            IconButton(
              onPressed: () {
                developer.log(
                  'Notifications button pressed',
                  name: 'ProfileScreen',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Notifications coming soon',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.black.withValues(alpha: 0.8),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              icon: Icon(
                LucideIcons.bell,
                size: 20,
                color: colorScheme.onSurface,
              ),
              tooltip: 'Notifications',
              style: IconButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                backgroundColor: Colors.transparent,
              ),
            ),
            IconButton(
              icon: Icon(
                LucideIcons.settings,
                size: 20,
                color: colorScheme.onSurface,
              ),
              onPressed: () {
                developer.log(
                  'Settings button pressed',
                  name: 'ProfileScreen',
                );
                context.push('/profile_settings');
              },
              tooltip: 'Settings',
              style: IconButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadProfileData(),
        displacement: 40,
        color: secondaryColor,
        backgroundColor: surfaceColor,
        strokeWidth: 2.5,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const ProfileHeader(),
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              const ProfileTabs(),
            ],
          ),
        ),
      ),
    );
  }
}
