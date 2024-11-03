import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/content.dart';
import 'package:laya/config/schema/user.dart';
import 'package:video_player/video_player.dart';

class ViewVideoContentPage extends StatefulWidget {
  final Content content;
  final User user;

  const ViewVideoContentPage({
    super.key,
    required this.content,
    required this.user,
  });

  @override
  State<ViewVideoContentPage> createState() => _ViewVideoContentPageState();
}

class _ViewVideoContentPageState extends State<ViewVideoContentPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
    );

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _controller.play();
          _controller.setPlaybackSpeed(1.0);
          _controller.setVolume(1.0);
          _createChewieController();
        });
      }
    }).catchError((error) {
      // Handle initialization error
      _showErrorDialog('Failed to initialize video player');
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Title')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _isInitialized
                  ? SizedBox(
                      height: screenHeight * 0.26,
                      width: double.infinity,
                      child: Chewie(controller: _chewieController!),
                    )
                  : const Center(child: CircularProgressIndicator()),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Video Description'),
                    SizedBox(height: 8),
                    Text(
                      'This is a video description. It can be long or short. '
                      'It can contain any information about the video.',
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10, // Replace with your actual item count
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.video_collection),
                    title: Text('Video $index'),
                    subtitle: Text('Description for video $index'),
                    onTap: () {
                      // Handle tap event
                    },
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
