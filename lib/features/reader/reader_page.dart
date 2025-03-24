import 'dart:developer' as developer;
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:laya/features/reader/components/reader_app_bar.dart';
import 'package:laya/features/reader/components/reader_bottom_bar.dart';
import 'package:laya/features/reader/components/reader_settings_panel.dart';
import 'package:laya/features/reader/data/reader_state.dart';
import 'package:laya/features/reader/data/reader_theme.dart';
import 'package:laya/models/bookmark_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum AssetSource { local, network }

class ReaderScreen extends StatefulWidget {
  final String bookId;
  final String? assetPath;
  final String? assetUrl;
  final AssetSource sourceType;

  const ReaderScreen({
    super.key,
    required this.bookId,
    this.assetPath,
    this.assetUrl,
    this.sourceType = AssetSource.local,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late ReaderState readerState;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize with default values
    readerState = ReaderState(
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
      bookTitle: '',
      chapterTitle: '',
    );

    _initializeBook();
  }

  Future<void> _initializeBook() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Simulating loading book content - replace with actual implementation
      await Future.delayed(const Duration(milliseconds: 500));

      String bookContent;
      if (widget.sourceType == AssetSource.local && widget.assetPath != null) {
        bookContent = await rootBundle.loadString(widget.assetPath!);
      } else if (widget.sourceType == AssetSource.network &&
          widget.assetUrl != null) {
        final response = await http.get(Uri.parse(widget.assetUrl!));
        if (response.statusCode == 200) {
          bookContent = response.body;
        } else {
          throw Exception('Failed to load content: ${response.statusCode}');
        }
        bookContent = "Sample content from URL: ${widget.assetUrl}";
      } else {
        throw Exception('Invalid asset source or path');
      }

      const int charsPerPage = 800;
      final int totalPages = (bookContent.length / charsPerPage).ceil();

      setState(() {
        readerState = readerState.copyWith(
          content: bookContent,
          bookTitle: widget.assetPath?.split('/').last ?? "Book Title",
          chapterTitle: "Chapter 1",
          totalPages: totalPages,
          currentPage: 1,
          textPositions: _generateTextPositions(
            bookContent,
            charsPerPage,
            totalPages,
          ),
        );
        isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading book: $e', name: 'ReaderScreen');
      setState(() {
        readerState = readerState.copyWith(
          content: "Error loading book: ${e.toString()}",
        );
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bookmark added'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Create a map of page numbers to character positions
  Map<int, int> _generateTextPositions(
      String content, int charsPerPage, int totalPages) {
    Map<int, int> positions = {};
    for (int i = 1; i <= totalPages; i++) {
      positions[i] = (i - 1) * charsPerPage;
    }
    return positions;
  }

  // Method to navigate to a specific page by scrolling to the correct position
  void navigateToPage(int page) {
    if (page < 1 || page > readerState.totalPages) return;

    setState(() {
      readerState = readerState.copyWith(currentPage: page);
      // In a real implementation, you would scroll to the corresponding position
      // using a ScrollController
    });
  }

  void updateReaderState(ReaderState newState) {
    setState(() {
      readerState = newState;
    });
  }

  void addBookmark() {
    final bookmark = Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      page: readerState.currentPage,
      note: "",
      timestamp: DateTime.now(),
    );

    setState(() {
      readerState = readerState.copyWith(
        bookmarks: [...readerState.bookmarks, bookmark],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: readerState.theme.background,
        body: Center(
          child: CircularProgressIndicator(
            color: readerState.theme.accent,
          ),
        ),
      );
    }

    return ReaderContent(
      readerState: readerState,
      updateReaderState: updateReaderState,
      addBookmark: addBookmark,
    );
  }
}

class ReaderContent extends StatefulWidget {
  final ReaderState readerState;
  final Function(ReaderState) updateReaderState;
  final VoidCallback addBookmark;

  const ReaderContent({
    super.key,
    required this.readerState,
    required this.updateReaderState,
    required this.addBookmark,
  });

  @override
  State<ReaderContent> createState() => _ReaderContentState();
}

class _ReaderContentState extends State<ReaderContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsOpacityAnimation;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    developer.log(
      'Initializing reader content',
      name: 'ReaderScreen',
    );

    // Add scroll listener to update current page
    _scrollController.addListener(_updateCurrentPageFromScroll);

    // Setup animations for controls
    _controlsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _controlsOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeOut,
    ));

    // Initial state for controls visibility
    if (widget.readerState.showControls) {
      _controlsAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controlsAnimationController.dispose();
    _contentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    final showControls = !widget.readerState.showControls;
    widget.updateReaderState(
        widget.readerState.copyWith(showControls: showControls));

    if (!showControls) {
      _controlsAnimationController.reverse();
    } else {
      _controlsAnimationController.forward();
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ReaderSettingsPanel(
        readerState: widget.readerState,
        updateReaderState: widget.updateReaderState,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
    );
  }

  void _showBookmarks() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BookmarksPanel(
          bookmarks: widget.readerState.bookmarks,
          currentPage: widget.readerState.currentPage,
          theme: widget.readerState.theme,
          onNavigate: (page) {
            _navigateToPage(page);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _addBookmark() {
    widget.addBookmark();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bookmark added'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateCurrentPageFromScroll() {
    if (!_scrollController.hasClients) return;

    final scrollPosition = _scrollController.position;
    final viewportHeight = scrollPosition.viewportDimension;
    final totalHeight = scrollPosition.maxScrollExtent + viewportHeight;
    final scrollOffset = scrollPosition.pixels;

    // Calculate percentage scrolled
    final scrollPercentage = scrollOffset / totalHeight;

    // Calculate page based on percentage
    final totalPages = widget.readerState.totalPages;
    final newPage = (scrollPercentage * totalPages).ceil();
    final currentPage = math.max(1, math.min(newPage, totalPages));

    // Update only if page changed
    if (currentPage != widget.readerState.currentPage) {
      widget.updateReaderState(
        widget.readerState.copyWith(currentPage: currentPage),
      );
    }
  }

  void _navigateToPage(int page) {
    if (page < 1 || page > widget.readerState.totalPages) return;

    // Update the reader state
    widget.updateReaderState(
      widget.readerState.copyWith(currentPage: page),
    );

    if (!_scrollController.hasClients) return;

    // Calculate scroll position for target page
    final totalHeight = _scrollController.position.maxScrollExtent +
        _scrollController.position.viewportDimension;
    final targetPercentage = (page - 1) / widget.readerState.totalPages;
    final targetPosition = totalHeight * targetPercentage;

    // Animate to position
    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final readerState = widget.readerState;

    return GestureDetector(
      onTap: _toggleControls,
      // Make sure input events get passed to the focus node
      behavior: HitTestBehavior.opaque,
      child: Focus(
        focusNode: _contentFocusNode,
        child: Scaffold(
          backgroundColor: readerState.theme.background,
          body: Stack(
            children: [
              // Main content area
              SafeArea(
                child: readerState.readerMode == 'book'
                    ? _buildBookContent(context)
                    : _buildMangaContent(context),
              ),

              // Controls overlay with animation
              AnimatedBuilder(
                animation: _controlsOpacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _controlsOpacityAnimation.value,
                    child: IgnorePointer(
                      ignoring: _controlsOpacityAnimation.value == 0,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    // Custom app bar
                    ReaderAppBar(
                      title: readerState.bookTitle,
                      subtitle: readerState.chapterTitle,
                      theme: readerState.theme,
                      onBack: () => context.pop(),
                      onBookmark: _addBookmark,
                      onSettings: _showSettings,
                      onShowBookmarks: _showBookmarks,
                    ),
                    const Spacer(),
                    // Bottom navigation bar
                    ReaderBottomBar(
                      currentPage: readerState.currentPage,
                      totalPages: readerState.totalPages,
                      theme: readerState.theme,
                      onPageChanged: _navigateToPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookContent(BuildContext context) {
    final readerState = widget.readerState;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: readerState.marginSize),
        child: SelectableText(
          readerState.content,
          style: TextStyle(
            fontSize: readerState.fontSize,
            height: readerState.lineHeight,
            fontFamily: readerState.fontFamily,
            color: readerState.theme.text,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.justify,
          onSelectionChanged: (selection, cause) {
            // If user selects text, show controls
            if (selection.baseOffset != selection.extentOffset) {
              if (!widget.readerState.showControls) {
                widget.updateReaderState(
                    widget.readerState.copyWith(showControls: true));
                _controlsAnimationController.forward();
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildMangaContent(BuildContext context) {
    final readerState = widget.readerState;

    // Implement manga reader
    return Center(
      child: Text(
        'Manga reading mode coming soon',
        style: TextStyle(
          color: readerState.theme.text,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _BookmarksPanel extends StatelessWidget {
  final List<Bookmark> bookmarks;
  final int currentPage;
  final ReaderTheme theme;
  final Function(int) onNavigate;

  const _BookmarksPanel({
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
              bookmarks.isEmpty ? _buildEmptyState() : _buildBookmarkList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildBookmarkList() {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
