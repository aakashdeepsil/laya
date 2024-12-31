import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/shared/widgets/bottom_navigation_bar_widget.dart';
import 'package:laya/shared/widgets/user_profile/bottom_modal_sheet_widget.dart';
import 'package:laya/shared/widgets/user_profile/user_profile_header_widget.dart';
import 'package:laya/shared/widgets/user_profile/user_profile_tabs_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserProfilePage extends StatefulWidget {
  final User user;
  final User currentUser;

  const UserProfilePage({
    super.key,
    required this.user,
    required this.currentUser,
  });

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
      builder: (BuildContext context) => BottomModalSheet(user: widget.user),
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
            icon: Icon(LucideIcons.upload, size: screenHeight * 0.02),
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserProfileHeader(
              user: widget.user,
              currentUser: widget.currentUser,
            ),
            UserProfileTabs(
              user: widget.user,
              currentUser: widget.currentUser,
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 3,
        user: widget.currentUser,
      ),
    );
  }
}
