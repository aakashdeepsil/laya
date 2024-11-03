import 'package:flutter/material.dart';

class SectionTile extends StatefulWidget {
  final String title;

  const SectionTile({super.key, required this.title});

  @override
  State<SectionTile> createState() => _SectionTileState();
}

class _SectionTileState extends State<SectionTile> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: screenHeight * 0.005,
        left: screenWidth * 0.025,
      ),
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: screenHeight * 0.02,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
