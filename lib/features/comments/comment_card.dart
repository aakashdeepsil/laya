// import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart';
// import 'package:supabase_auth_ui/supabase_auth_ui.dart';

// class CommentCard extends StatefulWidget {
//   final Map<String, dynamic> commentDetails;

//   const CommentCard({super.key, required this.commentDetails});

//   @override
//   State<CommentCard> createState() => _CommentCardState();
// }

// class _CommentCardState extends State<CommentCard> {
//   double get screenHeight => MediaQuery.of(context).size.height;
//   double get screenWidth => MediaQuery.of(context).size.width;

//   bool _isFetchingProfile = false;

//   List<Map<String, dynamic>> _commentLikes = [];
//   List<Map<String, dynamic>> _commentDislikes = [];
//   List<Map<String, dynamic>> _commentReplies = [];

//   Map<String, dynamic> profile = {};

//   Future<void> _fetchProfile() async {
//     // Fetch the user profile from the database
//     setState(() => _isFetchingProfile = true);

//     try {
//       final data = await Supabase.instance.client
//           .from('profiles')
//           .select()
//           .eq('id', widget.commentDetails['user_id'])
//           .single();

//       // Set the profile data to the profile variable
//       setState(() => profile = data);
//     } on PostgrestException catch (error) {
//       // Handle the error
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(error.message),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     } catch (error) {
//       // Handle the error
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Unexpected error occurred. Try again.'),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     } finally {
//       // Set the isFetchingProfile to false
//       setState(() => _isFetchingProfile = false);
//     }
//   }

//   Future<void> _fetchCommentLikes() async {
//     // Fetch the likes for the comment
//     try {
//       var data = await Supabase.instance.client
//           .from('comment_likes')
//           .select()
//           .eq('comment_id', widget.commentDetails['id'])
//           .eq('is_like', true);

//       setState(() => _commentLikes = data);

//       // Fetch the dislikes for the comment
//       data = await Supabase.instance.client
//           .from('comment_likes')
//           .select()
//           .eq('comment_id', widget.commentDetails['id'])
//           .eq('is_like', false);

//       setState(() => _commentDislikes = data);
//     } on PostgrestException catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(error.message),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     } catch (error) {
//       print(error);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text(
//               'Unexpected error occurred fetching comment likes. Try again.',
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _fetchCommentReplies() async {
//     // Fetch the replies for the comment
//     try {
//       final data = await Supabase.instance.client
//           .from('comment_replies')
//           .select()
//           .eq('comment_id', widget.commentDetails['id']);

//       setState(() => _commentReplies = data);
//     } on PostgrestException catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(error.message),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     } catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Unexpected error occurred. Try again.'),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   // Get the time difference between the post creation time and now
//   String getTimeDifference(String createdAt) {
//     DateTime createdAtDate = DateTime.parse(createdAt);
//     DateTime now = DateTime.now();
//     Duration difference = now.difference(createdAtDate);

//     if (difference.inDays > 0) {
//       return '${difference.inDays}d ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'Just now';
//     }
//   }

//   void onClickMoreButton() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Icon(
//                 Icons.person_add_alt_1_outlined,
//               ),
//               title: Text('Follow User'),
//             ),
//             ListTile(
//               leading: Icon(LucideIcons.copy),
//               title: Text('Copy link'),
//             ),
//             ListTile(
//               leading: Icon(Icons.block),
//               title: Text('Block User'),
//             ),
//             ListTile(
//               leading: Icon(LucideIcons.flag),
//               title: Text('Report Comment'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchProfile();
//     _fetchCommentLikes();
//     _fetchCommentReplies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _isFetchingProfile
//         ? const Center(child: CircularProgressIndicator())
//         : Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: screenWidth * 0.02,
//               vertical: screenHeight * 0.01,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: screenHeight * 0.01,
//                       backgroundImage: NetworkImage(profile['avatar_url']),
//                     ),
//                     SizedBox(width: screenWidth * 0.02),
//                     InkWell(
//                       onTap: () => {},
//                       child: Text(
//                         profile['username'],
//                         style: TextStyle(fontSize: screenHeight * 0.015),
//                       ),
//                     ),
//                     Text(
//                       " | ",
//                       style: TextStyle(
//                         fontSize: screenHeight * 0.02,
//                         fontWeight: FontWeight.w300,
//                       ),
//                     ),
//                     Text(
//                       getTimeDifference(widget.commentDetails['created_at']),
//                       style: TextStyle(
//                         fontSize: screenHeight * 0.015,
//                         fontWeight: FontWeight.w300,
//                       ),
//                     ),
//                     const Spacer(),
//                     InkWell(
//                       onTap: onClickMoreButton,
//                       child: Icon(
//                         LucideIcons.moreVertical,
//                         size: screenHeight * 0.017,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: screenHeight * 0.01),
//                 Text(
//                   widget.commentDetails['comment_text'],
//                   style: TextStyle(fontSize: screenHeight * 0.015),
//                 ),
//                 SizedBox(height: screenHeight * 0.01),
//                 Row(
//                   children: [
//                     OutlinedButton(
//                       onPressed: () {},
//                       style: OutlinedButton.styleFrom(
//                         minimumSize: Size(
//                           screenWidth * 0.1,
//                           screenHeight * 0.03,
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: screenWidth * 0.03,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.thumb_up_alt_outlined,
//                             size: screenHeight * 0.02,
//                           ),
//                           SizedBox(width: screenWidth * 0.01),
//                           Text(
//                             _commentLikes.length.toString(),
//                             style: TextStyle(fontSize: screenHeight * 0.015),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: screenWidth * 0.02),
//                     OutlinedButton(
//                       onPressed: () {},
//                       style: OutlinedButton.styleFrom(
//                         minimumSize: Size(
//                           screenWidth * 0.1,
//                           screenHeight * 0.03,
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: screenWidth * 0.03,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.thumb_down_off_alt_rounded,
//                             size: screenHeight * 0.02,
//                           ),
//                           SizedBox(width: screenWidth * 0.01),
//                           Text(
//                             _commentDislikes.length.toString(),
//                             style: TextStyle(fontSize: screenHeight * 0.015),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: screenWidth * 0.02),
//                     OutlinedButton(
//                       onPressed: () {},
//                       style: OutlinedButton.styleFrom(
//                         minimumSize: Size(
//                           screenWidth * 0.2,
//                           screenHeight * 0.03,
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: screenWidth * 0.03,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(LucideIcons.reply, size: screenHeight * 0.02),
//                           SizedBox(width: screenWidth * 0.01),
//                           Text(
//                             'Reply',
//                             style: TextStyle(fontSize: screenHeight * 0.015),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//   }
// }
