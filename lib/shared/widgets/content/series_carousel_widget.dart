import 'package:flutter/material.dart';
import 'package:laya/config/schema/series.dart';
import 'package:laya/shared/widgets/content/series_card_widget.dart';

class SeriesCarousel extends StatefulWidget {
  final List<Series>? seriesList;
  final Function(Series)? onSeriesSelected;

  const SeriesCarousel({
    super.key,
    required this.seriesList,
    this.onSeriesSelected,
  });

  @override
  State<SeriesCarousel> createState() => _SeriesCarouselState();
}

class _SeriesCarouselState extends State<SeriesCarousel> {
  final ScrollController _scrollController = ScrollController();

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.2,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.seriesList!.length,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        itemBuilder: (context, index) {
          final series = widget.seriesList![index];
          return Container(
            margin: EdgeInsets.only(right: screenWidth * 0.03),
            width: screenWidth * 0.3,
            child: SeriesCard(
              title: null,
              chapters: null,
              thumbnailURL: series.thumbnailUrl,
              onTap: () => widget.onSeriesSelected?.call(series),
            ),
          );
        },
      ),
    );
  }
}
