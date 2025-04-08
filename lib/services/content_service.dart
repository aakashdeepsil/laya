import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:laya/models/content_model.dart';
import 'package:laya/models/reading_progress.dart';
import 'package:laya/enums/content_status.dart';
import 'package:laya/enums/media_type.dart';
import 'package:path/path.dart' as path;

class ContentService {
  final CollectionReference _contentCollection =
      FirebaseFirestore.instance.collection('content');
  final CollectionReference _readingProgressCollection =
      FirebaseFirestore.instance.collection('reading_progress');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadThumbnail(
    String contentId,
    File file,
    String title,
    String seriesId,
  ) async {
    try {
      // Get file extension
      final fileExt = path.extension(file.path).toLowerCase();

      // Validate file extension
      final validExtensions = ['.jpg', '.jpeg', '.png'];
      if (!validExtensions.contains(fileExt)) {
        throw 'Invalid file type. Only JPG and PNG files are allowed.';
      }

      // Simple, organized filename
      final fileName = '${seriesId}_${contentId}_thumbnail$fileExt';

      // Upload to Firebase Storage
      final ref = _storage.ref().child('content_thumbnails/$fileName');
      await ref.putFile(file);

      // Get download URL
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Error uploading thumbnail: ${e.toString()}';
    }
  }

  Future<String> uploadMedia(
    File file,
    String contentId,
    String title,
    String seriesId,
  ) async {
    try {
      // Get file extension
      final fileExt = path.extension(file.path).toLowerCase();

      // Validate file extension
      final validExtensions = [
        '.pdf',
        '.doc',
        '.docx',
        '.mp4',
        '.mov',
        '.avi',
        '.txt',
      ];
      if (!validExtensions.contains(fileExt)) {
        throw 'Invalid file type. Only PDF, DOC, DOCX, MP4, MOV, TXT, and AVI files are allowed.';
      }

      // Simple, organized filename
      final fileName = '${seriesId}_${contentId}_media$fileExt';

      // Upload to Firebase Storage
      final ref = _storage.ref().child('content_media/$fileName');
      await ref.putFile(file);

      // Get download URL
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Error uploading media: ${e.toString()}';
    }
  }

