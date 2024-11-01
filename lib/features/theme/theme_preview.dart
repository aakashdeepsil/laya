import 'package:flutter/material.dart';

class ThemePreview extends StatefulWidget {
  final ColorScheme colorScheme;

  const ThemePreview({super.key, required this.colorScheme});

  @override
  State<ThemePreview> createState() => _ThemePreviewState();
}

class _ThemePreviewState extends State<ThemePreview> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: widget.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: screenWidth * 0.1,
                height: screenHeight * 0.05,
                decoration: BoxDecoration(
                  color: widget.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: widget.colorScheme.onPrimary,
                  size: screenHeight * 0.03,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth * 0.3,
                      height: screenHeight * 0.015,
                      decoration: BoxDecoration(
                        color: widget.colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Container(
                      width: screenWidth * 0.2,
                      height: screenHeight * 0.015,
                      decoration: BoxDecoration(
                        color: widget.colorScheme.onSurface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Container(
            width: double.infinity,
            height: screenHeight * 0.2,
            decoration: BoxDecoration(
              color: widget.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image,
              size: screenHeight * 0.05,
              color: widget.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
