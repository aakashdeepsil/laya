import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  // Get screen width of viewport.
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/laya_logo.jpeg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenHeight * 0.02,
                    ),
                    child: Text(
                      "INDIA'S BIGGEST WEBTOONS PLATFORM",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        child: ElevatedButton(
                          onPressed: () => context.push('/sign_in'),
                          child: Text(
                            "GET STARTED",
                            style: TextStyle(
                              fontSize: screenHeight * 0.017,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        child: ElevatedButton(
                          onPressed: () => context.push('/about_us'),
                          child: Text(
                            "ABOUT US",
                            style: TextStyle(
                              fontSize: screenHeight * 0.017,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
