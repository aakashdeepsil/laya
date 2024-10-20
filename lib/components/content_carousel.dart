import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class ContentCarousel extends StatefulWidget {
  final List<String> content;
  final List<String> titles;

  const ContentCarousel({
    super.key,
    required this.content,
    required this.titles,
  });

  @override
  State<ContentCarousel> createState() => _ContentCarouselState();
}

class _ContentCarouselState extends State<ContentCarousel> {
  // Wheater to loop through elements
  final bool _loop = true;

  // Scroll controller for carousel
  late InfiniteScrollController _topWebToonsController;

  // Maintain current index of carousel
  int _topWebToonsControllerselectedIndex = 0;

  // Width of each item
  double? _topWebToonsCarouselItemWidth;

  // Get screen width of viewport.
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  void initState() {
    super.initState();
    _topWebToonsController = InfiniteScrollController(
      initialItem: _topWebToonsControllerselectedIndex,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _topWebToonsCarouselItemWidth = screenWidth - 250;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.2,
      child: InfiniteCarousel.builder(
        center: false,
        velocityFactor: 0.75,
        itemCount: widget.content.length,
        itemExtent: _topWebToonsCarouselItemWidth ?? screenWidth * 0.9,
        scrollBehavior: kIsWeb
            ? ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  // Allows to swipe in web browsers
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              )
            : null,
        loop: _loop,
        controller: _topWebToonsController,
        onIndexChanged: (index) {
          if (_topWebToonsControllerselectedIndex != index) {
            setState(() {
              _topWebToonsControllerselectedIndex = index;
            });
          }
        },
        itemBuilder: (context, itemIndex, realIndex) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.025,
            ),
            child: GestureDetector(
              onTap: () {
                _topWebToonsController.animateToItem(realIndex);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          image: NetworkImage(widget.content[itemIndex]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    widget.titles[itemIndex],
                    style: TextStyle(fontSize: screenHeight * 0.015),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
