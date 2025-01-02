import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/content.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/enums/content_status.dart';
import 'package:laya/features/content/data/content_repository.dart';
import 'package:laya/shared/widgets/cached_document_widget.dart';
import 'package:laya/shared/widgets/content/delete_alert_dialog_widget.dart';

class ViewDocumentContentPage extends StatefulWidget {
  final Content content;
  final User user;

  const ViewDocumentContentPage({
    super.key,
    required this.content,
    required this.user,
  });

  @override
  State<ViewDocumentContentPage> createState() =>
      _ViewDocumentContentPageState();
}

class _ViewDocumentContentPageState extends State<ViewDocumentContentPage> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  final ContentRepository _contentRepository = ContentRepository();

  int _currentPage = 0;
  int _totalPages = 0;

  double _readingProgress = 0.0;

  bool isDeletingContent = false;
  bool isDocumentLoaded = false;
  bool loadingReadingProgress = false;

  @override
  void initState() {
    super.initState();
    _loadReadingProgress();
  }

  // Load the reading progress of the user
  Future<void> _loadReadingProgress() async {
    try {
      setState(() => loadingReadingProgress = true);

      final readingProgressResponse =
          await _contentRepository.getReadingProgress(
        contentId: widget.content.id,
        userId: widget.user.id,
      );

      if (readingProgressResponse != null) {
        setState(() {
          _currentPage = readingProgressResponse.currentPage;
          _readingProgress = readingProgressResponse.progress;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              "Failed to load reading progress.",
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    } finally {
      setState(() => loadingReadingProgress = false);
    }
  }

  // Save the reading progress of the user
  Future<void> _saveReadingProgress() async {
    try {
      await _contentRepository.saveReadingProgress(
        contentId: widget.content.id,
        userId: widget.user.id,
        currentPage: _currentPage,
        progress: _readingProgress,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              "Failed to save reading progress.",
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    }
  }

  // Show the delete confirmation dialog
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: !isDeletingContent,
      builder: (context) => DeleteAlertDialog(
        isDeleting: isDeletingContent,
        deleteContent: deleteContent,
        deleteSeries: null,
      ),
    );
  }

  // Delete the content
  Future<void> deleteContent() async {
    try {
      setState(() => isDeletingContent = true);
      await _contentRepository.deleteContent(widget.content.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              'Failed to delete the content.',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    } finally {
      setState(() => isDeletingContent = false);
    }
  }

  // Update the content status
  Future<void> updateContentStatus() async {
    try {
      await _contentRepository.updateContentStatus(
        contentId: widget.content.id,
        status: ContentStatus.published,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Text(
              'Chapter published successfully.',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              'Failed to publish the chapter.',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.content.title,
          style: TextStyle(fontSize: screenHeight * 0.02),
        ),
        actions: widget.content.creatorId == widget.user.id
            ? [
                PopupMenuButton<int>(
                  icon: Icon(Icons.more_vert, size: screenHeight * 0.025),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: ListTile(
                        leading: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        title: Text(
                          'Edit',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: screenHeight * 0.02,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          context.pop(); // Close the popup menu
                          context.push('/edit_content_page', extra: {
                            'content': widget.content,
                            'user': widget.user,
                          });
                        },
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: ListTile(
                        leading: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          'Delete',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: screenHeight * 0.02,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          context.pop();
                          _showDeleteConfirmation();
                        },
                      ),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: ListTile(
                        leading: Icon(
                          Icons.publish,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          'Publish',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: screenHeight * 0.02,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          context.pop(); // Close the popup menu
                          updateContentStatus();
                        },
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            CachedPdfViewer(
              mediaUrl: widget.content.mediaUrl,
              initialPageNumber: _currentPage,
              onDocumentLoaded: (details) {
                setState(() => _totalPages = details.document.pages.count);
              },
              onPageChanged: (details) {
                setState(() {
                  _currentPage = details.newPageNumber - 1;
                  _readingProgress = _currentPage / (_totalPages - 1);
                });
                _saveReadingProgress();
              },
              canShowPaginationDialog: false,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saveReadingProgress();
    super.dispose();
  }
}
