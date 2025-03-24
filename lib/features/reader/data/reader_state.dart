import 'package:laya/features/reader/data/reader_theme.dart';
import 'package:laya/models/bookmark_model.dart';

class ReaderState {
  final ReaderTheme theme;
  final double fontSize;
  final double lineHeight;
  final double marginSize;
  final String fontFamily;
  final String readerMode;
  final String readingDirection;
  final int currentPage;
  final int totalPages;
  final List<Bookmark> bookmarks;
  final bool showControls;
  final String content;
  final String bookTitle;
  final String chapterTitle;
  final Map<int, int> textPositions; // Maps page numbers to character positions

  ReaderState({
    required this.theme,
    required this.fontSize,
    required this.lineHeight,
    required this.marginSize,
    required this.fontFamily,
    required this.readerMode,
    required this.readingDirection,
    required this.currentPage,
    required this.totalPages,
    required this.bookmarks,
    required this.showControls,
    required this.content,
    required this.bookTitle,
    required this.chapterTitle,
    this.textPositions = const {},
  });

  ReaderState copyWith({
    ReaderTheme? theme,
    double? fontSize,
    double? lineHeight,
    double? marginSize,
    String? fontFamily,
    String? readerMode,
    String? readingDirection,
    int? currentPage,
    int? totalPages,
    List<Bookmark>? bookmarks,
    bool? showControls,
    String? content,
    String? bookTitle,
    String? chapterTitle,
    Map<int, int>? textPositions,
  }) {
    return ReaderState(
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      marginSize: marginSize ?? this.marginSize,
      fontFamily: fontFamily ?? this.fontFamily,
      readerMode: readerMode ?? this.readerMode,
      readingDirection: readingDirection ?? this.readingDirection,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      bookmarks: bookmarks ?? this.bookmarks,
      showControls: showControls ?? this.showControls,
      content: content ?? this.content,
      bookTitle: bookTitle ?? this.bookTitle,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      textPositions: textPositions ?? this.textPositions,
    );
  }
}
