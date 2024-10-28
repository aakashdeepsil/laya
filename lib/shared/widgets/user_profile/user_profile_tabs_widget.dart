import 'package:flutter/material.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/shared/widgets/user_profile/activity_view_widget.dart';
import 'package:laya/shared/widgets/user_profile/content_grid_view_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserProfileTabs extends StatefulWidget {
  final User user;

  const UserProfileTabs({super.key, required this.user});

  @override
  State<UserProfileTabs> createState() => _UserProfileTabsState();
}

class _UserProfileTabsState extends State<UserProfileTabs> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  LucideIcons.grid,
                  size: screenHeight * 0.03,
                ),
              ),
              Tab(
                icon: Icon(
                  LucideIcons.activity,
                  size: screenHeight * 0.03,
                ),
              ),
            ],
            indicatorColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            labelColor: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(
            height: screenHeight * 0.4,
            child: TabBarView(
              children: [
                ContentGridView(user: widget.user),
                ActivityView(user: widget.user),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
