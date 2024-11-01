import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsItem extends StatefulWidget {
  final IconData icon;
  final bool isDestructive;
  final String title;
  final void Function() onTap;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.isDestructive,
    required this.title,
    required this.onTap,
  });

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Material(
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenHeight * 0.02,
              vertical: screenHeight * 0.02,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenHeight * 0.012),
                  decoration: BoxDecoration(
                    color: widget.isDestructive
                        ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.isDestructive
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                    size: screenHeight * 0.024,
                  ),
                ),
                SizedBox(width: screenHeight * 0.02),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.isDestructive
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: screenHeight * 0.018,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  size: screenHeight * 0.024,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
