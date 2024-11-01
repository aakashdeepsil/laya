import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/series.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/features/content/data/series_repository.dart';

class ActivityView extends StatefulWidget {
  final User user;

  const ActivityView({super.key, required this.user});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final SeriesRepository _seriesRepository = SeriesRepository();

  List<Series> seriesCreatedByTheUser = [];

  bool isLoading = false;

  Future<void> _fetchSeriesCreatedByTheUser() async {
    try {
      setState(() => isLoading = true);
      final series = await _seriesRepository.getUserSeries(widget.user.id);
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
            physics: const NeverScrollableScrollPhysics(),
            itemCount: seriesCreatedByTheUser.length,
            separatorBuilder: (context, index) => Divider(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              thickness: 1,
            ),
            itemBuilder: (context, index) {
              final series = seriesCreatedByTheUser[index];
              return ListTile(
                leading: Image.network(
                  series.thumbnailUrl,
                  fit: BoxFit.cover,
                  height: screenHeight * 0.2,
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
                        .withOpacity(0.7),
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
