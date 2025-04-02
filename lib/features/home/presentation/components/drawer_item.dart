import 'package:flutter/material.dart';

Widget drawerItem({
  required IconData icon,
  required String title,
  bool isSelected = false,
  required VoidCallback onTap,
  required BuildContext context,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.white.withOpacity(0.1)
                  : colorScheme.primary.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : colorScheme.primary.withOpacity(0.2),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? (isDark ? Colors.white : colorScheme.primary)
                  : (isDark
                      ? Colors.white.withOpacity(0.7)
                      : colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected
                        ? (isDark ? Colors.white : colorScheme.primary)
                        : (isDark
                            ? Colors.white.withOpacity(0.7)
                            : colorScheme.onSurface.withOpacity(0.7)),
                  ),
            ),
          ],
        ),
      ),
    ),
  );
}
