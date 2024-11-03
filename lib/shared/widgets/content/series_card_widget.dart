import 'package:flutter/material.dart';

class SeriesCard extends StatefulWidget {
  final String? title;
  final int? chapters;
  final String? thumbnailURL;
  final void Function() onTap;

  const SeriesCard({
    super.key,
    required this.title,
    required this.chapters,
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
                ? Image.network(
                    widget.thumbnailURL!,
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.2,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.2,
                    color: Colors.grey,
                  ),
            widget.chapters != null
                ? Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.01,
                        vertical: screenHeight * 0.0025,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius:
                            BorderRadius.circular(screenHeight * 0.01),
                      ),
                      child: Text(
                        widget.chapters.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
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
                  style: const TextStyle(
                    color: Colors.white,
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
