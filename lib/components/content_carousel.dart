import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

class ContentCarousel extends StatefulWidget {
  const ContentCarousel({super.key});

  @override
  State<ContentCarousel> createState() => _ContentCarouselState();
}

class _ContentCarouselState extends State<ContentCarousel> {
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
        itemCount: kDemoImages.length,
        itemExtent: _topWebToonsCarouselItemWidth ?? 50,
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
                          image: NetworkImage(kDemoImages[itemIndex]),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'WebToon Title',
                    style: TextStyle(fontSize: screenHeight * 0.02),
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
