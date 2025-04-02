import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsItem extends StatefulWidget {
  final IconData icon;
  final bool isDestructive;
  final String title;
  final String? subtitle;
  final void Function() onTap;
  final Widget? trailingWidget;
  final bool showChevron;

  /// A settings item with customizable appearance and behavior.
  ///
  /// [icon] - The leading icon to display.
  /// [title] - The main text to display.
  /// [subtitle] - Optional secondary text below the title.
  /// [isDestructive] - Whether this item represents a destructive action (like logout, delete).
  /// [onTap] - Function to call when the item is tapped.
  /// [trailingWidget] - Optional widget to display instead of the chevron (like a switch).
  /// [showChevron] - Whether to show the chevron at the end (ignored if [trailingWidget] is provided).
  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isDestructive,
    required this.onTap,
    this.trailingWidget,
    this.showChevron = true,
  });

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use fixed sizes for better consistency across devices
    const double verticalPadding = 16.0;
    const double horizontalPadding = 16.0;
    const double iconSize = 20.0;
    const double borderRadius = 12.0;

    // Calculate the main color based on destructive state
    final Color mainColor =
        widget.isDestructive ? colorScheme.error : colorScheme.primary;

    // Text styles
    final titleStyle = TextStyle(
      color: widget.isDestructive ? colorScheme.error : colorScheme.onSurface,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );

    final subtitleStyle = TextStyle(
      color: colorScheme.onSurfaceVariant,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  boxShadow: _isPressed
                      ? [
                          BoxShadow(
                            color: mainColor.withValues(alpha: 0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    onTapDown: (_) {
                      setState(() => _isPressed = true);
                      _controller.forward();
                    },
                    onTapUp: (_) {
                      setState(() => _isPressed = false);
                      _controller.reverse();
                    },
                    onTapCancel: () {
                      setState(() => _isPressed = false);
                      _controller.reverse();
                    },
                    borderRadius: BorderRadius.circular(borderRadius),
                    splashColor: mainColor.withValues(alpha: 0.05),
                    highlightColor: mainColor.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: Row(
                        children: [
                          // Leading Icon with container
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: mainColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              widget.icon,
                              color: mainColor,
                              size: iconSize,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Title and optional subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.title,
                                  style: titleStyle,
                                ),
                                if (widget.subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.subtitle!,
                                    style: subtitleStyle,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Trailing widget or chevron
                          widget.trailingWidget ??
                              (widget.showChevron
                                  ? Icon(
                                      LucideIcons.chevronRight,
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                      size: iconSize,
                                    )
                                  : const SizedBox.shrink())
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
