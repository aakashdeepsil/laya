import 'package:flutter/material.dart';

class MediaButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;
  final String? selectedFileName;

  const MediaButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
    this.selectedFileName,
  });

  @override
  State<MediaButton> createState() => _MediaButtonState();
}

class _MediaButtonState extends State<MediaButton> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.018,
                  horizontal: screenHeight * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.isLoading
                        ? SizedBox(
                            width: screenWidth * 0.025,
                            height: screenHeight * 0.025,
                            child: CircularProgressIndicator(
                              strokeWidth: screenHeight * 0.0025,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          )
                        : Icon(
                            widget.icon,
                            color: colorScheme.primary.withOpacity(0.8),
                            size: screenHeight * 0.025,
                          ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      widget.isLoading ? 'Uploading...' : widget.label,
                      style: TextStyle(
                        color: colorScheme.primary.withOpacity(0.8),
                        fontSize: screenHeight * 0.016,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.selectedFileName != null)
          Padding(
            padding: EdgeInsets.only(
              left: screenHeight * 0.02,
              top: screenHeight * 0.01,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: screenHeight * 0.02,
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    widget.selectedFileName!,
                    style: TextStyle(
                      color: colorScheme.primary.withOpacity(0.8),
                      fontSize: screenHeight * 0.016,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}