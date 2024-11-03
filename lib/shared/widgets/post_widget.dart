import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/config/schema/posts.dart';
import 'package:laya/config/supabase_config.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PostWidget extends StatefulWidget {
  final String avatarUrl;
  final Post post;
  final String username;

  const PostWidget({
    super.key,
    required this.avatarUrl,
    required this.post,
    required this.username,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  IconData bookmarkIcon = Icons.bookmark_border_outlined;
  IconData likeIcon = Icons.favorite_border_outlined;

  int likesCount = 0;
  int commentsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _fetchLikes();
  }

  String getTimeDifference(String createdAt) {
    DateTime createdAtDate = DateTime.parse(createdAt);
    Duration difference = DateTime.now().difference(createdAtDate);

    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  Future<void> _fetchComments() async {
    try {
      final data = await supabase
          .from('comments')
          .select()
          .eq('post_id', widget.post.id)
          .count();

      setState(() => commentsCount = data.count);
    } catch (error) {
      _showErrorSnackBar(error);
    }
  }

  Future<void> _fetchLikes() async {
    try {
      final data = await supabase
          .from('likes')
          .select()
          .eq('post_id', widget.post.id)
          .count();

      setState(() => likesCount = data.count);

      if (likesCount > 0) {
        supabase
            .from('likes')
            .select()
            .eq('post_id', widget.post.id)
            .eq('user_id', supabase.auth.currentUser!.id)
            .then((value) {
          if (value.isNotEmpty) {
            setState(() => likeIcon = Icons.favorite_outlined);
          }
        });
      }
    } catch (error) {
      _showErrorSnackBar(error);
    }
  }

  void _showErrorSnackBar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void onClickLikeIcon() async {
    try {
      if (likeIcon == Icons.favorite_border_outlined) {
        await supabase.from('likes').insert({
          'post_id': widget.post.id,
          'user_id': supabase.auth.currentUser!.id,
        });
        setState(() => likesCount++);
      } else {
        await supabase
            .from('likes')
            .delete()
            .eq('post_id', widget.post.id)
            .eq('user_id', supabase.auth.currentUser!.id);
        setState(() => likesCount--);
      }

      setState(() => likeIcon = likeIcon == Icons.favorite_border_outlined
          ? Icons.favorite_outlined
          : Icons.favorite_border_outlined);
    } catch (error) {
      _showErrorSnackBar(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.01,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/profile/${widget.post.userId}'),
                child: CircleAvatar(
                  radius: screenHeight * 0.02,
                  backgroundImage: NetworkImage(widget.avatarUrl),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                widget.username,
                style: TextStyle(fontSize: screenHeight * 0.015),
              ),
              Text(
                " | ",
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                getTimeDifference(widget.post.createdAt.toIso8601String()),
                style: TextStyle(
                  fontSize: screenHeight * 0.015,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {},
                child: Icon(
                  LucideIcons.moreVertical,
                  size: screenHeight * 0.017,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            widget.post.description,
            style: TextStyle(fontSize: screenHeight * 0.015),
          ),
          if (widget.post.media.isNotEmpty)
            SizedBox(height: screenHeight * 0.01),
          if (widget.post.media.isNotEmpty)
            ...widget.post.media.map(
              (imageURL) => Image.network(
                imageURL,
                fit: BoxFit.cover,
                height: screenHeight * 0.3,
                width: screenWidth,
              ),
            ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: Icon(
                  likeIcon,
                  color: Theme.of(context).colorScheme.primary,
                  size: screenHeight * 0.02,
                ),
                label: Text(
                  "$likesCount",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: screenHeight * 0.015,
                  ),
                ),
                onPressed: onClickLikeIcon,
              ),
              TextButton.icon(
                icon: Icon(
                  LucideIcons.messageCircle,
                  size: screenHeight * 0.02,
                ),
                label: Text(
                  "$commentsCount",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: screenHeight * 0.015,
                  ),
                ),
                onPressed: () => context.go('/post/${widget.post.id}'),
              ),
              TextButton(
                onPressed: () {},
                child: Icon(LucideIcons.share2, size: screenHeight * 0.02),
              ),
              TextButton(
                onPressed: () {},
                child: Icon(
                  bookmarkIcon,
                  size: screenHeight * 0.02,
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
