import 'dart:developer' as developer;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laya/models/user_model.dart' as user_model;
import 'package:laya/features/library/components/shimmer_loading.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AvatarUploadWidget extends StatefulWidget {
  /// The current avatar URL of the user
  final String currentAvatarUrl;

  /// Callback function when avatar is uploaded successfully
  final Function(String) onUpload;

  /// Whether the upload is in progress
  final bool isLoading;

  /// User ID for storage reference
  final user_model.User user;

  const AvatarUploadWidget({
    super.key,
    required this.currentAvatarUrl,
    required this.onUpload,
    this.isLoading = false,
    required this.user,
  });

  @override
  State<AvatarUploadWidget> createState() => _AvatarUploadWidgetState();
}

class _AvatarUploadWidgetState extends State<AvatarUploadWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Local state to manage loading status
  bool _localLoading = false;

  // Track image load errors
  bool _hasImageLoadError = false;

  // Store preview image file
  File? _previewFile;

  @override
  void initState() {
    super.initState();

    // Setup animation controller for button press effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Shows a bottom sheet with image source options
  Future<void> _showImageSourceOptions() async {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: LucideIcons.camera,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: LucideIcons.image,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (widget.currentAvatarUrl.isNotEmpty)
                  _buildSourceOption(
                    icon: LucideIcons.trash2,
                    label: 'Remove',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      _removeAvatar();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isDestructive ? colorScheme.error : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _localLoading = true;
        _previewFile = null;
      });

      // Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? imageFile = await picker.pickImage(
        source: source,
        maxWidth: 500, // Limit size for profile pictures
        maxHeight: 500,
        imageQuality: 85, // Good quality but smaller file size
      );

      if (imageFile == null) {
        // User canceled picking
        setState(() => _localLoading = false);
        return;
      }

      // Set preview and proceed with upload
      setState(() => _previewFile = File(imageFile.path));

      // Upload the image directly
      _uploadImageToStorage(File(imageFile.path));
    } catch (error) {
      developer.log(
        'Error picking image: $error',
        name: 'AvatarUploadWidget',
        error: error,
      );
      setState(() => _localLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: ${error.toString()}'),
          ),
        );
      }
    }
  }

  // Upload image to Firebase storage and update Firebase document
  Future<void> _uploadImageToStorage(File imageFile) async {
    try {
      final String fileExtension = imageFile.path.split('.').last.toLowerCase();

      // Use consistent path pattern for user avatars
      final String filePath = 'users/${widget.user.id}/profile.$fileExtension';

      developer.log(
        'Uploading new profile picture: $filePath',
        name: 'AvatarUploadWidget',
      );

      // Delete old avatar if exists
      if (widget.currentAvatarUrl.isNotEmpty) {
        try {
          // Extract old file path from URL
          final Uri uri = Uri.parse(widget.currentAvatarUrl);
          final String oldPath = uri.path.split('/o/')[1].split('?')[0];
          final String decodedPath = Uri.decodeComponent(oldPath);

          if (decodedPath.isNotEmpty) {
            await FirebaseStorage.instance.ref(decodedPath).delete();
            developer.log(
              'Old profile picture removed: $decodedPath',
              name: 'AvatarUploadWidget',
            );
          }
        } catch (e) {
          // Log but continue if old file deletion fails
          developer.log(
            'Warning: Could not delete old avatar: $e',
            name: 'AvatarUploadWidget',
          );
        }
      }

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref(filePath);
      final uploadTask = storageRef.putFile(imageFile);

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final String publicUrl = await storageRef.getDownloadURL();

      developer.log(
        'Profile picture uploaded to Firebase Storage, URL: $publicUrl',
        name: 'AvatarUploadWidget',
      );

      // Update Firebase user record
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .update({'avatarUrl': publicUrl});

      developer.log(
        'Firebase user record updated with new profile picture URL',
        name: 'AvatarUploadWidget',
      );

      // Call the onUpload callback
      await widget.onUpload(publicUrl);

      developer.log(
        'Profile picture update process completed successfully',
        name: 'AvatarUploadWidget',
      );
    } catch (error) {
      developer.log(
        'Error uploading profile picture: $error',
        name: 'AvatarUploadWidget',
        error: error,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      rethrow;
    } finally {
      if (mounted) {
        setState(() => _localLoading = false);
      }
    }
  }

  /// Remove the current avatar
  Future<void> _removeAvatar() async {
    if (widget.currentAvatarUrl.isEmpty) return;

    try {
      setState(() => _localLoading = true);

      // Delete from Firebase Storage
      try {
        // Extract path from Firebase Storage URL
        final Uri uri = Uri.parse(widget.currentAvatarUrl);
        final String path = uri.path.split('/o/')[1].split('?')[0];
        final String decodedPath = Uri.decodeComponent(path);

        if (decodedPath.isNotEmpty) {
          await FirebaseStorage.instance.ref(decodedPath).delete();
          developer.log(
            'Profile picture removed from Firebase Storage',
            name: 'AvatarUploadWidget',
          );
        }
      } catch (e) {
        developer.log(
          'Warning: Could not delete avatar from storage: $e',
          name: 'AvatarUploadWidget',
        );
      }

      // Update user record in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .update({'avatarUrl': ''});

      // Call callback with empty URL
      await widget.onUpload('');
    } catch (error) {
      developer.log(
        'Error removing avatar: $error',
        name: 'AvatarUploadWidget',
        error: error,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove image: ${error.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _localLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = widget.isLoading || _localLoading;
    const avatarSize = 112.0; // Fixed size for consistency

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Stack(
        children: [
          // Avatar container
          GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) {
              _animationController.reverse();
              if (!isLoading) {
                _showImageSourceOptions();
              }
            },
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatarContent(colorScheme, avatarSize, isLoading),
              ),
            ),
          ),

          // Edit button - Make it respond to taps
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) {
                _animationController.reverse();
                if (!isLoading) {
                  _showImageSourceOptions();
                }
              },
              onTapCancel: () => _animationController.reverse(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.pencil,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),

          // Loading overlay
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the content of the avatar (image, preview or placeholder)
  Widget _buildAvatarContent(
      ColorScheme colorScheme, double size, bool isLoading) {
    // Show preview file if available
    if (_previewFile != null) {
      return Image.file(
        _previewFile!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          developer.log(
            'Error loading preview image: $error',
            name: 'AvatarUploadWidget',
            error: error,
          );
          return _buildPlaceholder(colorScheme, size);
        },
      );
    }

    // Show network image if URL is available
    if (widget.currentAvatarUrl.isNotEmpty && !_hasImageLoadError) {
      return Image.network(
        widget.currentAvatarUrl,
        fit: BoxFit.cover,
        width: size,
        height: size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImageLoadingShimmer(size);
        },
        errorBuilder: (context, error, stackTrace) {
          developer.log('Error loading avatar image: $error',
              name: 'AvatarUploadWidget', error: error);
          // Set error flag to avoid repeated network requests
          if (!_hasImageLoadError && mounted) {
            setState(() => _hasImageLoadError = true);
          }
          return _buildPlaceholder(colorScheme, size);
        },
      );
    }

    // Show placeholder
    return _buildPlaceholder(colorScheme, size);
  }

  /// Builds a loading shimmer effect while image loads
  Widget _buildImageLoadingShimmer(double size) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
      ),
    );
  }

  /// Builds the placeholder when no image is available
  Widget _buildPlaceholder(ColorScheme colorScheme, double size) {
    return Container(
      width: size,
      height: size,
      color: colorScheme.primaryContainer,
      child: Center(
        child: widget.user.avatarUrl.isEmpty
            ? Text(
                widget.user.username.toUpperCase()[0],
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              )
            : const Icon(
                LucideIcons.user,
                size: 48,
                color: Colors.white,
              ),
      ),
    );
  }
}
