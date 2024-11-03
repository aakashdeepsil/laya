import 'package:flutter/material.dart';

class DropdownField extends StatefulWidget {
  final String hint;
  final String label;
  final List<String> options;
  final Function(String?) onChanged;

  const DropdownField({
    super.key,
    required this.hint,
    required this.label,
    required this.options,
    required this.onChanged,
  });

  @override
  State<DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: screenHeight * 0.0175,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(screenHeight * 0.02),
          ),
          child: DropdownButtonFormField<String>(
            items: widget.options
                .map((option) => DropdownMenuItem(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: screenHeight * 0.0175,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                fontSize: screenHeight * 0.0175,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screenHeight * 0.02),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenHeight * 0.02,
                vertical: screenHeight * 0.01,
              ),
            ),
            dropdownColor: Theme.of(context).colorScheme.surface,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
            ),
            isExpanded: true,
            alignment: AlignmentDirectional.centerStart,
          ),
        ),
      ],
    );
  }
}
