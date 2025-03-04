import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/features/home/presentation/components/drawer_item.dart';
import 'dart:developer' as developer;

import 'package:laya/providers/auth_provider.dart';

Widget navigationDrawer(BuildContext context, dynamic user, WidgetRef ref) {
  developer.log(
    'Building navigation drawer for user: ${user?.id ?? "guest"}',
    name: 'HomePage',
  );

  return Drawer(
    backgroundColor: const Color(0xFF0f172a),
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        // Drawer header with user profile
        UserAccountsDrawerHeader(
          decoration: const BoxDecoration(
            color: Color(0xFF1e293b),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage:
                user?.avatarUrl != null && user!.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
            child: user?.avatarUrl == null || user!.avatarUrl.isEmpty
                ? const Icon(Icons.person, size: 40, color: Color(0xFF0f172a))
                : null,
          ),
          accountName: Text(
            user != null ? '${user.firstName} ${user.lastName}' : 'Guest User',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          accountEmail: Text(
            user?.email ?? 'Not signed in',
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ),

        // Navigation items
        drawerItem(
          icon: Icons.home,
          title: 'Home',
          isSelected: true,
          onTap: () {
            developer.log('Drawer: Home selected', name: 'HomePage');
            Navigator.pop(context);
          },
        ),

        drawerItem(
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
          icon: Icons.explore,
          title: 'Explore',
          onTap: () {
            developer.log(
              'Drawer: Explore selected, navigating',
              name: 'HomePage',
            );
            Navigator.pop(context);
            context.go('/explore');
          },
        ),

        drawerItem(
          icon: Icons.bookmarks,
          title: 'Bookmarks',
          onTap: () {
            developer.log(
              'Drawer: Bookmarks selected, navigating',
              name: 'HomePage',
            );
            Navigator.pop(context);
            context.go('/bookmarks');
          },
        ),

        const Divider(color: Colors.white24),

        drawerItem(
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
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {
            developer.log(
              'Drawer: Settings selected, navigating',
              name: 'HomePage',
            );
            Navigator.pop(context);
            context.go('/settings');
          },
        ),

        const Divider(color: Colors.white24),

        drawerItem(
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
                    const SnackBar(
                      content: Text('Error signing out. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),

        if (user == null)
          drawerItem(
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
  );
}
