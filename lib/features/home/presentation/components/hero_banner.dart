// Build the hero banner with featured content
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:laya/features/home/data/models/content_model.dart';

Widget buildHeroBanner(FeaturedBook book, Size screenSize) {
  return Stack(
    children: [
      // Banner image
      CachedNetworkImage(
        imageUrl: book.coverImage,
        height: screenSize.height * 0.7,
        width: screenSize.width,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFF1e293b),
        ),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFF1e293b),
          child: const Icon(Icons.error, color: Colors.white),
        ),
      ),

      // Gradient overlay
      Container(
        height: screenSize.height * 0.7,
        width: screenSize.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
            stops: const [0.3, 1.0],
          ),
        ),
      ),

      // Content overlay
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                book.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.08,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.75),
                    ),
                  ],
                ),
              ),

              // Author
              const SizedBox(height: 8),
              Text(
                'by ${book.author}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),

              // Tags
              const SizedBox(height: 12),
              Row(
                children: book.tags
                    .map((tag) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),

              // Description
              const SizedBox(height: 12),
              Text(
                book.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              // Buttons
              const SizedBox(height: 20),
              Row(
                children: [
                  // Read Now button
                  ElevatedButton(
                    onPressed: () {
                      // Handle read action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe50914),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Read Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Add to list button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle add to list action
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'My List',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
