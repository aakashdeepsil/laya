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
  List<Series> topActionSeries = [];
  List<Series> topHorrorSeries = [];
  List<Series> topMysterySeries = [];
  List<Series> topRomanceSeries = [];
  List<Series> topDocumentarySeries = [];
  List<Series> topComedySeries = [];
  List<Series> topDramaSeries = [];
  List<Series> topSciFiSeries = [];

  bool isFetchingMostRecentlyAddedSeries = false;
  bool isActionSeries = false;
  bool isHorrorSeries = false;
  bool isMysterySeries = false;
  bool isRomanceSeries = false;
  bool isDocumentarySeries = false;
  bool isComedySeries = false;
  bool isDramaSeries = false;
  bool isSciFiSeries = false;

  @override
  void initState() {
    super.initState();
    _loadMostRecentlyAddedSeries();
    _loadTopActionSeries();
    _loadTopHorrorSeries();
    _loadTopMysterySeries();
    _loadTopRomanceSeries();
    _loadTopDocumentarySeries();
    _loadTopComedySeries();
    _loadTopDramaSeries();
    _loadTopSciFiSeries();
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

  // Load top action series
  Future<void> _loadTopActionSeries() async {
    try {
      setState(() => isActionSeries = true);
      final response = await _seriesRepository.getTopActionSeries();
      topActionSeries = response;
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
      setState(() => isActionSeries = false);
    }
  }

  // Load top horror series
  Future<void> _loadTopHorrorSeries() async {
    try {
      setState(() => isHorrorSeries = true);
      final response = await _seriesRepository.getTopHorrorSeries();
      topHorrorSeries = response;
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
      setState(() => isHorrorSeries = false);
    }
  }

  // Load top mystery series
  Future<void> _loadTopMysterySeries() async {
    try {
      setState(() => isMysterySeries = true);
      final response = await _seriesRepository.getTopMysterySeries();
      topMysterySeries = response;
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
      setState(() => isMysterySeries = false);
    }
  }

  // Load top romance series
  Future<void> _loadTopRomanceSeries() async {
    try {
      setState(() => isRomanceSeries = true);
      final response = await _seriesRepository.getTopRomanceSeries();
      topRomanceSeries = response;
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
      setState(() => isRomanceSeries = false);
    }
  }

  // Load top documentary series
  Future<void> _loadTopDocumentarySeries() async {
    try {
      setState(() => isDocumentarySeries = true);
      final response = await _seriesRepository.getTopDocumentarySeries();
      topDocumentarySeries = response;
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
      setState(() => isDocumentarySeries = false);
    }
  }

  // Load top comedy series
  Future<void> _loadTopComedySeries() async {
    try {
      setState(() => isComedySeries = true);
      final response = await _seriesRepository.getTopComedySeries();
      topComedySeries = response;
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
      setState(() => isComedySeries = false);
    }
  }

  // Load top drama series
  Future<void> _loadTopDramaSeries() async {
    try {
      setState(() => isDramaSeries = true);
      final response = await _seriesRepository.getTopDramaSeries();
      topDramaSeries = response;
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
      setState(() => isDramaSeries = false);
    }
  }

  // Load top sci-fi series
  Future<void> _loadTopSciFiSeries() async {
    try {
      setState(() => isSciFiSeries = true);
      final response = await _seriesRepository.getTopSciFiSeries();
      topSciFiSeries = response;
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
      setState(() => isSciFiSeries = false);
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
          child: isFetchingMostRecentlyAddedSeries &&
                  isActionSeries &&
                  isHorrorSeries &&
                  isMysterySeries &&
                  isRomanceSeries &&
                  isDocumentarySeries &&
                  isComedySeries &&
                  isDramaSeries &&
                  isSciFiSeries
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    mostRecentlyAddedSeries.isNotEmpty
                        ? const SectionTile(title: 'Recently Added')
                        : Container(),
                    SeriesCarousel(
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
                    SizedBox(height: screenHeight * 0.02),
                    topActionSeries.isNotEmpty
                        ? const SectionTile(title: 'Top Action Series')
                        : Container(),
                    SeriesCarousel(
                      seriesList: topActionSeries,
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
                    SizedBox(height: screenHeight * 0.02),
                    topHorrorSeries.isNotEmpty
                        ? const SectionTile(title: 'Top Horror Series')
                        : Container(),
                    SeriesCarousel(
                      seriesList: topHorrorSeries,
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
                    SizedBox(height: screenHeight * 0.02),
                    topMysterySeries.isNotEmpty
                        ? const SectionTile(title: 'Top Mystery Series')
                        : Container(),
                    SeriesCarousel(
                      seriesList: topMysterySeries,
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
                    SizedBox(height: screenHeight * 0.02),
                    topRomanceSeries.isNotEmpty
                        ? const SectionTile(title: 'Top Romance Series')
                        : Container(),
                    SeriesCarousel(
                      seriesList: topRomanceSeries,
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
                    // SizedBox(height: screenHeight * 0.02),
                    // isDocumentarySeries
                    //     ? const Center(child: CircularProgressIndicator())
                    //     : topDocumentarySeries.isNotEmpty
                    //         ? const SectionTile(title: 'Top Documentary Series')
                    //         : Container(),
                    // if (isDocumentarySeries)
                    //   SeriesCarousel(
                    //     seriesList: topDocumentarySeries,
                    //     onSeriesSelected: (series) {
                    //       context.push(
                    //         '/series_details_page',
                    //         extra: {
                    //           'series': series,
                    //           'user': widget.user,
                    //         },
                    //       );
                    //     },
                    //   ),
                    // SizedBox(height: screenHeight * 0.02),
                    // isComedySeries
                    //     ? const Center(child: CircularProgressIndicator())
                    //     : topComedySeries.isNotEmpty
                    //         ? const SectionTile(title: 'Top Comedy Series')
                    //         : Container(),
                    // if (isComedySeries)
                    //   SeriesCarousel(
                    //     seriesList: topComedySeries,
                    //     onSeriesSelected: (series) {
                    //       context.push(
                    //         '/series_details_page',
                    //         extra: {
                    //           'series': series,
                    //           'user': widget.user,
                    //         },
                    //       );
                    //     },
                    //   ),
                    SizedBox(height: screenHeight * 0.02),
                    topDramaSeries.isNotEmpty
                        ? const SectionTile(title: 'Top Drama Series')
                        : Container(),
                    SeriesCarousel(
                      seriesList: topDramaSeries,
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
                    SizedBox(height: screenHeight * 0.02),
                    topSciFiSeries.isNotEmpty
                        ? const SectionTile(title: 'Top Sci-Fi Series')
                        : Container(),
                    SeriesCarousel(
                      seriesList: topSciFiSeries,
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