  // Create content entry and upload media files
  Future<Content> createContent({
    required String categoryId,
    required String creatorId,
    required String seriesId,
    required String description,
    required String title,
    required File mediaFile,
    required File thumbnail,
    required MediaType mediaType,
  }) async {
    try {
      // Create a new document reference
      final docRef = _contentCollection.doc();
      final contentId = docRef.id;

      // Upload files first
      final thumbnailUrl =
          await uploadThumbnail(contentId, thumbnail, title, seriesId);
      final mediaUrl = await uploadMedia(mediaFile, contentId, title, seriesId);

      final now = DateTime.now();
      final contentData = {
        'id': contentId,
        'title': title,
        'description': description,
        'creator_id': creatorId,
        'series_id': seriesId,
        'category_id': categoryId,
        'thumbnail_url': thumbnailUrl,
        'media_url': mediaUrl,
        'media_type': mediaType.name,
        'status': ContentStatus.draft.name,
        'is_premium': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      // Create the document
      await docRef.set(contentData);

      return Content.fromJson(contentData);
    } catch (e) {
      throw 'Failed to create content: ${e.toString()}';
    }
  }

  // Get all content by series ID
  Future<List<Content>> getContentsBySeries(String seriesId) async {
    try {
      final snapshot = await _contentCollection
          .where('series_id', isEqualTo: seriesId)
          .orderBy('created_at')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Ensure ID is included
        return Content.fromJson(data);
      }).toList();
    } catch (e) {
      throw 'Failed to load chapters: ${e.toString()}';
    }
  }

  // Get content by ID
  Future<Content> getContent(String contentId) async {
    try {
      final doc = await _contentCollection.doc(contentId).get();

      if (!doc.exists) {
        throw 'No content found';
      }

      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Ensure ID is included
      return Content.fromJson(data);
    } catch (e) {
      throw 'Failed to load content: ${e.toString()}';
    }
  }

  // Delete content by ID
  Future<bool> deleteContent(String contentId) async {
    try {
      // Get content details first
      final doc = await _contentCollection.doc(contentId).get();
      final data = doc.data() as Map<String, dynamic>;

      // Delete media files from storage
      if (data['thumbnail_url'] != null) {
        final thumbnailRef = _storage.refFromURL(data['thumbnail_url']);
        await thumbnailRef.delete();
      }

      if (data['media_url'] != null) {
        final mediaRef = _storage.refFromURL(data['media_url']);
        await mediaRef.delete();
      }

      // Delete content document
      await _contentCollection.doc(contentId).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Save reading progress for a specific content and user
  Future<void> saveReadingProgress({
    required String contentId,
    required String userId,
    required int currentPage,
    required double progress,
  }) async {
    try {
      final docId = '${userId}_$contentId';
      final docRef = _readingProgressCollection.doc(docId);
      final doc = await docRef.get();
      final now = DateTime.now().toIso8601String();

      final progressData = {
        'id': docId,
        'content_id': contentId,
        'user_id': userId,
        'current_page': currentPage,
        'progress': progress,
        'last_read': now,
        'updated_at': now,
      };

      if (!doc.exists) {
        progressData['created_at'] = now;
        await docRef.set(progressData);
      } else {
        await docRef.update(progressData);
      }
    } catch (e) {
      throw 'Failed to save reading progress: ${e.toString()}';
    }
  }

  // Get reading progress for a specific content and user
  Future<ReadingProgress?> getReadingProgress({
    required String contentId,
    required String userId,
  }) async {
    try {
      final docId = '${userId}_$contentId';
      final doc = await _readingProgressCollection.doc(docId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      // Ensure all required fields are present
      data['id'] = docId;

      // Convert timestamps if they're Firestore timestamps
      final lastRead = data['last_read'];
      if (lastRead is Timestamp) {
        data['last_read'] = lastRead.toDate().toIso8601String();
      }

      final createdAt = data['created_at'];
      if (createdAt is Timestamp) {
        data['created_at'] = createdAt.toDate().toIso8601String();
      }

      final updatedAt = data['updated_at'];
      if (updatedAt is Timestamp) {
        data['updated_at'] = updatedAt.toDate().toIso8601String();
      }

      return ReadingProgress.fromJson(data);
    } catch (e) {
      throw 'Failed to load reading progress: ${e.toString()}';
    }
  }

  // Update content status
  Future<void> updateContentStatus({
    required String contentId,
    required ContentStatus status,
  }) async {
    try {
      await _contentCollection.doc(contentId).update({
        'status': status.name,
        'published_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to update content status: ${e.toString()}';
    }
  }

  // Update reading progress
  Future<void> updateReadingProgress({
    required String contentId,
    required String userId,
    required double progress,
  }) async {
    try {
      final docId = '${userId}_$contentId';
      final docRef = _readingProgressCollection.doc(docId);
      final doc = await docRef.get();
      final now = DateTime.now().toIso8601String();

      if (!doc.exists) {
        // First time reading, create a new document
        await docRef.set({
          'id': docId,
          'content_id': contentId,
          'user_id': userId,
          'current_page': (progress * 100).round(), // Approximate current page
          'progress': progress,
          'last_read': now,
          'created_at': now,
          'updated_at': now,
        });
      } else {
        // Update existing document
        final data = doc.data() as Map<String, dynamic>;
        await docRef.update({
          'id': docId,
          'content_id': contentId,
          'user_id': userId,
          'current_page': (progress * 100).round(), // Approximate current page
          'progress': progress,
          'last_read': now,
          'updated_at': now,
        });
      }
    } catch (e) {
      throw 'Failed to update reading progress: ${e.toString()}';
    }
  }

  // Update content entry and upload media files
  Future<Content> updateContent({
    required String contentId,
    required String title,
    required String description,
    required String categoryId,
    required File thumbnail,
    required File mediaFile,
    required MediaType mediaType,
  }) async {
    try {
      final docRef = _contentCollection.doc(contentId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw 'Content not found';
      }

      final data = doc.data() as Map<String, dynamic>;
      final seriesId = data['series_id'] as String;

      final contentData = {
        'title': title,
        'description': description,
        'category_id': categoryId,
        'media_type': mediaType.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Only upload and update thumbnail if a new file is provided
      if (thumbnail.path.isNotEmpty) {
        final thumbnailUrl =
            await uploadThumbnail(contentId, thumbnail, title, seriesId);
        contentData['thumbnail_url'] = thumbnailUrl;
      }

      // Only upload and update media if a new file is provided
      if (mediaFile.path.isNotEmpty) {
        final mediaUrl =
            await uploadMedia(mediaFile, contentId, title, seriesId);
        contentData['media_url'] = mediaUrl;
      }

      // Update the document
      await docRef.update(contentData);

      // Get the updated document
      final updatedDoc = await docRef.get();
      final updatedData = updatedDoc.data() as Map<String, dynamic>;
      updatedData['id'] = contentId; // Ensure ID is included

      return Content.fromJson(updatedData);
    } catch (e) {
      throw 'Failed to update content: ${e.toString()}';
    }
  }
}
