import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laya/features/reader/data/reader_state.dart';
import 'package:laya/features/reader/data/reader_theme.dart';
import 'package:laya/models/bookmark_model.dart';
import 'package:laya/models/content_model.dart';

class ReaderNotifier extends StateNotifier<ReaderState> {
  final Content content;

  ReaderNotifier(this.content)
      : super(ReaderState(
          theme: ReaderThemes.light,
          fontSize: 16.0,
          lineHeight: 1.5,
          marginSize: 20.0,
          fontFamily: 'System',
          readerMode: 'book',
          readingDirection: 'ltr',
          currentPage: 1,
          totalPages: 1,
          bookmarks: [],
          showControls: true,
          content: '',
          bookTitle: content.title,
          chapterTitle: '',
        ));

  void updateTheme(ReaderTheme theme) {
    state = state.copyWith(theme: theme);
  }

  void updateFontSize(double size) {
    state = state.copyWith(fontSize: size);
  }

  void updateLineHeight(double height) {
    state = state.copyWith(lineHeight: height);
  }

  void updateMarginSize(double size) {
    state = state.copyWith(marginSize: size);
  }

  void updateFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
  }

  void updateReaderMode(String mode) {
    state = state.copyWith(readerMode: mode);
  }

  void updateReadingDirection(String direction) {
    state = state.copyWith(readingDirection: direction);
  }

  void updateCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void updateTotalPages(int total) {
    state = state.copyWith(totalPages: total);
  }

  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  void toggleControls() {
    state = state.copyWith(showControls: !state.showControls);
  }

  void addBookmark() {
    final bookmark = Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      page: state.currentPage,
      note: "",
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      bookmarks: [...state.bookmarks, bookmark],
    );
  }

  void removeBookmark(String bookmarkId) {
    state = state.copyWith(
      bookmarks: state.bookmarks.where((b) => b.id != bookmarkId).toList(),
    );
  }

  void updateBookmarkNote(String bookmarkId, String note) {
    state = state.copyWith(
      bookmarks: state.bookmarks.map((b) {
        if (b.id == bookmarkId) {
          return b.copyWith(note: note);
        }
        return b;
      }).toList(),
    );
  }

  void navigateToPage(int page) {
    if (page < 1 || page > state.totalPages) return;
    state = state.copyWith(currentPage: page);
  }
}

final readerProvider =
    StateNotifierProvider.family<ReaderNotifier, ReaderState, Content>(
  (ref, content) => ReaderNotifier(content),
);
