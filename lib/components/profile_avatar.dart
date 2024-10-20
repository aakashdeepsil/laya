import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class ProfileAvatar extends StatefulWidget {
  final String imageUrl;
  final void Function(String) onUpload;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.onUpload,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  // Variable to store the loading state
  bool _isLoading = false;

  // Get the screen width and height
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  // Function to show error snackbar
  void _showErrorSnackBar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString(),
          style: TextStyle(fontSize: screenHeight * 0.015),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  // Function to upload the user's profile photo
  Future<void> _upload() async {
    try {
      setState(() => _isLoading = true);

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      final imageExtension = image.path.split('.').last.toLowerCase();
      final imageBytes = await image.readAsBytes();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final imagePath = '/$userId/profile';

      await Supabase.instance.client.storage.from('profiles').uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$imageExtension',
            ),
          );

      String imageUrl = Supabase.instance.client.storage
          .from('profiles')
          .getPublicUrl(imagePath);

      imageUrl = Uri.parse(imageUrl).replace(queryParameters: {
        't': DateTime.now().millisecondsSinceEpoch.toString(),
      }).toString();

      widget.onUpload(imageUrl);
    } on PostgrestException catch (error) {
      _showErrorSnackBar(error.message);
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              CircleAvatar(
                radius: screenHeight * 0.05,
                backgroundImage: NetworkImage(widget.imageUrl),
              ),
              SizedBox(height: screenHeight * 0.01),
              ElevatedButton(
                onPressed: _upload,
                child: Text(
                  'Upload New Profile Photo',
                  style: TextStyle(fontSize: screenHeight * 0.015),
                ),
              ),
            ],
          );
  }
}
