import 'package:flutter/material.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/shared/widgets/user_profile/activity_view_widget.dart';

class UserProfileTabs extends StatefulWidget {
  final User user;
  final User currentUser;

  const UserProfileTabs({
    super.key,
    required this.user,
    required this.currentUser,
  });

  @override
  State<UserProfileTabs> createState() => _UserProfileTabsState();
}

class _UserProfileTabsState extends State<UserProfileTabs> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Column(
        children: [
          TabBar(
            tabs: const [Tab(text: 'Series')],
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          SizedBox(
            height: screenHeight * 0.4,
            child: TabBarView(children: [ActivityView(user: widget.user)]),
          ),
        ],
      ),
    );
  }
}
