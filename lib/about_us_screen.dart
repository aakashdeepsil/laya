import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'About Us',
          style: TextStyle(
            fontSize: screenHeight * 0.025,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: screenHeight * 0.3,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/app_logo.png'),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenHeight * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      icon: Icons.lightbulb_outline,
                      title: 'Our Vision',
                      content:
                          'Welcome to LAYA, your go-to platform for discovering and enjoying original stories. We bring a world of captivating stories straight to your fingertips, offering an easy-to-use interface that makes reading a pleasure.',
                      colorScheme: Theme.of(context).colorScheme,
                    ),
                    _buildSection(
                      icon: Icons.people_outline,
                      title: 'Community',
                      content:
                          'At LAYA, we believe in the power of creativity and community. That\'s why we\'ve created a space where anyone can build, share, and grow their content. Whether you\'re an aspiring creator or a passionate reader, our platform is designed to connect you with like-minded individuals.',
                      colorScheme: Theme.of(context).colorScheme,
                    ),
                    // _buildSection(
                    //   icon: Icons.connect_without_contact,
                    //   title: 'Social Features',
                    //   content:
                    //       'Our socials section allows users to dive deep into discussions, share their thoughts, and form bonds with others who share their interests. Through hyper social media engagement, we aim to create a thriving, retainable user base that grows together.',
                    //   colorScheme: Theme.of(context).colorScheme,
                    // ),
                    _buildSection(
                      icon: Icons.star_outline,
                      title: 'Premium Experience',
                      content:
                          'For those looking for something extra, our premium service offers access to the latest and most highly anticipated content. As our community expands, we\'re excited to introduce new features, including a marketplace for content creators.',
                      colorScheme: Theme.of(context).colorScheme,
                    ),
                    _buildSection(
                      icon: Icons.public,
                      title: 'Local Focus',
                      content:
                          'LAYA is committed to filling the gap in the webtoon and web novel space by rapidly expanding and innovating. With a strong focus on localized content and a wide variety of storytelling, we\'re here to promote Indian original content creators.',
                      colorScheme: Theme.of(context).colorScheme,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                      ),
                      padding: EdgeInsets.all(screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Join us at LAYA',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: screenHeight * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'Where stories come to life and communities thrive.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenHeight * 0.018,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required ColorScheme colorScheme,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: colorScheme.primary,
                size: screenHeight * 0.03,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                title,
                style: TextStyle(
                  fontSize: screenHeight * 0.0225,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            content,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.8),
              fontSize: screenHeight * 0.018,
              height: screenHeight * 0.002,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
