import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeleteAlertDialog extends StatefulWidget {
  final bool isDeleting;
  final void Function()? deleteContent;
  final void Function()? deleteSeries;

  const DeleteAlertDialog({
    super.key,
    required this.isDeleting,
    required this.deleteContent,
    required this.deleteSeries,
  });

  @override
  State<DeleteAlertDialog> createState() => _DeleteAlertDialogState();
}

class _DeleteAlertDialogState extends State<DeleteAlertDialog> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Delete Series',
        style: TextStyle(
          fontSize: screenHeight * 0.025,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: widget.isDeleting
          ? Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.1,
                  height: screenHeight * 0.05,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Deleting series...',
                  style: TextStyle(fontSize: screenHeight * 0.02),
                ),
              ],
            )
          : Text(
              'Are you sure you want to delete this series? This action cannot be undone.',
              style: TextStyle(fontSize: screenHeight * 0.02),
            ),
      actions: widget.isDeleting
          ? null
          : [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: screenHeight * 0.02),
                ),
              ),
              TextButton(
                onPressed: widget.deleteSeries,
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: screenHeight * 0.02,
                  ),
                ),
              ),
            ],
    );
  }
}
