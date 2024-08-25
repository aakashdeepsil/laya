import 'package:flutter/material.dart';
import 'package:laya/components/bottom_navigation_bar.dart';
import 'package:laya/components/content_carousel.dart';
import 'package:laya/components/homepage_carousel.dart';
import 'package:laya/constants.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('LAYA'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const HomepageCarousel(),
              SizedBox(height: screenHeight * 0.025),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.025),
                child: Text(
                  'Top WebToons',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const ContentCarousel(),
              SizedBox(height: screenHeight * 0.025),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.025),
                child: Text(
                  'Continue Watching',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const ContentCarousel(),
              SizedBox(height: screenHeight * 0.025),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.025),
                child: Text(
                  'Continue Reading',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const ContentCarousel(),
              SizedBox(height: screenHeight * 0.025),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MyBottomNavigationBar(index: 0),
    );
  }
}
