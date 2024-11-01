import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/user.dart';

class ContentGridView extends StatefulWidget {
  final User user;

  const ContentGridView({super.key, required this.user});

  @override
  State<ContentGridView> createState() => _ContentGridViewState();
}

class _ContentGridViewState extends State<ContentGridView> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 4, // Replace with actual content count
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            // Navigate to content detail
            context.push('/content/$index');
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/anime_$index.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
