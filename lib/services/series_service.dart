import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/services/ai_service.dart';
import 'package:path/path.dart' as path;

class SeriesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _seriesCollection =
      FirebaseFirestore.instance.collection('series');
  final AIService _aiService = AIService();

  // Get all series for a user
  Future<List<Series>> getUserSeries(String userId) async {
    final snapshot = await _seriesCollection
        .where('creator_id', isEqualTo: userId)
        .orderBy('updated_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => Series.fromFirestore(doc)).toList();
  }

  // Get series by ID
  Future<Series?> getSeriesById(String seriesId) async {
    final doc = await _seriesCollection.doc(seriesId).get();

    if (!doc.exists) return null;
    return Series.fromFirestore(doc);
  }

  // Create a new series
  Future<String> createSeries(Series series) async {
    try {
      // Create the series first
      final docRef = await _seriesCollection.add(series.toFirestore());

      // Generate and update the embedding
      await generateSeriesEmbedding(docRef.id);

      return docRef.id;
    } catch (e) {
      throw 'Failed to create series: ${e.toString()}';
    }
  }

  // Update an existing series
  Future<Series> updateSeries({
    required Series series,
    File? newCoverImage,
    File? newThumbnail,
  }) async {
    try {
      // Get the existing series
      final existingSeries = await getSeriesById(series.id);
      if (existingSeries == null) {
        throw 'Series not found';
      }

      // Check if title or description has changed
      final needsNewEmbedding = series.title != existingSeries.title ||
          series.description != existingSeries.description;

      // Handle file uploads if provided
      String? coverImageUrl;
      String? thumbnailUrl;

      if (newCoverImage != null) {
        // Get file extension
        final fileExt = path.extension(newCoverImage.path).toLowerCase();

        // Validate file extension
        final validExtensions = ['.jpg', '.jpeg', '.png'];
        if (!validExtensions.contains(fileExt)) {
          throw 'Invalid file type. Only JPG and PNG files are allowed.';
        }

        // Upload to Firebase Storage with new naming convention
        final storageRef = FirebaseStorage.instance.ref();
        final coverImageRef =
            storageRef.child('series_cover/${series.id}/cover$fileExt');

        await coverImageRef.putFile(newCoverImage);
        coverImageUrl = await coverImageRef.getDownloadURL();
      }

      if (newThumbnail != null) {
        // Get file extension
        final fileExt = path.extension(newThumbnail.path).toLowerCase();

        // Validate file extension
        final validExtensions = ['.jpg', '.jpeg', '.png'];
        if (!validExtensions.contains(fileExt)) {
          throw 'Invalid file type. Only JPG and PNG files are allowed.';
        }

        // Upload to Firebase Storage with new naming convention
        final storageRef = FirebaseStorage.instance.ref();
        final thumbnailRef =
            storageRef.child('series_thumbnail/${series.id}/thumbnail$fileExt');

        await thumbnailRef.putFile(newThumbnail);
        thumbnailUrl = await thumbnailRef.getDownloadURL();
      }

      // Create updated series with new image URLs if applicable
      final updatedSeries = series.copyWith(
        coverImageUrl: coverImageUrl ?? series.coverImageUrl,
        thumbnailUrl: thumbnailUrl ?? series.thumbnailUrl,
      );

      // Update Firestore document
      await _seriesCollection
          .doc(series.id)
          .update(updatedSeries.toFirestore());

      // Generate new embedding if needed
      if (needsNewEmbedding) {
        await generateSeriesEmbedding(series.id);
      }

      // Return updated series
      return updatedSeries;
    } catch (e) {
      throw 'Failed to update series: ${e.toString()}';
    }
  }

  // Get recently added series
  Future<List<Series>> getRecentSeries({int limit = 10}) async {
    try {
      final snapshot = await _seriesCollection
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Series.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Failed to fetch recent series: ${e.toString()}';
    }
  }

  // Delete a series and its associated files
  Future<void> deleteSeries(String seriesId) async {
    try {
      await _seriesCollection.doc(seriesId).delete();
      await deleteSeriesImage(seriesId, 'cover');
      await deleteSeriesImage(seriesId, 'thumbnail');
    } catch (e) {
      throw Exception('Failed to delete series: $e');
    }
  }

  // Helper method to delete a specific series image (cover or thumbnail)
  Future<void> deleteSeriesImage(String seriesId, String imageType) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final seriesRef = storageRef.child(
        imageType == 'cover'
            ? 'series_cover/$seriesId'
            : 'series_thumbnail/$seriesId',
      );

      // List all files in the series directory
      final items = await seriesRef.listAll();

      // Find and delete the specific image type
      for (var item in items.items) {
        if (item.name.startsWith(imageType)) {
          await item.delete();
        }
      }
    } catch (e) {
      print('Error deleting $imageType image: $e');
    }
  }

  // Helper method to delete a specific file from storage
  Future<void> deleteFile(String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef.child(path);
      await fileRef.delete();
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String seriesId) async {
    await _seriesCollection.doc(seriesId).update({
      'view_count': FieldValue.increment(1),
    });
  }

  // Search series by title and optionally by category
  Future<List<Series>> searchSeries({
    required String query,
    String? categoryId,
    int limit = 20,
  }) async {
    try {
      // Start with base query
      Query seriesQuery = _seriesCollection;

      // If category filter is provided, add it to the query
      if (categoryId != null && categoryId.isNotEmpty) {
        seriesQuery = seriesQuery.where('category_id', isEqualTo: categoryId);
      }

      // Get all the documents based on current filters
      // Note: Firestore doesn't support native text search
      final snapshot = await seriesQuery.get();

      // Perform client-side filtering for the search query
      final results = snapshot.docs
          .map((doc) => Series.fromFirestore(doc))
          .where((series) =>
              series.title.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Sort by relevance (exact match first, then contains)
      results.sort((a, b) {
        final aTitle = a.title.toLowerCase();
        final bTitle = b.title.toLowerCase();
        final queryLower = query.toLowerCase();

        // Exact matches first
        final aExact = aTitle == queryLower;
        final bExact = bTitle == queryLower;

        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;

        // Then starts with
        final aStartsWith = aTitle.startsWith(queryLower);
        final bStartsWith = bTitle.startsWith(queryLower);

        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;

        // Then alphabetically
        return aTitle.compareTo(bTitle);
      });

      // Apply limit
      return results.take(limit).toList();
    } catch (e) {
      throw 'Failed to search series: ${e.toString()}';
    }
  }

  Future<void> publishSeries(String seriesId) async {
    try {
      await _seriesCollection.doc(seriesId).update({
        'is_published': true,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to publish series: $e');
    }
  }

  Future<void> unpublishSeries(String seriesId) async {
    try {
      await _seriesCollection.doc(seriesId).update({
        'is_published': false,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to unpublish series: $e');
    }
  }

  // Vector search for series
  Future<List<Series>> vectorSearchSeries({
    required String query,
    String? categoryId,
    int limit = 20,
    double distanceThreshold = 0.7,
  }) async {
    try {
      // Generate embedding for the search query
      final queryEmbedding = await _aiService.generateEmbedding(query);

      // Start with base query
      Query seriesQuery = _seriesCollection;

      // If category filter is provided, add it to the query
      if (categoryId != null && categoryId.isNotEmpty) {
        seriesQuery = seriesQuery.where('category_id', isEqualTo: categoryId);
      }

      // Perform vector search using native Firestore query
      final snapshot = await seriesQuery
          .where('embedding', arrayContains: queryEmbedding)
          .orderBy('updated_at', descending: true)
          .limit(limit)
          .get();

      // Convert to Series objects
      final results = snapshot.docs
          .map((doc) => Series.fromFirestore(doc))
          .where((series) => series.isPublished) // Only return published series
          .toList();

      return results;
    } catch (e) {
      throw 'Failed to perform vector search: ${e.toString()}';
    }
  }

  // Generate or update embedding for a series
  Future<void> generateSeriesEmbedding(String seriesId) async {
    try {
      final series = await getSeriesById(seriesId);
      if (series == null) {
        throw 'Series not found';
      }

      // Combine title and description for embedding
      final text = '${series.title} ${series.description}';
      final embedding = await _aiService.generateEmbedding(text);

      // Update series with new embedding
      await _seriesCollection.doc(seriesId).update({
        'embedding': embedding,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to generate series embedding: ${e.toString()}';
    }
  }
}
