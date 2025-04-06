import 'dart:developer' as developer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/home/presentation/components/drawer_item.dart';
import 'package:laya/models/user_model.dart';
import 'package:laya/providers/auth_provider.dart';

Widget navigationDrawer(BuildContext context, User? user, WidgetRef ref) {
  developer.log(
    'Building navigation drawer for user: ${user?.id}',
    name: 'HomePage',
  );

  final colorScheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Drawer(
    backgroundColor: colorScheme.surface,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        // Drawer header with user profile
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage:
                        user?.avatarUrl != null && user!.avatarUrl.isNotEmpty
                            ? CachedNetworkImageProvider(user.avatarUrl)
                            : null,
                    child: user?.avatarUrl == null || user!.avatarUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : colorScheme.primary.withValues(alpha: 0.5),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null
                              ? '${user.firstName} ${user.lastName}'
                              : 'Guest User',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'Not signed in',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Navigation items
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              drawerItem(
                context: context,
                icon: Icons.home,
                title: 'Home',
                isSelected: true,
                onTap: () {
                  developer.log('Drawer: Home selected', name: 'HomePage');
                  Navigator.pop(context);
                },
              ),
              drawerItem(
                context: context,
                icon: Icons.auto_stories,
                title: 'My Library',
                onTap: () {
                  developer.log(
                    'Drawer: My Library selected, navigating',
                    name: 'HomePage',
                  );
                  Navigator.pop(context);
                  context.go('/library');
                },
              ),
              drawerItem(
                context: context,
                icon: Icons.explore,
                title: 'Explore',
                onTap: () {
                  developer.log(
                    'Drawer: Explore selected, navigating',
                    name: 'HomePage',
                  );
                  Navigator.pop(context);
                  context.go('/search');
                },
              ),
              drawerItem(
                context: context,
                icon: Icons.person,
                title: 'Profile',
                onTap: () {
                  developer.log(
                    'Drawer: Profile selected, navigating',
                    name: 'HomePage',
                  );
                  Navigator.pop(context);
                  context.go('/profile');
                },
              ),
              drawerItem(
                context: context,
                icon: Icons.smart_toy_rounded,
                title: 'AI Assistant',
                onTap: () {
                  developer.log(
                    'Drawer: AI Assistant selected, navigating',
                    name: 'HomePage',
                  );
                  Navigator.pop(context);
                  context.go('/ai_dashboard');
                },
              ),
              drawerItem(
                context: context,
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  developer.log(
                    'Drawer: Settings selected, navigating',
                    name: 'HomePage',
                  );
                  Navigator.pop(context);
                  context.push('/profile_settings');
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        Divider(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : colorScheme.outline.withValues(alpha: 0.1),
          height: 1,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              drawerItem(
                context: context,
                icon: Icons.help,
                title: 'Help & Feedback',
                onTap: () {
                  developer.log(
                    'Drawer: Help & Feedback selected',
                    name: 'HomePage',
                  );
                  Navigator.pop(context);
                  // Handle help action
                },
              ),
              if (user != null)
                drawerItem(
                  context: context,
                  icon: Icons.logout,
                  title: 'Sign Out',
                  onTap: () async {
                    developer.log(
                      'Drawer: Sign Out selected, logging out user',
                      name: 'HomePage',
                    );
                    Navigator.pop(context);
                    final authService = ref.read(authServiceProvider);

                    try {
                      await authService.signOut();
                      developer.log(
                        'User successfully signed out',
                        name: 'HomePage',
                      );
                      if (context.mounted) {
                        context.go('/login');
                      }
                    } catch (e) {
                      developer.log('Error signing out: $e',
                          name: 'HomePage', error: e);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error signing out. Please try again.'),
                            backgroundColor: colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              if (user == null)
                drawerItem(
                  context: context,
                  icon: Icons.login,
                  title: 'Sign In',
                  onTap: () {
                    developer.log(
                      'Drawer: Sign In selected, navigating to login',
                      name: 'HomePage',
                    );
                    Navigator.pop(context);
                    context.go('/login');
                  },
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
