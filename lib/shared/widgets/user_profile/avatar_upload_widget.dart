import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laya/config/supabase_config.dart';

class AvatarUploadWidget extends StatefulWidget {
  final String currentAvatarUrl;
  final Function(String) onUpload;
  final bool isLoading;
  final String userID;

  const AvatarUploadWidget({
    super.key,
    required this.currentAvatarUrl,
    required this.onUpload,
    this.isLoading = false,
    required this.userID,
  });

  @override
  State<AvatarUploadWidget> createState() => _AvatarUploadWidgetState();
}

class _AvatarUploadWidgetState extends State<AvatarUploadWidget> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  Future<void> _uploadAvatar() async {
    try {
      // Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? imageFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 85,
      );

      if (imageFile == null) return;

      final String fileExtension = imageFile.path.split('.').last;

      if (widget.currentAvatarUrl.isNotEmpty) {
        final oldFileName = widget.currentAvatarUrl.split('/').last;
        await supabase.storage.from('avatars').remove([oldFileName]);
      }

      // Upload to Supabase Storage
      final String fileName =
          '${DateTime.now().toIso8601String()}_${supabase.auth.currentUser!.id}.$fileExtension';

      final storageResponse = await supabase.storage
          .from('avatars')
          .upload(fileName, File(imageFile.path));

      if (storageResponse.isEmpty) throw 'Upload failed';

      // Get public URL
      final String publicUrl =
          supabase.storage.from('avatars').getPublicUrl(fileName);

      await supabase
          .from('users')
          .update({'avatar_url': publicUrl}).eq('id', widget.userID);

      // Call the onUpload callback
      await widget.onUpload(publicUrl);
    } catch (error) {
      debugPrint('Error uploading avatar: $error');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: screenHeight * 0.12,
          height: screenHeight * 0.12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.currentAvatarUrl.isEmpty
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : null,
            image: widget.currentAvatarUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(widget.currentAvatarUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: widget.currentAvatarUrl.isEmpty
              ? Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: screenHeight * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: widget.isLoading ? null : _uploadAvatar,
            child: Container(
              padding: EdgeInsets.all(screenHeight * 0.008),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.edit,
                size: screenHeight * 0.02,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        if (widget.isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
