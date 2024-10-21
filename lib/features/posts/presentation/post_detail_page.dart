// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:laya/comments/comment_card.dart';
// import 'package:laya/components/post.dart';
// import 'package:laya/constants.dart';
// import 'package:supabase_auth_ui/supabase_auth_ui.dart';

// class PostDetail extends StatefulWidget {
//   final String avatarURL;
//   final String postID;
//   final Map<String, dynamic> post;
//   final String username;

//   const PostDetail({
//     super.key,
//     required this.postID,
//     required this.avatarURL,
//     required this.post,
//     required this.username,
//   });

//   @override
//   State<PostDetail> createState() => _PostDetailState();
// }

// class _PostDetailState extends State<PostDetail> {
//   // Get the screen width and height
//   double get screenHeight => MediaQuery.of(context).size.height;
//   double get screenWidth => MediaQuery.of(context).size.width;

//   // Comments data
//   List<Map<String, dynamic>> _comments = [];

//   // Show error snackbar
//   void _showErrorSnackBar(dynamic error) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(error.toString()),
//         backgroundColor: Theme.of(context).colorScheme.error,
//       ),
//     );
//   }

//   // Fetch comments
//   Future<void> _fetchComments() async {
//     try {
//       final data = await Supabase.instance.client
//           .from('comments')
//           .select()
//           .eq('post_id', widget.post['id']);

//       setState(() => _comments = data);
//     } on PostgrestException catch (error) {
//       _showErrorSnackBar(error);
//     } catch (error) {
//       _showErrorSnackBar(error);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchComments();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: customAppBar(screenHeight, 'LAYA', backButton: true),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Post(
//                 avatarUrl: widget.avatarURL,
//                 postItem: widget.post,
//                 username: widget.username,
//               ),
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _comments.length,
//                 itemBuilder: (context, index) {
//                   final commentDetails = _comments[index];
//                   return CommentCard(commentDetails: commentDetails);
//                 },
//               )
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: InkWell(
//         onTap: () =>
//             context.push('/post_details/${widget.post['post_id']}/add_comment'),
//         child: Container(
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: Theme.of(context).primaryColor,
//               width: screenWidth * 0.003,
//             ),
//             borderRadius: BorderRadius.circular(screenWidth * 0.03),
//           ),
//           height: screenHeight * 0.06,
//           padding: EdgeInsets.only(
//             left: screenWidth * 0.05,
//             right: screenWidth * 0.05,
//             top: screenHeight * 0.01,
//             bottom: screenHeight * 0.02,
//           ),
//           child: Center(
//               child: Text(
//             'Add a comment',
//             style: TextStyle(
//               color: Theme.of(context).primaryColor,
//               fontSize: screenWidth * 0.04,
//             ),
//           )),
//         ),
//       ),
//     );
//   }
// }
