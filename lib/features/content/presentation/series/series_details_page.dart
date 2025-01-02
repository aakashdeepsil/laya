import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/content.dart';
import 'package:laya/config/schema/series.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/features/content/data/content_repository.dart';
import 'package:laya/features/content/data/series_repository.dart';
import 'package:laya/features/library/data/library_repository.dart';
import 'package:laya/shared/widgets/cached_image_widget.dart';
import 'package:laya/shared/widgets/content/delete_alert_dialog_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SeriesDetailsPage extends StatefulWidget {
  final Series series;
  final User user;

  const SeriesDetailsPage({
    super.key,
    required this.series,
    required this.user,
  });

  @override
  State<SeriesDetailsPage> createState() => _SeriesDetailsPageState();
}

class _SeriesDetailsPageState extends State<SeriesDetailsPage> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  final ContentRepository _contentRepository = ContentRepository();
  final LibraryRepository _libraryRepository = LibraryRepository();
  final SeriesRepository _seriesRepository = SeriesRepository();

  bool isCreator = false;
  bool isDeleting = false;
  bool isFetchingSeriesContent = false;
  bool inLibrary = false;
  bool isFetchingLibraryStatus = false;

  List<Content> seriesContent = [];

  // Fetch series content
  Future<void> getSeriesContent(String seriesId) async {
    try {
      setState(() => isFetchingSeriesContent = true);
      final response = await _contentRepository.getContentsBySeries(seriesId);
      setState(() => seriesContent = response);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              "Failed to load series content. Please try again.",
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    } finally {
      setState(() => isFetchingSeriesContent = false);
    }
  }

  // Check if series is in library
  Future<void> checkLibraryStatus() async {
    try {
      setState(() => isFetchingLibraryStatus = true);
      final response = await _libraryRepository.isSeriesInLibrary(
        seriesId: widget.series.id,
        userId: widget.user.id,
      );
      setState(() => inLibrary = response);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to check library status. Please try again.",
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => isFetchingLibraryStatus = false);
    }
  }

  // Delete series
  Future<void> deleteSeries() async {
    try {
      setState(() => isDeleting = true);
      await _seriesRepository.deleteSeries(widget.series);
      if (mounted) {
        context.pop(); // Close the dialog
        context.go('/home', extra: widget.user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: Text(
              'Series deleted successfully.',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        context.pop(); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              "Failed to delete the series. Please try again.",
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    } finally {
      setState(() => isDeleting = false);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: !isDeleting,
      builder: (context) => DeleteAlertDialog(
        isDeleting: isDeleting,
        deleteContent: null,
        deleteSeries: deleteSeries,
      ),
    );
  }

  Future<void> _toggleLibrary() async {
    try {
      setState(() => inLibrary = !inLibrary);
      if (inLibrary) {
        await _libraryRepository.addToLibrary(
          seriesId: widget.series.id,
          userId: widget.user.id,
        );
      } else {
        await _libraryRepository.removeFromLibrary(
          seriesId: widget.series.id,
          userId: widget.user.id,
        );
      }
    } catch (e) {
      setState(() => inLibrary = !inLibrary);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              "Failed to ${inLibrary ? 'add to' : 'remove from'} library",
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    isCreator = widget.user.id == widget.series.creatorId;
    getSeriesContent(widget.series.id);
    checkLibraryStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.25,
            floating: false,
            pinned: false,
            snap: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedImageWidget(
                    imageUrl: widget.series.coverImageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: isCreator
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
                              context.pop();
                              context.push('/edit_series_page', extra: {
                                'series': widget.series,
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
                              Icons.add,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(
                              'Add a new chapter',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: screenHeight * 0.02,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              context.pop();
                              context.push(
                                '/create_chapter_page',
                                extra: widget.user,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ]
                : null,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: screenHeight * 0.03,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenHeight * 0.01,
                    vertical: screenHeight * 0.015,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedImageWidget(
                          imageUrl: widget.series.thumbnailUrl,
                          width: screenWidth * 0.25,
                          height: screenHeight * 0.175,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.series.title,
                              style: TextStyle(
                                fontSize: screenHeight * 0.025,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              widget.series.description,
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: screenHeight * 0.015),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('');
                      },
                      icon: Icon(
                        Icons.play_arrow,
                        color: Theme.of(context).colorScheme.secondary,
                        size: screenHeight * 0.025,
                      ),
                      label: Text(
                        'Start Reading',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: screenHeight * 0.015,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _toggleLibrary,
                      icon: Icon(
                        inLibrary ? Icons.check : Icons.add,
                        color: Theme.of(context).colorScheme.secondary,
                        size: screenHeight * 0.025,
                      ),
                      label: Text(
                        inLibrary ? 'In Library' : 'Add to Library',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: screenHeight * 0.015,
                        ),
                      ),
                    ),
                  ],
                ),
                if (seriesContent.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.02,
                    ),
                    child: Text(
                      'No content available yet.',
                      style: TextStyle(fontSize: screenHeight * 0.02),
                    ),
                  ),
                ListView.builder(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: seriesContent.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        context.push('/content_details_page', extra: {
                          'content': seriesContent[index],
                          'user': widget.user,
                        });
                      },
                      leading: CachedImageWidget(
                        imageUrl: seriesContent[index].thumbnailUrl,
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.2,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        seriesContent[index].title,
                        style: TextStyle(
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        seriesContent[index].description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      trailing: Icon(
                        LucideIcons.chevronRight,
                        size: screenHeight * 0.025,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
