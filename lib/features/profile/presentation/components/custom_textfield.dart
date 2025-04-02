import 'package:flutter/material.dart';

Widget textField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  required IconData icon,
  String? errorText,
  String? hintText,
  Widget? suffixIcon,
  int maxLines = 1,
  void Function(String)? onChanged,
  String? Function(String?)? validator,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: colorScheme.outline.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
      style: TextStyle(
        fontSize: 16,
        color: colorScheme.onSurface,
      ),
    ),
  );
}
