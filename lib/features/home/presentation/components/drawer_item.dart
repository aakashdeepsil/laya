import 'package:flutter/material.dart';

Widget drawerItem({
  required IconData icon,
  required String title,
  bool isSelected = false,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(
      icon,
      color: isSelected ? const Color(0xFFe50914) : Colors.white,
    ),
    title: Text(
      title,
      style: TextStyle(
        color: isSelected ? const Color(0xFFe50914) : Colors.white,
        fontSize: 16,
      ),
    ),
    onTap: onTap,
    selected: isSelected,
    selectedTileColor: const Color(0xFF1e293b),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
  );
}
