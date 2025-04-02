import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/models/user_model.dart';
import 'package:laya/services/series_service.dart';
import 'package:laya/shared/widgets/cached_image_widget.dart';

class ActivityView extends StatefulWidget {
  final User user;

  const ActivityView({super.key, required this.user});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final SeriesService _seriesService = SeriesService();

  List<Series> seriesCreatedByTheUser = [];

  bool isLoading = false;

  Future<void> _fetchSeriesCreatedByTheUser() async {
    try {
      setState(() => isLoading = true);
      final series = await _seriesService.getUserSeries(widget.user.id);
      setState(() => seriesCreatedByTheUser = series);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              'Failed to fetch series created by the user. Please try again.',
              style: TextStyle(fontSize: screenHeight * 0.016),
            ),
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSeriesCreatedByTheUser();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
            itemCount: seriesCreatedByTheUser.length,
            separatorBuilder: (context, index) => Divider(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.1),
              thickness: 1,
            ),
            itemBuilder: (context, index) {
              final series = seriesCreatedByTheUser[index];
              return ListTile(
                leading: CachedImageWidget(
                  imageUrl: series.thumbnailUrl!,
                  fit: BoxFit.cover,
                  height: screenHeight * 0.2,
                  width: screenWidth * 0.3,
                ),
                title: Text(
                  series.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: screenHeight * 0.016,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  series.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                    fontSize: screenHeight * 0.014,
                  ),
                ),
                onTap: () => context.push(
                  '/series_details_page',
                  extra: {
                    'series': seriesCreatedByTheUser[index],
                    'user': widget.user,
                  },
                ),
              );
            },
          );
  }
}
