import 'package:flutter/material.dart';

class EditableDropdown extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;
  final Function(String) onChanged;
  final bool isLoading;
  final TextEditingController controller;

  const EditableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.controller,
    this.isLoading = false,
  });

  @override
  State<EditableDropdown> createState() => _EditableDropdownState();
}

class _EditableDropdownState extends State<EditableDropdown> {
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  bool _isExpanded = false;
  List<String> _filteredItems = [];
  String categoryName = '';

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    widget.controller.addListener(_filterItems);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _filterItems() {
    if (!mounted) return;

    final query = widget.controller.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoading
        ? SizedBox(
            width: screenWidth * 0.1,
            height: screenHeight * 0.05,
            child: const Center(child: CircularProgressIndicator()),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: screenHeight * 0.018,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: widget.controller,
                      enabled: !widget.isLoading,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isExpanded
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                          ),
                          onPressed: () {
                            setState(() => _isExpanded = !_isExpanded);
                          },
                        ),
                      ),
                      onTap: () => setState(() => _isExpanded = true),
                      onChanged: widget.onChanged,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please select or type in the series';
                        }
                        return null;
                      },
                    ),
                    if (_isExpanded && _filteredItems.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.2,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return ListTile(
                              dense: true,
                              title: Text(
                                item,
                                style:
                                    TextStyle(fontSize: screenHeight * 0.018),
                              ),
                              onTap: () {
                                widget.controller.text = item;
                                widget.onChanged(item);
                                setState(() => _isExpanded = false);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
  }
}
