import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  // Get screen width of viewport.
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ABOUT US',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenHeight * 0.02,
            vertical: screenHeight * 0.02,
          ),
          child: Text(
            '''
Welcome to LAYA, your go-to platform for discovering and enjoying original webtoons and web novels. We bring a world of captivating stories straight to your fingertips, offering an easy-to-use interface that makes reading a pleasure.

At LAYA, we believe in the power of creativity and community. That’s why we’ve created a space where anyone can build, share, and grow their content. Whether you're an aspiring creator or a passionate reader, our platform is designed to connect you with like-minded individuals and vibrant communities through our engaging social features.

We’re more than just a content platform—we’re a community. Our socials section allows users to dive deep into discussions, share their thoughts, and form bonds with others who share their interests. Through hyper social media engagement, both within the app and across other platforms, we aim to create a thriving, retainable user base that grows together.

For those looking for something extra, our premium service offers access to the latest and most highly anticipated content. As our community expands, we’re excited to introduce new features, including a marketplace that will empower content creators and merchandise sellers to boost their growth and engage with their followers in new and creative ways.

LAYA is committed to filling the gap in the webtoon and web novel space by rapidly expanding and innovating. With a strong focus on localized content and a wide variety of storytelling, we’re here to promote Indian original content creators and provide a platform that celebrates diversity in narrative.

Join us at LAYA—where stories come to life and communities thrive.
''',
            style: TextStyle(
              fontSize: screenHeight * 0.025,
            ),
          ),
        ),
      )),
    );
  }
}
