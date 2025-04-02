import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/content_model.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/models/user_model.dart';
import 'package:laya/providers/auth_provider.dart';
import 'package:laya/providers/content_provider.dart';
import 'package:laya/providers/series_provider.dart';
import 'package:laya/shared/widgets/content/delete_alert_dialog_widget.dart';
import 'package:laya/features/content/presentation/series/components/toast.dart';
import 'package:laya/enums/content_status.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:laya/shared/widgets/cached_image_widget.dart';

class ContentListItem extends ConsumerWidget {
  final Content content;
  final Series series;
  final bool isCreator;
  final VoidCallback onTap;

  const ContentListItem({
    super.key,
    required this.content,
    required this.series,
    required this.isCreator,
    required this.onTap,
  });

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final chapterState = ref.read(chapterStateProvider(content.id).notifier);

    showDialog(
      context: context,
      barrierDismissible:
          ref.watch(chapterStateProvider(content.id)) is! AsyncLoading,
      builder: (context) => DeleteAlertDialog(
        isDeleting: ref.watch(chapterStateProvider(content.id)) is AsyncLoading,
        deleteContent: () async {
          await chapterState.deleteChapter(content.id);

          final state = ref.read(chapterStateProvider(content.id));
          if (state is AsyncData && context.mounted) {
            context.pop(); // Close dialog
            // Invalidate the seriesContentProvider to refresh the content list
            ref.invalidate(seriesContentProvider(series.id));
            showToast(
              context: context,
              message: 'Chapter deleted successfully',
              type: ToastType.success,
            );
          } else if (state is AsyncError && context.mounted) {
            context.pop(); // Close dialog
            showToast(
              context: context,
              message: 'Failed to delete chapter',
              type: ToastType.error,
            );
          }
        },
        deleteSeries: null,
      ),
    );
  }

  Future<void> _updateContentStatus(
      BuildContext context, WidgetRef ref, ContentStatus status) async {
    final chapterState = ref.read(chapterStateProvider(content.id).notifier);

    try {
      if (status == ContentStatus.published) {
        await chapterState.publishChapter(content.id);
      } else {
        await chapterState.unpublishChapter(content.id);
      }

      // Invalidate the seriesContentProvider to refresh the content list
      ref.invalidate(seriesContentProvider(series.id));

      if (context.mounted) {
        showToast(
          context: context,
          message: status == ContentStatus.published
              ? 'Chapter published successfully'
              : 'Chapter unpublished successfully',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showToast(
          context: context,
          message: 'Failed to update chapter status',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final chapterState = ref.watch(chapterStateProvider(content.id));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.015,
          horizontal: screenWidth * 0.01,
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: screenWidth * 0.15,
                height: screenHeight * 0.08,
                child: CachedImageWidget(
                  imageUrl: content.thumbnailUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),

            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: TextStyle(
                      fontSize: screenHeight * 0.016,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.004),
                  Text(
                    content.description,
                    style: TextStyle(
                      fontSize: screenHeight * 0.014,
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.02),

            // Action buttons for creator
            if (isCreator)
              PopupMenuButton(
                icon: Icon(
                  LucideIcons.moreVertical,
                  size: screenHeight * 0.022,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: ListTile(
                      leading: Icon(
                        LucideIcons.pencil,
                        color: colorScheme.primary,
                        size: screenHeight * 0.022,
                      ),
                      title: Text(
                        'Edit Chapter',
                        style: TextStyle(
                          fontSize: screenHeight * 0.016,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    onTap: () {
                      // Need to use future to navigate after popup is dismissed
                      Future.delayed(Duration.zero, () {
                        if (context.mounted) {
                          context.push(
                            '/edit_chapter',
                            extra: {'content': content},
                          );
                        }
                      });
                    },
                  ),
                  if (content.status == ContentStatus.draft)
                    PopupMenuItem(
                      value: 2,
                      child: ListTile(
                        leading: Icon(
                          LucideIcons.send,
                          color: colorScheme.primary,
                          size: screenHeight * 0.022,
                        ),
                        title: Text(
                          'Publish Chapter',
                          style: TextStyle(
                            fontSize: screenHeight * 0.016,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                      onTap: () => _updateContentStatus(
                        context,
                        ref,
                        ContentStatus.published,
                      ),
                    ),
                  if (content.status == ContentStatus.published)
                    PopupMenuItem(
                      value: 3,
                      child: ListTile(
                        leading: Icon(
                          LucideIcons.undo,
                          color: colorScheme.primary,
                          size: screenHeight * 0.022,
                        ),
                        title: Text(
                          'Unpublish Chapter',
                          style: TextStyle(
                            fontSize: screenHeight * 0.016,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                      onTap: () => _updateContentStatus(
                        context,
                        ref,
                        ContentStatus.draft,
                      ),
                    ),
                  PopupMenuItem(
                    value: 4,
                    child: ListTile(
                      leading: Icon(
                        LucideIcons.trash2,
                        color: colorScheme.error,
                        size: screenHeight * 0.022,
                      ),
                      title: Text(
                        'Delete Chapter',
                        style: TextStyle(
                          fontSize: screenHeight * 0.016,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.error,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    onTap: () => _showDeleteConfirmation(context, ref),
                  ),
                ],
              )
            else
              // Navigation indicator for non-creators
              Icon(
                LucideIcons.chevronRight,
                size: screenHeight * 0.022,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
          ],
        ),
      ),
    );
  }
}
