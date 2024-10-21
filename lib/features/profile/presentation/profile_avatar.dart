import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laya/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool _isLoading = false;

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: screenHeight * 0.015),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _upload() async {
    try {
      setState(() => _isLoading = true);

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final imageExtension = image.path.split('.').last.toLowerCase();
      final imageBytes = await image.readAsBytes();
      final userId = supabase.auth.currentUser?.id;
      final imagePath = '$userId/profile.$imageExtension';

      await supabase.storage.from('profiles').uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$imageExtension',
            ),
          );

      String imageUrl =
          supabase.storage.from('profiles').getPublicUrl(imagePath);

      imageUrl = Uri.parse(imageUrl).replace(queryParameters: {
        't': DateTime.now().millisecondsSinceEpoch.toString(),
      }).toString();

      widget.onUpload(imageUrl);
    } catch (error) {
      _showErrorSnackBar('Failed to upload image: ${error.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: screenHeight * 0.05,
          backgroundImage: NetworkImage(widget.imageUrl),
        ),
        SizedBox(height: screenHeight * 0.01),
        ElevatedButton(
          onPressed: _isLoading ? null : _upload,
          child: Text(
            'Upload New Profile Photo',
            style: TextStyle(fontSize: screenHeight * 0.015),
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
