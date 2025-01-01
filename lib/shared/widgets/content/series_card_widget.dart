import 'package:flutter/material.dart';
import 'package:laya/shared/widgets/cached_image_widget.dart';

class SeriesCard extends StatefulWidget {
  final String? title;
  final String? thumbnailURL;
  final void Function() onTap;

  const SeriesCard({
    super.key,
    required this.title,
    required this.thumbnailURL,
    required this.onTap,
  });

  @override
  State<SeriesCard> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<SeriesCard> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            widget.thumbnailURL != null
                ? CachedImageWidget(
                    imageUrl: widget.thumbnailURL!,
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.2,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.2,
                    color: Colors.grey,
                  ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(screenHeight * 0.01),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  widget.title ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight * 0.017,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
