import 'package:flutter/material.dart';
import 'package:laya/features/reader/data/reader_theme.dart';

class ReaderBottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ReaderTheme theme;
  final ValueChanged<int> onPageChanged;

  const ReaderBottomBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.theme,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Ensure current page is within bounds
    final validCurrentPage = currentPage.clamp(1, totalPages);
    final progress =
        totalPages > 0 ? validCurrentPage / totalPages.toDouble() : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.background.withOpacity(0),
            theme.background.withOpacity(0.7),
            theme.background.withOpacity(0.95),
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, 24, 16, 16 + bottomInset),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page slider
            Row(
              children: [
                // Current page number
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    validCurrentPage.toString(),
                    style: TextStyle(
                      color: theme.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                // Slider
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      activeTrackColor: theme.accent,
                      inactiveTrackColor: theme.surfaceColor,
                      thumbColor: theme.accent,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayColor: theme.accent.withOpacity(0.2),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                    ),
                    child: Slider(
                      value: validCurrentPage.toDouble(),
                      min: 1,
                      max: totalPages.toDouble(),
                      onChanged: (value) => onPageChanged(value.round()),
                    ),
                  ),
                ),

                // Total pages
                Text(
                  totalPages.toString(),
                  style: TextStyle(
                    color: theme.text.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            // Progress percentage
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).round()}% complete',
              style: TextStyle(
                color: theme.text.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
