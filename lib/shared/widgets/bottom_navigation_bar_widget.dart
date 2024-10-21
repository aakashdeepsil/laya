import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/profiles.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Profile profile;

  const MyBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.profile,
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
      icon: Icons.people_alt_outlined,
      label: 'Socials',
      route: '/socials',
    ),
    _NavItem(
      icon: LucideIcons.library,
      label: 'Library',
      route: '/library',
    ),
    _NavItem(
      icon: LucideIcons.userCircle,
      label: 'Profile',
      route: '/profile_page',
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
        items:
            _navItems.map((item) => item.toBottomNavigationBarItem()).toList(),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        onTap: (index) => _onItemTapped(index),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      context.push('/profile_page', extra: widget.profile);
      return;
    }
    context.push(_navItems[index].route);
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  _NavItem({required this.icon, required this.label, required this.route});

  BottomNavigationBarItem toBottomNavigationBarItem() {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
      tooltip: label,
    );
  }
}
