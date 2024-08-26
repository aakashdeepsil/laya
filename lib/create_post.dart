import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool _loading = false;
  String postId = '';
  final _descriptionController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  List<XFile> imageFileList = [];
  List<String> imageUrlList = [];

  Future<void> selectMedia() async {
    try {
      final List<XFile> selectedImages = await imagePicker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        setState(() {
          imageFileList.addAll(selectedImages);
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Media selected successfully.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to select media.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _createPost() async {
    setState(() {
      _loading = true;
    });

    final description = _descriptionController.text.trim();

    try {
      final response = await Supabase.instance.client
          .from('posts')
          .insert(
            {
              'comments': {},
              'description': description,
              'email': Supabase.instance.client.auth.currentUser?.email,
              'likes': {},
              'media': imageUrlList,
            },
          )
          .select('post_id')
          .single();

      postId = response['post_id'].toString();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Post created successfully.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to create post.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    try {
      for (int index = 0; index < imageFileList.length; index++) {
        final imageFile = imageFileList[index];
        final imageExtension = imageFile.path.split('.').last.toLowerCase();
        final imageBytes = await imageFile.readAsBytes();
        final userId = Supabase.instance.client.auth.currentUser?.id;
        final imagePath = '/$userId/$postId/$index';

        await Supabase.instance.client.storage.from('posts').uploadBinary(
              imagePath,
              imageBytes,
              fileOptions: FileOptions(
                upsert: true,
                contentType: 'image/$imageExtension',
              ),
            );

        final imageUrl = Supabase.instance.client.storage
            .from('posts')
            .getPublicUrl(imagePath);

        setState(() {
          imageUrlList.add(imageUrl);
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Media uploaded successfully.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to upload media.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    print(imageUrlList);

    final updates = {'media': imageUrlList};

    try {
      await Supabase.instance.client
          .from('posts')
          .update(updates)
          .eq('post_id', int.parse(postId));
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unexpected error occurred'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        GoRouter.of(context).go('/profile');
      }
    }
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
            onPressed: _createPost,
            child: Text(
              'Post',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
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
                        icon: Icon(
                          Icons.image_outlined,
                          size: screenHeight * 0.025,
                        ),
                        onPressed: selectMedia,
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: imageFileList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    imageFileList.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
