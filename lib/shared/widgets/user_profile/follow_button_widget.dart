import 'package:flutter/material.dart';
import 'package:laya/features/profile/data/user_repository.dart';

class FollowButton extends StatefulWidget {
  final String userId;
  final VoidCallback? onFollowStatusChanged;

  const FollowButton({
    super.key,
    required this.userId,
    this.onFollowStatusChanged,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final UserRepository _userRepository = UserRepository();

  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    try {
      final isFollowing = await _userRepository.isFollowing(widget.userId);
      setState(() => _isFollowing = isFollowing);
    } catch (e) {
      debugPrint('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => _isLoading = true);

    try {
      if (_isFollowing) {
        await _userRepository.unfollowUser(widget.userId);
      } else {
        await _userRepository.followUser(widget.userId);
      }

      setState(() => _isFollowing = !_isFollowing);
      widget.onFollowStatusChanged?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              e.toString(),
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _isLoading ? null : _toggleFollow,
      style: OutlinedButton.styleFrom(
        backgroundColor: _isFollowing
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.primary,
        foregroundColor: _isFollowing
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onPrimary,
        side: _isFollowing
            ? BorderSide(color: Theme.of(context).colorScheme.onSurface)
            : null,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenHeight * 0.01),
        ),
      ),
      child: _isLoading
          ? SizedBox(
              width: screenWidth * 0.04,
              height: screenHeight * 0.02,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isFollowing
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
          : Text(
              _isFollowing ? 'Following' : 'Follow',
              style: TextStyle(fontSize: screenHeight * 0.0175),
            ),
    );
  }
}
