import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/user.dart';
import 'package:lucide_icons/lucide_icons.dart';

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  BottomNavigationBarItem toBottomNavigationBarItem() =>
      BottomNavigationBarItem(
        icon: Icon(icon),
        label: label,
        tooltip: label,
      );
}

class MyBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final User user;

  const MyBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.user,
  });

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  final List<_NavItem> _navItems = [
    _NavItem(
      icon: LucideIcons.home,
      label: 'Home',
      route: '/home',
    ),
    _NavItem(
      icon: LucideIcons.search,
      label: 'Explore',
      route: '/explore',
    ),
    _NavItem(
      icon: LucideIcons.library,
      label: 'Library',
      route: '/library',
    ),
    _NavItem(
      icon: LucideIcons.userCircle,
      label: 'Profile',
      route: '/user_profile_page',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15.0),
        topRight: Radius.circular(15.0),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: widget.currentIndex,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: _navItems
            .map(
              (item) => item.toBottomNavigationBarItem(),
            )
            .toList(),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        onTap: (index) {
          print('index: $index');
          _onItemTapped(index);
        },
      ),
    );
  }

  void _onItemTapped(int index) => index == 3
      ? context.push(
          _navItems[index].route,
          extra: {
            'user': widget.user,
            'currentUser': widget.user,
          },
        )
      : context.push(
          _navItems[index].route,
          extra: widget.user,
        );
}
