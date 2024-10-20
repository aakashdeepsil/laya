import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/components/bottom_navigation_bar.dart';
import 'package:laya/components/content_carousel.dart';
import 'package:laya/components/homepage_carousel.dart';
import 'package:laya/constants.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Get screen width of viewport.
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  List<String> anime = [
    'https://qph.cf2.quoracdn.net/main-qimg-5abcf39750a6e0f1074f1249b66d6445',
    'https://wallpapercave.com/wp/wp10508780.jpg',
    'https://mlpnk72yciwc.i.optimole.com/cqhiHLc.IIZS~2ef73/w:auto/h:auto/q:75/https://bleedingcool.com/wp-content/uploads/2020/10/ChainsawMan_GN01_C1_Web-copy.jpg',
    'https://upload.wikimedia.org/wikipedia/en/9/90/One_Piece%2C_Volume_61_Cover_%28Japanese%29.jpg',
  ];

  List<String> titles = [
    'My Hero Academia',
    'Jujutsu Kaisen',
    'Chainsawman',
    'One Piece',
  ];

  Future<void> checkProfileCompletion() async {
    String userId = Supabase.instance.client.auth.currentSession!.user.id;

    var data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    if (data['username'].length == 0 &&
        data['first_name'].length == 0 &&
        data['last_name'].length == 0) {
      if (mounted) {
        context.go('/complete_profile');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkProfileCompletion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(screenHeight, 'LAYA'),
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
                padding: EdgeInsets.only(
                  bottom: screenHeight * 0.01,
                  left: screenWidth * 0.025,
                ),
                child: Text(
                  'Top WebToons',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ContentCarousel(content: anime, titles: titles),
              SizedBox(height: screenHeight * 0.025),
              Padding(
                padding: EdgeInsets.only(
                  bottom: screenHeight * 0.01,
                  left: screenWidth * 0.025,
                ),
                child: Text(
                  'Continue Watching',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ContentCarousel(content: anime, titles: titles),
              SizedBox(height: screenHeight * 0.025),
              Padding(
                padding: EdgeInsets.only(
                  bottom: screenHeight * 0.01,
                  left: screenWidth * 0.025,
                ),
                child: Text(
                  'Continue Reading',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ContentCarousel(content: anime, titles: titles),
              SizedBox(height: screenHeight * 0.025),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MyBottomNavigationBar(index: 0),
    );
  }
}
