import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AddCommentPage extends StatefulWidget {
  final String postId;

  const AddCommentPage({super.key, required this.postId});

  @override
  State<AddCommentPage> createState() => _AddCommentPageState();
}

class _AddCommentPageState extends State<AddCommentPage> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isAddingComment = false;

  Future<void> addComment() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() => _isAddingComment = true);

        await Supabase.instance.client.from('comments').insert([
          {
            'post_id': int.parse(widget.postId),
            'user_id': Supabase.instance.client.auth.currentUser?.id,
            'comment_text': _commentController.text,
          }
        ]);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Comment added successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          context.pop();
        }
      } on PostgrestException catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.message,
                style: TextStyle(fontSize: screenHeight * 0.02),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (error) {
        print(widget.postId);
        print(error.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to add comment'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        setState(() => _isAddingComment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Comment',
          style: TextStyle(fontSize: screenHeight * 0.025),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.check, size: screenHeight * 0.03),
            onPressed: addComment,
          ),
        ],
      ),
      body: _isAddingComment
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.01,
                        ),
                        child: TextFormField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Write your comment here',
                            border: OutlineInputBorder(),
                          ),
                          minLines: 1,
                          maxLines: null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a comment!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
