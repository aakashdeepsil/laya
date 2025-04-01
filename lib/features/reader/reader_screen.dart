import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:laya/features/reader/components/bookmark_panel.dart';
import 'package:laya/features/reader/components/reader_app_bar.dart';
import 'package:laya/features/reader/components/reader_bottom_bar.dart';
import 'package:laya/features/reader/components/reader_settings_panel.dart';
import 'package:laya/features/reader/data/reader_state.dart';
import 'package:laya/models/content_model.dart';
import 'package:laya/shared/widgets/cached_document_widget.dart';
import 'package:path/path.dart' as path;
import 'package:laya/features/reader/providers/reader_provider.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final Content content;

  const ReaderScreen({super.key, required this.content});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    // Schedule initialization after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBook();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (error != null) {
      // Schedule the SnackBar to be shown after the frame is built
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading book: $error'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
          // Clear the error after showing it
          setState(() {
            error = null;
          });
        }
      });
    }
  }

  Future<void> _initializeBook() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      String bookContent = '';
      int totalPages = 1;

      // Get file extension from URL, removing query parameters
      final uri = Uri.parse(widget.content.mediaUrl);
      developer.log(
        'Processing document URL: ${widget.content.mediaUrl}',
        name: 'ReaderScreen',
      );
      final fileExt = path.extension(uri.path).toLowerCase();
      developer.log('Detected file extension: $fileExt', name: 'ReaderScreen');
      final notifier = ref.read(readerProvider(widget.content).notifier);

      // For PDF files, we'll use CachedPdfViewer
      if (fileExt == '.pdf') {
        developer.log('Initializing PDF viewer mode', name: 'ReaderScreen');
        // Initialize with empty content, will be updated when PDF text is extracted
        notifier.updateTotalPages(1); // This will be updated by CachedPdfViewer
        notifier.updateCurrentPage(1);
        notifier.updateContent(''); // Temporary empty content
        developer.log(
          'PDF viewer mode initialized, waiting for text extraction',
          name: 'ReaderScreen',
        );
      } else if (fileExt == '.txt') {
        developer.log('Processing text file', name: 'ReaderScreen');
        // For text files, download and read directly
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          bookContent = response.body;
          developer.log(
            'Text content loaded, length: ${bookContent.length}',
            name: 'ReaderScreen',
          );
          totalPages = (bookContent.length / 800).ceil(); // Approximate pages
          developer.log('Calculated pages: $totalPages', name: 'ReaderScreen');

          // Update state one by one to avoid potential issues
          developer.log(
            'Updating reader state with text content',
            name: 'ReaderScreen',
          );
          notifier.updateContent(bookContent);
          notifier.updateTotalPages(totalPages);
          notifier.updateCurrentPage(1);
        } else {
          throw Exception('Failed to load content: ${response.statusCode}');
        }
      } else {
        throw Exception('Unsupported file type: $fileExt');
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading book: $e', name: 'ReaderScreen', error: e);
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(readerProvider(widget.content));

    final uri = Uri.parse(widget.content.mediaUrl);
    developer.log(
      'Processing document URL: ${widget.content.mediaUrl}',
      name: 'ReaderScreen',
    );
    final fileExt = path.extension(uri.path).toLowerCase();

    developer.log(
      'Building ReaderScreen, current page: ${readerState.currentPage}, total pages: ${readerState.totalPages}, content length: ${readerState.content.length}',
      name: 'ReaderScreen',
    );

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

    if (error != null) {
      developer.log('Showing error state: $error', name: 'ReaderScreen');
      return Scaffold(
        backgroundColor: readerState.theme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading book',
                style: TextStyle(
                  color: readerState.theme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: TextStyle(
                  color: readerState.theme.text.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeBook,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // If we have a PDF URL, use CachedPdfViewer
    if (fileExt == '.pdf') {
      return Scaffold(
        backgroundColor: readerState.theme.background,
        body: Stack(
          children: [
            // PDF Viewer
            SafeArea(
              child: CachedPdfViewer(
                documentUrl: widget.content.mediaUrl,
                backgroundColor: readerState.theme.background,
                loadingColor: readerState.theme.accent,
                onDocumentLoaded: (pages) {
                  developer.log(
                    'PDF document loaded with $pages pages',
                    name: 'ReaderScreen',
                  );
                  ref
                      .read(readerProvider(widget.content).notifier)
                      .updateTotalPages(pages);
                },
                onPageChanged: (page) {
                  developer.log(
                    'PDF page changed to $page',
                    name: 'ReaderScreen',
                  );
                  ref
                      .read(readerProvider(widget.content).notifier)
                      .updateCurrentPage(page);
                },
                onTextExtracted: (text) {
                  developer.log(
                    'PDF text extracted, length: ${text.length}, first 100 chars: ${text.substring(
                      0,
                      math.min(100, text.length),
                    )}',
                    name: 'ReaderScreen',
                  );
                  ref
                      .read(readerProvider(widget.content).notifier)
                      .updateContent(text);
                },
              ),
            ),

            // Controls overlay
            Column(
              children: [
                // Custom app bar
                ReaderAppBar(
                  title: readerState.bookTitle,
                  subtitle: readerState.chapterTitle,
                  theme: readerState.theme,
                  onBack: () => context.pop(),
                  onBookmark: () {
                    ref
                        .read(readerProvider(widget.content).notifier)
                        .addBookmark();
                  },
                  onSettings: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => ReaderSettingsPanel(
                        readerState: readerState,
                        updateReaderState: (newState) {
                          final notifier =
                              ref.read(readerProvider(widget.content).notifier);
                          // Update all settings that changed
                          if (newState.theme != readerState.theme) {
                            notifier.updateTheme(newState.theme);
                          }
                          if (newState.fontSize != readerState.fontSize) {
                            notifier.updateFontSize(newState.fontSize);
                          }
                          if (newState.lineHeight != readerState.lineHeight) {
                            notifier.updateLineHeight(newState.lineHeight);
                          }
                          if (newState.marginSize != readerState.marginSize) {
                            notifier.updateMarginSize(newState.marginSize);
                          }
                          if (newState.fontFamily != readerState.fontFamily) {
                            notifier.updateFontFamily(newState.fontFamily);
                          }
                          if (newState.readerMode != readerState.readerMode) {
                            notifier.updateReaderMode(newState.readerMode);
                          }
                          if (newState.readingDirection !=
                              readerState.readingDirection) {
                            notifier.updateReadingDirection(
                                newState.readingDirection);
                          }
                        },
                      ),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      barrierColor: Colors.black54,
                    );
                  },
                  onShowBookmarks: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return BookmarksPanel(
                          bookmarks: readerState.bookmarks,
                          currentPage: readerState.currentPage,
                          theme: readerState.theme,
                          onNavigate: (page) {
                            ref
                                .read(readerProvider(widget.content).notifier)
                                .updateCurrentPage(page);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
                const Spacer(),
                // Bottom navigation bar
                ReaderBottomBar(
                  currentPage: readerState.currentPage,
                  totalPages: readerState.totalPages,
                  theme: readerState.theme,
                  onPageChanged: (page) {
                    ref
                        .read(readerProvider(widget.content).notifier)
                        .updateCurrentPage(page);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }

    // For other document types, use the regular reader content
    return ReaderContent(
      readerState: readerState,
      onUpdateReaderState: (newState) {
        // Handle state updates through the provider
        final notifier = ref.read(readerProvider(widget.content).notifier);
        if (newState.theme != readerState.theme) {
          notifier.updateTheme(newState.theme);
        }
        if (newState.fontSize != readerState.fontSize) {
          notifier.updateFontSize(newState.fontSize);
        }
        if (newState.lineHeight != readerState.lineHeight) {
          notifier.updateLineHeight(newState.lineHeight);
        }
        if (newState.marginSize != readerState.marginSize) {
          notifier.updateMarginSize(newState.marginSize);
        }
        if (newState.fontFamily != readerState.fontFamily) {
          notifier.updateFontFamily(newState.fontFamily);
        }
        if (newState.readerMode != readerState.readerMode) {
          notifier.updateReaderMode(newState.readerMode);
        }
        if (newState.readingDirection != readerState.readingDirection) {
          notifier.updateReadingDirection(newState.readingDirection);
        }
        if (newState.currentPage != readerState.currentPage) {
          notifier.updateCurrentPage(newState.currentPage);
        }
        if (newState.totalPages != readerState.totalPages) {
          notifier.updateTotalPages(newState.totalPages);
        }
        if (newState.showControls != readerState.showControls) {
          notifier.toggleControls();
        }
      },
      onAddBookmark: () {
        ref.read(readerProvider(widget.content).notifier).addBookmark();
      },
    );
  }
}

class ReaderContent extends ConsumerStatefulWidget {
  final ReaderState readerState;
  final Function(ReaderState) onUpdateReaderState;
  final VoidCallback onAddBookmark;

  const ReaderContent({
    super.key,
    required this.readerState,
    required this.onUpdateReaderState,
    required this.onAddBookmark,
  });

  @override
  ConsumerState<ReaderContent> createState() => _ReaderContentState();
}

class _ReaderContentState extends ConsumerState<ReaderContent>
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
    widget.onUpdateReaderState(
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
        updateReaderState: widget.onUpdateReaderState,
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
        return BookmarksPanel(
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
    widget.onAddBookmark();

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
      widget.onUpdateReaderState(
        widget.readerState.copyWith(currentPage: currentPage),
      );
    }
  }

  void _navigateToPage(int page) {
    if (page < 1 || page > widget.readerState.totalPages) return;

    // Update the reader state
    widget.onUpdateReaderState(
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
    developer.log('Book content: ${readerState.content}', name: 'ReaderScreen');

    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: readerState.marginSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add some top padding for better visual balance
            const SizedBox(height: 24),
            // Wrap the text in a Container for better control over the content width
            Container(
              constraints: const BoxConstraints(
                maxWidth: 800, // Limit the maximum width for better readability
              ),
              child: SelectableText(
                readerState.content,
                style: TextStyle(
                  fontSize: readerState.fontSize,
                  height: readerState.lineHeight,
                  fontFamily: readerState.fontFamily,
                  color: readerState.theme.text,
                  letterSpacing: 0.3,
                  wordSpacing: 0.5, // Add word spacing for better readability
                ),
                textAlign: TextAlign.justify,
                textDirection: readerState.readingDirection == 'rtl'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                onSelectionChanged: (selection, cause) {
                  // If user selects text, show controls
                  if (selection.baseOffset != selection.extentOffset) {
                    if (!widget.readerState.showControls) {
                      widget.onUpdateReaderState(
                        widget.readerState.copyWith(showControls: true),
                      );
                      _controlsAnimationController.forward();
                    }
                  }
                },
              ),
            ),
            // Add bottom padding for better visual balance
            const SizedBox(height: 24),
          ],
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
