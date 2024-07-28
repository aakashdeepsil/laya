import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.onUpload,
  });

  final String? imageUrl;
  final void Function(String) onUpload;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _isLoading = false;

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.imageUrl == null || widget.imageUrl!.isEmpty)
          CircleAvatar(
            radius: screenHeight * 0.05,
            child: Icon(
              LucideIcons.user,
              size: screenHeight * 0.075,
            ),
          )
        else
          CircleAvatar(
            radius: screenHeight * 0.05,
            backgroundImage: NetworkImage(widget.imageUrl!),
          ),
        SizedBox(height: screenHeight * 0.01),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _upload,
                child: const Text('Upload New Profile Photo'),
              ),
      ],
    );
  }

  Future<void> _upload() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
      't': DateTime.now().millisecondsSinceEpoch.toString()
    }).toString();
    widget.onUpload(imageUrl);

    setState(() {
      _isLoading = false;
    });
  }
}
