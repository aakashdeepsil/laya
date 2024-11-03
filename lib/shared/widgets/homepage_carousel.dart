import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:laya/config/schema/user.dart';

class HomepageCarousel extends StatefulWidget {
  final User user;

  const HomepageCarousel({super.key, required this.user});

  @override
  State<HomepageCarousel> createState() => _HomepageCarouselState();
}

class _HomepageCarouselState extends State<HomepageCarousel> {
  // Wheater to loop through elements
  final bool _loop = true;

  // Get screen width of viewport.
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  List<String> kDemoImages = [
    'https://naruto-official.com/common/ogp/NTOS_OG-main.png',
    'https://cdn.europosters.eu/image/hp/50779.jpg',
  ];

  // Width of each item
  double? _mainCarouselItemWidth;

  // Scroll controller for carousel
  late InfiniteScrollController _mainController;

  // Maintain current index of carousel
  int _mainControllerselectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _mainController =
        InfiniteScrollController(initialItem: _mainControllerselectedIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainCarouselItemWidth = screenWidth;
  }

  @override
  void dispose() {
    super.dispose();
    _mainController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.25,
      child: InfiniteCarousel.builder(
        center: false,
        velocityFactor: 0.75,
        itemCount: kDemoImages.length,
        itemExtent: _mainCarouselItemWidth ?? 50,
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
        controller: _mainController,
        onIndexChanged: (index) {
          if (_mainControllerselectedIndex != index) {
            setState(() {
              _mainControllerselectedIndex = index;
            });
          }
        },
        itemBuilder: (context, itemIndex, realIndex) {
          return GestureDetector(
            onTap: () {
              context.push('/view_video_content_page', extra: widget.user);
              _mainController.animateToItem(realIndex);
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: kElevationToShadow[2],
                image: DecorationImage(
                  image: NetworkImage(kDemoImages[itemIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
