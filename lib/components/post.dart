import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:laya/constants.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class Post extends StatefulWidget {
  final String avatarUrl;
  final Map<String, dynamic> postItem;
  final String username;

  const Post({
    super.key,
    required this.avatarUrl,
    required this.postItem,
    required this.username,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  // Get the current screen width and height
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  // Set the initial bookmark icon to bookmark_border_outlined
  IconData bookmarkIcon = Icons.bookmark_border_outlined;
  IconData likeIcon = Icons.favorite_border_outlined;

  // Initialize an empty list to store images
  List<dynamic> imgList = [];

  // Store the number of likes and comments
  int likesCount = 0;
  int commentsCount = 0;

  // Get the time difference between the post creation time and now
  String getTimeDifference(String createdAt) {
    DateTime createdAtDate = DateTime.parse(createdAt);
    DateTime now = DateTime.now();
    Duration difference = now.difference(createdAtDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Handle the like button click event
  void onClickLikeIcon() async {
    try {
      if (likeIcon == Icons.favorite_border_outlined) {
        // Add the like to the post
        await Supabase.instance.client.from('likes').insert({
          'post_id': widget.postItem['id'],
          'user_id': Supabase.instance.client.auth.currentUser!.id,
        });

        setState(() => likesCount++);
      } else {
        // Remove the like from the post
        await Supabase.instance.client
            .from('likes')
            .delete()
            .eq('post_id', widget.postItem['id'])
            .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

        setState(() => likesCount--);
      }

      setState(() {
        likeIcon = likeIcon == Icons.favorite_border_outlined
            ? Icons.favorite_outlined
            : Icons.favorite_border_outlined;
      });
    } on PostgrestException catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error.message, screenHeight);
      }
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error.toString(), screenHeight);
      }
    }
  }

  // Handle the bookmark button click event
  void onClickBookmarkButton() async {
    try {
      if (bookmarkIcon == Icons.bookmark_outlined) {
      } else {}

      setState(() {
        bookmarkIcon = bookmarkIcon == Icons.bookmark_border_outlined
            ? Icons.bookmark_outlined
            : Icons.bookmark_border_outlined;
      });
    } on PostgrestException catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error.message, screenHeight);
      }
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error.toString(), screenHeight);
      }
    }
  }

  // Handle the more button click event
  void onClickMoreButton() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.person_add_alt_1_outlined,
                size: screenHeight * 0.03,
              ),
              title: Text(
                'Follow User',
                style: TextStyle(fontSize: screenHeight * 0.017),
              ),
            ),
            ListTile(
              leading: Icon(
                LucideIcons.copy,
                size: screenHeight * 0.03,
              ),
              title: Text(
                'Copy link',
                style: TextStyle(fontSize: screenHeight * 0.017),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.block,
                size: screenHeight * 0.03,
              ),
              title: Text(
                'Block User',
                style: TextStyle(fontSize: screenHeight * 0.017),
              ),
            ),
            ListTile(
              leading: Icon(
                LucideIcons.flag,
                size: screenHeight * 0.03,
              ),
              title: Text(
                'Report Post',
                style: TextStyle(fontSize: screenHeight * 0.017),
              ),
            ),
          ],
        );
      },
    );
  }

  // Fetch comments
  Future<void> _fetchComments() async {
    try {
      final data = await Supabase.instance.client
          .from('comments')
          .select()
          .eq('post_id', widget.postItem['id'])
          .count();

      setState(() => commentsCount = data.count);
    } on PostgrestException catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error.message, screenHeight);
      }
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error.toString(), screenHeight);
      }
    }
  }

  // Fetch likes
  Future<void> _fetchLikes() async {
    try {
      final data = await Supabase.instance.client
          .from('likes')
          .select()
          .eq('post_id', widget.postItem['id'])
          .count();

      setState(() => likesCount = data.count);

      if (likesCount > 0) {
        Supabase.instance.client
            .from('likes')
            .select()
            .eq('post_id', widget.postItem['id'])
            .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
            .then((value) {
          if (value.isNotEmpty) {
            setState(() => likeIcon = Icons.favorite_outlined);
          }
        });
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error.message, screenHeight);
      }
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(context, error.toString(), screenHeight);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _fetchLikes();

    // Get the list of images from the post
    imgList = widget.postItem['media'];
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
                onTap: () =>
                    context.go('/profile/${widget.postItem['user_id']}'),
                child: CircleAvatar(
                  radius: screenHeight * 0.02,
                  backgroundImage: NetworkImage(widget.avatarUrl),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              InkWell(
                onTap: () => {},
                child: Text(
                  widget.username,
                  style: TextStyle(fontSize: screenHeight * 0.015),
                ),
              ),
              Text(
                " | ",
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                getTimeDifference(widget.postItem['created_at']),
                style: TextStyle(
                  fontSize: screenHeight * 0.015,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onClickMoreButton,
                child: Icon(
                  LucideIcons.moreVertical,
                  size: screenHeight * 0.017,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            widget.postItem['description'],
            style: TextStyle(
              fontSize: screenHeight * 0.015,
            ),
            textAlign: TextAlign.left,
          ),
          imgList.isNotEmpty
              ? SizedBox(height: screenHeight * 0.01)
              : Container(),
          imgList.isNotEmpty
              ? ExpandableCarousel(
                  items: imgList
                      .map((imageURL) => Image.network(
                            imageURL,
                            fit: BoxFit.cover,
                            height: screenHeight * 0.3,
                            width: screenWidth,
                          ))
                      .toList(),
                  options: ExpandableCarouselOptions(
                    aspectRatio: 16 / 9,
                    autoPlay: false,
                    slideIndicator: const CircularSlideIndicator(),
                    viewportFraction: 1,
                  ),
                )
              : Container(),
          SizedBox(height: screenHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: onClickLikeIcon,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.1, screenHeight * 0.03),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                ),
                child: Row(
                  children: [
                    Icon(
                      likeIcon,
                      color: Theme.of(context).colorScheme.primary,
                      size: screenHeight * 0.02,
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      "$likesCount",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: screenHeight * 0.015,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () =>
                    context.go('/post/${widget.postItem['post_id']}'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.1, screenHeight * 0.03),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.messageCircle, size: screenHeight * 0.02),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      "$commentsCount",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: screenHeight * 0.015,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.1, screenHeight * 0.03),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                ),
                child: Icon(LucideIcons.share2, size: screenHeight * 0.02),
              ),
              OutlinedButton(
                onPressed: onClickBookmarkButton,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.1, screenHeight * 0.03),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                ),
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
