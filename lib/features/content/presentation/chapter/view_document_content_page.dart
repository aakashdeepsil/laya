import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/content_model.dart';
import 'package:laya/models/user_model.dart';
import 'package:laya/enums/content_status.dart';
import 'package:laya/providers/content_provider.dart';
import 'package:laya/shared/widgets/content/delete_alert_dialog_widget.dart';
import 'package:laya/shared/widgets/cached_document_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ViewDocumentContentPage extends ConsumerStatefulWidget {
  final Content content;
  final User user;

  const ViewDocumentContentPage({
    super.key,
    required this.content,
    required this.user,
  });

  @override
  ConsumerState<ViewDocumentContentPage> createState() =>
      _ViewDocumentContentPageState();
}

class _ViewDocumentContentPageState
    extends ConsumerState<ViewDocumentContentPage> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  int _currentPage = 0;
  int _totalPages = 0;
  bool isDocumentLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load reading progress
    ref
        .read(readingProgressProvider((
          contentId: widget.content.id,
          userId: widget.user.id,
        )).notifier)
        .loadReadingProgress(
          contentId: widget.content.id,
          userId: widget.user.id,
        );
  }

  // Update reading progress
  void _updateReadingProgress(double progress) {
    ref
        .read(readingProgressProvider((
          contentId: widget.content.id,
          userId: widget.user.id,
        )).notifier)
        .updateReadingProgress(
          contentId: widget.content.id,
          userId: widget.user.id,
          progress: progress,
        );
  }

  // Delete content
  Future<void> deleteContent() async {
    try {
      await ref
          .read(contentProvider(widget.content.seriesId).notifier)
          .deleteContent(widget.content.id);
      if (mounted) {
        context.pop();
      }
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
    }
  }

  // Update content status
  Future<void> updateContentStatus() async {
    try {
      await ref
          .read(contentProvider(widget.content.seriesId).notifier)
          .updateContentStatus(
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
    final readingProgress = ref.watch(readingProgressProvider((
      contentId: widget.content.id,
      userId: widget.user.id,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.content.title,
          style: TextStyle(fontSize: screenHeight * 0.02),
        ),
        actions: [
          if (widget.content.isEditable)
            IconButton(
              icon: Icon(
                LucideIcons.trash2,
                size: screenHeight * 0.025,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => DeleteAlertDialog(
                    isDeleting: false,
                    deleteContent: deleteContent,
                    deleteSeries: null,
                  ),
                );
              },
            ),
          if (widget.content.status == ContentStatus.draft)
            IconButton(
              icon: Icon(
                LucideIcons.send,
                size: screenHeight * 0.025,
              ),
              onPressed: updateContentStatus,
            ),
        ],
      ),
      body: readingProgress.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading reading progress: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        data: (progress) => Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: CachedPdfViewer(
                documentUrl: widget.content.mediaUrl,
                onDocumentLoaded: (pages) {
                  setState(() {
                    _totalPages = pages;
                    isDocumentLoaded = true;
                  });
                },
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  _updateReadingProgress(page / _totalPages);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
