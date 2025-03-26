import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/models/series_model.dart';

class SeriesCard extends StatelessWidget {
  final Series series;

  const SeriesCard({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/series_details',
        extra: {'series': series},
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Image
            series.coverImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: series.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.image,
                          color: Colors.white54,
                          size: 32,
                        ),
                      );
                    },
                  )
                : Image.asset('assets/images/placeholder_thumbnail.png'),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
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
                padding: const EdgeInsets.all(8),
                child: Text(
                  series.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
