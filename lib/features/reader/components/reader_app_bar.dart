import 'package:flutter/material.dart';
import 'package:laya/features/reader/data/reader_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ReaderAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final ReaderTheme theme;
  final VoidCallback onBack;
  final VoidCallback onBookmark;
  final VoidCallback onSettings;
  final VoidCallback onShowBookmarks;

  const ReaderAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.onBack,
    required this.onBookmark,
    required this.onSettings,
    required this.onShowBookmarks,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.background.withOpacity(0.95),
            theme.background.withOpacity(0.7),
            theme.background.withOpacity(0),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Row(
          children: [
            // Back button
            IconButton(
              icon: const Icon(LucideIcons.arrowLeft, size: 20),
              color: theme.text,
              onPressed: onBack,
              tooltip: 'Back',
              style: IconButton.styleFrom(
                foregroundColor: theme.text,
                backgroundColor: theme.surfaceColor.withOpacity(0.5),
                padding: const EdgeInsets.all(8),
              ),
            ),

            const SizedBox(width: 12),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.text.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Action buttons
            IconButton(
              icon: const Icon(LucideIcons.bookmarkPlus, size: 20),
              color: theme.text,
              onPressed: onBookmark,
              tooltip: 'Add bookmark',
              style: IconButton.styleFrom(
                foregroundColor: theme.text,
                padding: const EdgeInsets.all(8),
              ),
            ),

            IconButton(
              icon: const Icon(LucideIcons.bookmark, size: 20),
              color: theme.text,
              onPressed: onShowBookmarks,
              tooltip: 'Show bookmarks',
              style: IconButton.styleFrom(
                foregroundColor: theme.text,
                padding: const EdgeInsets.all(8),
              ),
            ),

            IconButton(
              icon: const Icon(LucideIcons.settings, size: 20),
              color: theme.text,
              onPressed: onSettings,
              tooltip: 'Settings',
              style: IconButton.styleFrom(
                foregroundColor: theme.text,
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
