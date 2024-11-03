import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laya/config/schema/user.dart' as user_model;
import 'package:laya/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostPage extends StatefulWidget {
  final user_model.User user;

  const CreatePostPage({super.key, required this.user});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool _loading = false;
  final _descriptionController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  List<XFile> imageFileList = [];
  List<String> imageUrlList = [];

  Future<void> selectMedia() async {
    try {
      final List<XFile> selectedImages = await imagePicker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        setState(() => imageFileList.addAll(selectedImages));
        _showSnackBar('Media selected successfully.', Colors.green);
      }
    } catch (error) {
      _showSnackBar('Failed to select media.', Colors.red);
    }
  }

  Future<void> _createPost() async {
    setState(() => _loading = true);

    final description = _descriptionController.text.trim();
    final userId = widget.user.id;

    try {
      final response = await supabase
          .from('posts')
          .insert({
            'description': description,
            'media': imageUrlList,
            'user_id': userId,
          })
          .select('id')
          .single();

      final postId = response['id'] as String;

      await _uploadMedia(postId, userId);

      await supabase
          .from('posts')
          .update({'media': imageUrlList}).eq('id', postId);

      if (mounted) {
        _showSnackBar('Post created successfully.', Colors.green);
        context.go('/profile_page', extra: widget.user);
      }
    } catch (error) {
      _showSnackBar('Failed to create post.', Colors.red);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _uploadMedia(String postId, String? userId) async {
    try {
      for (int index = 0; index < imageFileList.length; index++) {
        final imageFile = imageFileList[index];
        final imageExtension = imageFile.path.split('.').last.toLowerCase();
        final imageBytes = await imageFile.readAsBytes();
        final imagePath = '/$userId/$postId/$index.$imageExtension';

        await supabase.storage.from('posts').uploadBinary(
              imagePath,
              imageBytes,
              fileOptions: FileOptions(
                upsert: true,
                contentType: 'image/$imageExtension',
              ),
            );

        final imageUrl = supabase.storage.from('posts').getPublicUrl(imagePath);

        setState(() => imageUrlList.add(imageUrl));
      }

      if (imageUrlList.isNotEmpty) {
        _showSnackBar('Media uploaded successfully.', Colors.green);
      }
    } catch (error) {
      _showSnackBar('Failed to upload media.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : _createPost,
            child: Text(
              'Post',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.025),
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    hintStyle: TextStyle(fontSize: screenHeight * 0.02),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  style: TextStyle(fontSize: screenHeight * 0.02),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: Icon(Icons.image_outlined, size: screenHeight * 0.025),
                  onPressed: selectMedia,
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: imageFileList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final imageFile = imageFileList[index];
                  return Stack(
                    children: [
                      Image.file(
                        File(imageFile.path),
                        fit: BoxFit.contain,
                        height: screenHeight * 0.1,
                        width: screenWidth * 0.5,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => imageFileList.removeAt(index));
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
