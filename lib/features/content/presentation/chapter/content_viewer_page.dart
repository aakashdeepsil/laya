import 'package:flutter/material.dart';
import 'package:laya/config/schema/content.dart';
import 'package:laya/config/schema/user.dart';
import 'package:laya/enums/media_type.dart';
import 'package:laya/features/content/presentation/chapter/view_document_content_page.dart';
import 'package:laya/features/content/presentation/chapter/view_video_content_page.dart';

class ContentViewerPage extends StatefulWidget {
  final Content content;
  final User user;

  const ContentViewerPage({
    super.key,
    required this.content,
    required this.user,
  });

  @override
  State<ContentViewerPage> createState() => _ContentViewerPageState();
}

class _ContentViewerPageState extends State<ContentViewerPage> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildContentView());
  }

  Widget _buildContentView() {
    switch (widget.content.mediaType) {
      case MediaType.document:
        return ViewDocumentContentPage(
          content: widget.content,
          user: widget.user,
        );
      case MediaType.video:
        return ViewVideoContentPage(
          content: widget.content,
          user: widget.user,
        );
      default:
        return Center(
          child: Text(
            'Unsupported content type',
            style: TextStyle(fontSize: screenHeight * 0.02),
          ),
        );
    }
  }
}
