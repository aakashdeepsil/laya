import 'package:flutter/material.dart';

class ThemeOption extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const ThemeOption({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  State<ThemeOption> createState() => _ThemeOptionState();
}

class _ThemeOptionState extends State<ThemeOption> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? widget.colorScheme.primary.withOpacity(0.1)
              : widget.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isSelected
                ? widget.colorScheme.primary
                : widget.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: widget.isSelected
                  ? widget.colorScheme.primary
                  : widget.colorScheme.onSurface,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                color: widget.isSelected
                    ? widget.colorScheme.primary
                    : widget.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (widget.isSelected)
              Icon(
                Icons.check_circle,
                color: widget.colorScheme.primary,
                size: screenHeight * 0.03,
              ),
          ],
        ),
      ),
    );
  }
}
