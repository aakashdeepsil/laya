import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/series.dart';
import 'package:laya/features/content/data/series_repository.dart';
import 'package:laya/shared/widgets/bottom_navigation_bar_widget.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/shared/widgets/content/series_carousel_widget.dart';
import 'package:laya/shared/widgets/home/section_tile_widget.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  final SeriesRepository _seriesRepository = SeriesRepository();

  List<Series> mostRecentlyAddedSeries = [];

  bool isFetchingMostRecentlyAddedSeries = false;

  @override
  void initState() {
    super.initState();
    _loadMostRecentlyAddedSeries();
  }

  // Load most recently added series
  Future<void> _loadMostRecentlyAddedSeries() async {
    try {
      setState(() => isFetchingMostRecentlyAddedSeries = true);
      final response = await _seriesRepository.getRecentlyAddedSeries();
      mostRecentlyAddedSeries = response;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              'An error occurred while loading series. Please try again.',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    } finally {
      setState(() => isFetchingMostRecentlyAddedSeries = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('LAYA', style: TextStyle(fontSize: screenHeight * 0.025)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              isFetchingMostRecentlyAddedSeries
                  ? const Center(child: CircularProgressIndicator())
                  : mostRecentlyAddedSeries.isNotEmpty
                      ? const SectionTile(title: 'Recently Added')
                      : Container(),
              isFetchingMostRecentlyAddedSeries
                  ? Container()
                  : SeriesCarousel(
                      seriesList: mostRecentlyAddedSeries,
                      onSeriesSelected: (series) {
                        context.push(
                          '/series_details_page',
                          extra: {
                            'series': series,
                            'user': widget.user,
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 0,
        user: widget.user,
      ),
    );
  }
}
