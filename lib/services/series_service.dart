import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:laya/models/series_model.dart';
import 'package:path/path.dart' as path;

class SeriesService {
  final CollectionReference _seriesCollection =
      FirebaseFirestore.instance.collection('series');

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
    final docRef = await _seriesCollection.add(series.toFirestore());
    return docRef.id;
  }

  // Update an existing series
  Future<Series> updateSeries({
    required Series series,
    File? newCoverImage,
    File? newThumbnail,
  }) async {
    try {
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
}
