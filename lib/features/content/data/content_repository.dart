import 'dart:io';
import 'package:laya/config/schema/content.dart';
import 'package:laya/config/schema/reading_progress.dart';
import 'package:laya/config/supabase_config.dart';
import 'package:laya/enums/content_status.dart';
import 'package:laya/enums/media_type.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ContentRepository {
  Future<String> uploadThumbnail(
    String contentId,
    File file,
    String title,
  ) async {
    try {
      // Sanitize the title and create base filename
      final sanitizedTitle = title
          .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special characters
          .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscores
          .toLowerCase();

      // Get file extension
      final fileExt = path.extension(file.path).toLowerCase();

      // Validate file extension
      final validExtensions = ['.jpg', '.jpeg', '.png'];
      if (!validExtensions.contains(fileExt)) {
        throw 'Invalid file type. Only JPG and PNG files are allowed.';
      }

      // Create unique filename components
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomId =
          const Uuid().v4().substring(0, 8); // First 8 chars of UUID

      // Combine components into unique filename
      final fileName =
          '${sanitizedTitle}_${contentId}_${timestamp}_$randomId$fileExt';

      await supabase.storage.from('content_thumbnails').upload(fileName, file);

      final String publicUrl =
          supabase.storage.from('content_thumbnails').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      return 'Error uploading thumbnail';
    }
  }

  Future<String> uploadMedia(File file, String contentId, String title) async {
    try {
      // Sanitize the title and create base filename
      final sanitizedTitle = title
          .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special characters
          .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscores
          .toLowerCase();

      // Get file extension
      final fileExt = path.extension(file.path).toLowerCase();

      // Validate file extension
      final validExtensions = ['.pdf', '.doc', '.docx', '.mp4', '.mov', '.avi'];
      if (!validExtensions.contains(fileExt)) {
        throw 'Invalid file type. Only JPG and PNG files are allowed.';
      }

      // Create unique filename components
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomId =
          const Uuid().v4().substring(0, 8); // First 8 chars of UUID

      // Combine components into unique filename
      final fileName =
          '${sanitizedTitle}_${contentId}_${timestamp}_$randomId$fileExt';

      await supabase.storage.from('content_media').upload(fileName, file);

      final String publicUrl =
          supabase.storage.from('content_media').getPublicUrl(fileName);

      return publicUrl;
    } on StorageException catch (e) {
      if (e.statusCode == '413') {
        return 'File size exceeds the limit. Current file size limit is 50MB.';
      }
      return 'Storage error while uploading media';
    } catch (e) {
      return 'Error uploading media';
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
      final contentData = {
        'title': title,
        'description': description,
        'creator_id': creatorId,
        'series_id': seriesId,
        'category_id': categoryId,
        'media_type': mediaType.name,
        'status': ContentStatus.draft.name,
      };

      final response =
          await supabase.from('content').insert(contentData).select().single();

      final String contentId = response['id'];

      // Upload thumbnail if provided
      String thumbnailUrl;

      thumbnailUrl = await uploadThumbnail(contentId, thumbnail, title);

      // Upload media if provided
      String mediaUrl;

      mediaUrl = await uploadMedia(mediaFile, contentId, title);

      if (thumbnailUrl == 'Error uploading thumbnail' ||
          mediaUrl == 'Error uploading media') {
        throw 'Error uploading files';
      }

      // Update content with URLs
      final updates = {'thumbnail_url': thumbnailUrl, 'media_url': mediaUrl};

      final updatedResponse = await supabase
          .from('content')
          .update(updates)
          .eq('id', contentId)
          .select()
          .single();

      return Content.fromJson(updatedResponse);
    } catch (e) {
      throw 'Failed to create content';
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
      // Update content entry
      final contentData = {
        'title': title,
        'description': description,
        'category_id': categoryId,
        'media_type': mediaType.name,
      };

      final response = await supabase
          .from('content')
          .update(contentData)
          .eq('id', contentId)
          .select()
          .single();

      // Upload thumbnail if provided
      String thumbnailUrl;

      thumbnailUrl = await uploadThumbnail(contentId, thumbnail, title);

      // Upload media if provided
      String mediaUrl;

      mediaUrl = await uploadMedia(mediaFile, contentId, title);

      if (thumbnailUrl == 'Error uploading thumbnail' ||
          mediaUrl == 'Error uploading media') {
        throw 'Error uploading files';
      }

      // Update content with URLs
      final updates = {'thumbnail_url': thumbnailUrl, 'media_url': mediaUrl};

      final updatedResponse = await supabase
          .from('content')
          .update(updates)
          .eq('id', contentId)
          .select()
          .single();

      return Content.fromJson(updatedResponse);
    } catch (e) {
      throw 'Failed to update content';
    }
  }

  // Delete content by ID
  Future<bool> deleteContent(String contentId) async {
    try {
      // Get content details first
      final content =
          await supabase.from('content').select().eq('id', contentId).single();

      // Delete media files from storage
      final thumbnailFileName = content['thumbnail_url'].split('/').last;
      final mediaFileName = content['media_url'].split('/').last;

      await supabase.storage
          .from('content_thumbnails')
          .remove([thumbnailFileName]);

      await supabase.storage.from('content_media').remove([mediaFileName]);

      // Delete content record
      await supabase.from('content').delete().eq('id', contentId);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get content by ID
  Future<Content> getContent(String contentId) async {
    try {
      final response = await supabase.from('content').select('''
            *,
            series:series_id(
              id,
              title
            ),
            creator:creator_id(
              id,
              username,
              avatar_url
            )
          ''').eq('id', contentId).single();

      if (response.isEmpty) {
        throw 'No content found';
      }

      return Content.fromJson(response);
    } catch (e) {
      throw 'Failed to load content';
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
      final response = await getReadingProgress(
        contentId: contentId,
        userId: userId,
      );

      if (response == null) {
        await supabase.from('reading_progress').insert({
          'content_id': contentId,
          'user_id': userId,
          'current_page': currentPage,
          'progress': progress,
          'last_read': DateTime.now().toIso8601String(),
        });
      } else {
        await supabase
            .from('reading_progress')
            .update({
              'current_page': currentPage,
              'progress': progress,
              'last_read': DateTime.now().toIso8601String(),
            })
            .eq('content_id', contentId)
            .eq('user_id', userId);
      }
    } catch (e) {
      throw 'Failed to save reading progress';
    }
  }

  // Get reading progress for a specific content and user
  Future<ReadingProgress?> getReadingProgress({
    required String contentId,
    required String userId,
  }) async {
    try {
      final response = await supabase
          .from('reading_progress')
          .select()
          .eq('content_id', contentId)
          .eq('user_id', userId)
          .single();

      return ReadingProgress.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      throw 'Failed to load reading progress';
    } catch (e) {
      throw 'Failed to load reading progress';
    }
  }

  // Get all content by series ID
  Future<List<Content>> getContentsBySeries(String seriesId) async {
    try {
      final response = await supabase.from('content').select().eq(
            'series_id',
            seriesId,
          );
      return response.map((e) => Content.fromJson(e)).toList();
    } catch (e) {
      throw 'Failed to load content';
    }
  }

  // Update content status
  Future<void> updateContentStatus({
    required String contentId,
    required ContentStatus status,
  }) async {
    try {
      await supabase.from('content').update({
        'status': status.name,
        'published_at': DateTime.now().toIso8601String(),
      }).eq('id', contentId);
    } catch (e) {
      throw 'Failed to update content status';
    }
  }
}
