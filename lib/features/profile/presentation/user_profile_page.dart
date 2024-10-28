import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/shared/widgets/bottom_navigation_bar_widget.dart';
import 'package:laya/shared/widgets/user_profile/user_profile_header_widget.dart';
import 'package:laya/shared/widgets/user_profile/user_profile_tabs_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserProfilePage extends StatefulWidget {
  final User user;

  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  void showAddPostModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenHeight * 0.02),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenHeight * 0.02,
                    vertical: screenHeight * 0.01,
                  ),
                  child: Text(
                    'Share Your Thoughts and Stories',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(),
                _buildOptionTile(
                  context: context,
                  icon: LucideIcons.filePlus,
                  title: 'Publish New Content',
                  subtitle: 'Share your creative content',
                  onTap: () => context.push(
                    '/create_content_page',
                    extra: widget.user,
                  ),
                  colorScheme: Theme.of(context).colorScheme,
                  screenHeight: screenHeight,
                ),
                _buildOptionTile(
                  context: context,
                  icon: LucideIcons.messageSquarePlus,
                  title: 'Create New Post',
                  subtitle: 'Share your thoughts',
                  onTap: () => context.push(
                    '/create_post_page',
                    extra: widget.user,
                  ),
                  colorScheme: Theme.of(context).colorScheme,
                  screenHeight: screenHeight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required double screenHeight,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenHeight * 0.02,
          vertical: screenHeight * 0.015,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenHeight * 0.012),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: screenHeight * 0.028,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(width: screenHeight * 0.02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: screenHeight * 0.018,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: screenHeight * 0.014,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: screenHeight * 0.024,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.username,
          style: TextStyle(
            fontSize: screenHeight * 0.02,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => showAddPostModal(context),
            icon: Icon(
              LucideIcons.upload,
              size: screenHeight * 0.02,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(LucideIcons.bell, size: screenHeight * 0.02),
          ),
          IconButton(
            icon: Icon(LucideIcons.settings, size: screenHeight * 0.02),
            onPressed: () => context.push(
              '/user_profile_settings_page',
              extra: widget.user,
            ),
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserProfileHeader(user: widget.user),
            UserProfileTabs(user: widget.user),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 4,
        user: widget.user,
      ),
    );
  }
}
