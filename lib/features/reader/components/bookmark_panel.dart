import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:laya/features/reader/data/reader_theme.dart';
import 'package:laya/models/bookmark_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BookmarksPanel extends StatelessWidget {
  final List<Bookmark> bookmarks;
  final int currentPage;
  final ReaderTheme theme;
  final Function(int) onNavigate;

  const BookmarksPanel({
    super.key,
    required this.bookmarks,
    required this.currentPage,
    required this.theme,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: theme.surfaceColor.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: theme.borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.text.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.bookmark,
                      color: theme.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Bookmarks',
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        LucideIcons.x,
                        color: theme.text.withOpacity(0.6),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Bookmark list or empty state
              bookmarks.isEmpty ? emptyState() : bookmarkList(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget bookmarkList() {
    return Flexible(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shrinkWrap: true,
        itemCount: bookmarks.length,
        separatorBuilder: (context, index) => Divider(
          color: theme.borderColor,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final bookmark = bookmarks[index];
          final isCurrentPage = bookmark.page == currentPage;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Row(
              children: [
                Icon(
                  isCurrentPage ? LucideIcons.bookMarked : LucideIcons.bookmark,
                  size: 18,
                  color: isCurrentPage ? theme.accent : theme.text,
                ),
                const SizedBox(width: 12),
                Text(
                  'Page ${bookmark.page}',
                  style: TextStyle(
                    color: theme.text,
                    fontWeight:
                        isCurrentPage ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              bookmark.note.isNotEmpty
                  ? bookmark.note
                  : 'Added on ${_formatDate(bookmark.timestamp)}',
              style: TextStyle(
                color: theme.text.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            trailing: Icon(
              LucideIcons.arrowRight,
              size: 16,
              color: theme.text.withOpacity(0.4),
            ),
            onTap: () => onNavigate(bookmark.page),
            tileColor: isCurrentPage
                ? theme.accent.withOpacity(0.1)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }

  Widget emptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.bookmarkPlus,
            size: 64,
            color: theme.text.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: TextStyle(
              color: theme.text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark icon to save your current reading position',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.text.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
