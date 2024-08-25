import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Post extends StatefulWidget {
  final Map<String, dynamic> postItem;
  const Post({super.key, required this.postItem});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  IconData bookmarkIcon = Icons.bookmark_border_outlined;
  IconData likeIcon = Icons.favorite_border_outlined;

  List<dynamic> imgList = [];

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

  @override
  void initState() {
    super.initState();
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
                onTap: () {},
                child: CircleAvatar(
                  radius: screenHeight * 0.02,
                  backgroundImage: const NetworkImage(
                    'https://picsum.photos/250?image=1',
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              InkWell(
                onTap: () => {},
                child: const Text(
                  "@username ",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              const Text(
                " | ",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                getTimeDifference(widget.postItem['created_at']),
                style: TextStyle(
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
          SizedBox(height: screenHeight * 0.01),
          ExpandableCarousel(
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
          ),
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
                    const Text("100 "),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => context.go(
                  '/socials/post/${widget.postItem['post_id']}',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.2, screenHeight * 0.03),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.messageCircle,
                      size: screenHeight * 0.02,
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    const Text("100 Comments"),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.1, screenHeight * 0.03),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                ),
                child: Icon(
                  LucideIcons.share2,
                  size: screenHeight * 0.02,
                ),
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

  void onClickLikeIcon() {
    setState(() {
      likeIcon = likeIcon == Icons.favorite_border_outlined
          ? Icons.favorite_outlined
          : Icons.favorite_border_outlined;
    });
  }

  void onClickBookmarkButton() {
    setState(() {
      bookmarkIcon = bookmarkIcon == Icons.bookmark_border_outlined
          ? Icons.bookmark_outlined
          : Icons.bookmark_border_outlined;
    });
  }

  void onClickMoreButton() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.person_add_alt_1_outlined,
              ),
              title: Text('Follow User'),
            ),
            ListTile(
              leading: Icon(LucideIcons.copy),
              title: Text('Copy link'),
            ),
            ListTile(
              leading: Icon(Icons.block),
              title: Text('Block User'),
            ),
            ListTile(
              leading: Icon(LucideIcons.flag),
              title: Text('Report Post'),
            ),
          ],
        );
      },
    );
  }
}
