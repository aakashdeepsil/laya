import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/shared/widgets/bottom_navigation_bar_widget.dart';
import 'package:laya/config/schema/profiles.dart';
import 'package:laya/config/supabase_config.dart';
import 'package:laya/components/content_carousel.dart';
import 'package:laya/components/homepage_carousel.dart';

class HomePage extends StatefulWidget {
  final Profile profile;

  const HomePage({super.key, required this.profile});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
  }

  Future<void> _checkProfileCompletion() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId != null) {
      final data =
          await supabase.from('users').select().eq('id', userId).single();

      if (data['username'].isEmpty &&
          data['first_name'].isEmpty &&
          data['last_name'].isEmpty) {
        if (mounted) {
          context.go('/complete_profile');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LAYA')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const HomepageCarousel(),
              SizedBox(height: screenHeight * 0.025),
              _buildSectionTitle('Top WebToons'),
              ContentCarousel(content: anime, titles: titles),
              SizedBox(height: screenHeight * 0.025),
              _buildSectionTitle('Continue Watching'),
              ContentCarousel(content: anime, titles: titles),
              SizedBox(height: screenHeight * 0.025),
              _buildSectionTitle('Continue Reading'),
              ContentCarousel(content: anime, titles: titles),
              SizedBox(height: screenHeight * 0.025),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: 0,
        profile: widget.profile,
      ),
    );
  }

  Padding _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: screenHeight * 0.01,
        left: screenWidth * 0.025,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenHeight * 0.025,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
