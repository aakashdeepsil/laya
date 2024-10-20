import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final int index;

  const MyBottomNavigationBar({super.key, required this.index});

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15.0),
        topRight: Radius.circular(15.0),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: widget.index,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: 'Home',
            tooltip: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.search),
            label: 'Explore',
            tooltip: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Socials',
            tooltip: 'Socials',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.library),
            label: 'Library',
            tooltip: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.userCircle),
            label: 'Profile',
            tooltip: 'Profile',
          ),
        ],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        onTap: (value) {
          switch (value) {
            case 0:
              context.push('/home');
              break;
            case 1:
              context.push('/explore');
              break;
            case 2:
              context.push('/socials');
              break;
            case 3:
              context.push('/library');
              break;
            case 4:
              context.push(
                '/profile/${Supabase.instance.client.auth.currentUser?.id}',
              );
              break;
            default:
              break;
          }
        },
      ),
    );
  }
}
