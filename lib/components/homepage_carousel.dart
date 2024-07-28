import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class HomepageCarousel extends StatefulWidget {
  const HomepageCarousel({super.key});

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
    'https://i.pinimg.com/originals/7f/91/a1/7f91a18bcfbc35570c82063da8575be8.jpg',
    'https://www.absolutearts.com/portfolio3/a/afifaridasiddique/Still_Life-1545967888l.jpg',
    'https://cdn11.bigcommerce.com/s-x49po/images/stencil/1280x1280/products/53415/72138/1597120261997_IMG_20200811_095922__49127.1597493165.jpg?c=2',
    'https://i.pinimg.com/originals/47/7e/15/477e155db1f8f981c4abb6b2f0092836.jpg',
    'https://images.saatchiart.com/saatchi/770124/art/3760260/2830144-QFPTZRUH-7.jpg',
    'https://images.unsplash.com/photo-1471943311424-646960669fbc?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8c3RpbGwlMjBsaWZlfGVufDB8fDB8&ixlib=rb-1.2.1&w=1000&q=80',
    'https://cdn11.bigcommerce.com/s-x49po/images/stencil/1280x1280/products/40895/55777/1526876829723_P211_24X36__2018_Stilllife_15000_20090__91926.1563511650.jpg?c=2',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIUsxpakPiqVF4W_rOlq6eoLYboOFoxw45qw&usqp=CAU',
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
