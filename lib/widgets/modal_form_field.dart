import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/gap.dart';

class ModalFormField extends StatefulWidget {
  const ModalFormField({
    super.key,
    required this.title,
    required this.options,
    required this.controller,
    this.onOptionSelected,
    this.textColor = AppColors.darkgrey,
    this.modalHeightFactor = 0.6, // New property for modal height flexibility
    this.enableSearch = false, // NEW: Added enableSearch, defaults to false
  });

  final String title;
  final List<String> options;
  final TextEditingController controller;
  final Color textColor;
  final Function(String)? onOptionSelected;
  final double modalHeightFactor;
  final bool enableSearch; // NEW: Flag to enable/disable search

  @override
  State<ModalFormField> createState() => _ModalFormFieldState();
}

class _ModalFormFieldState extends State<ModalFormField> {
  // Controller for the search input field within the modal
  late TextEditingController _searchController;
  // List to hold filtered options based on search query
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredOptions = widget.options; // Initialize with all options
  }

  @override
  void didUpdateWidget(covariant ModalFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If options change from parent, re-initialize filtered options
    if (widget.options != oldWidget.options) {
      // Only filter if search is enabled, otherwise just update the options list
      if (widget.enableSearch) {
        _filterOptions(_searchController.text); // Apply current search query to new options
      } else {
        _filteredOptions = widget.options;
      }
    }
  }

  // Method to filter options based on search text
  void _filterOptions(String query) {
    // This method is only relevant if search is enabled
    if (!widget.enableSearch) {
      return; // Do nothing if search is not enabled
    }
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = widget.options;
      } else {
        _filteredOptions = widget.options
            .where((option) =>
                option.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showOptionsModal() {
    // Reset search controller and filtered options every time modal is opened
    _searchController.clear();
    _filterOptions(''); // Reset filter to show all options initially (even if search is disabled, this ensures _filteredOptions is correct)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows modal to take full height if needed
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder to manage state within the modal
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              height: MediaQuery.of(context).size.height * widget.modalHeightFactor, // Dynamic height
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap.h8,
                  // NEW: Conditionally render the Search TextField
                  if (widget.enableSearch)
                    Column(
                      children: [
                        TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: AppColors.lightgrey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: AppColors.lightgrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: AppColors.darkgrey), // Use your primary color
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                          ),
                          onChanged: (value) {
                            modalSetState(() { // Update state of the modal itself
                              _filterOptions(value);
                            });
                          },
                        ),
                        Gap.h16,
                        const Divider(
                          color: AppColors.lightgrey,
                          height: 5,
                          thickness: 0.5,
                        ),
                        Gap.h8,
                      ],
                    ),
                  Expanded(
                    child: _filteredOptions.isEmpty
                        ? Center(
                            child: AppText.body(
                              widget.enableSearch && _searchController.text.isNotEmpty
                                  ? 'No results for "${_searchController.text}"'
                                  : 'No options available.',
                              color: AppColors.darkgrey,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredOptions.length,
                            itemBuilder: (context, index) {
                              final option = _filteredOptions[index];
                              return ListTile(
                                title: Text(option),
                                onTap: () {
                                  setState(() {
                                    widget.controller.text = option;
                                    widget.onOptionSelected?.call(option);
                                  });
                                  Navigator.pop(context); // Close the modal
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.options.isEmpty ? null : _showOptionsModal, // Disable tap if no options
      child: Container(
        height: 55.h,
        width: double.infinity,
        padding: EdgeInsets.only(top: 12.h, bottom: 12.w, left: 12.w),
        decoration: BoxDecoration(
          color: AppColors.formWhite,
          border: Border.fromBorderSide(
            BorderSide(
              color: AppColors.black.withOpacity(0.4),
            ),
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( // Use Expanded to prevent overflow
              child: AppText.button(
                widget.controller.text.isEmpty
                    ? widget.title
                    : widget.controller.text,
                color: widget.controller.text.isEmpty
                    ? widget.textColor
                    : AppColors.black,
                fontSize: 14.sp,
                maxLines: 1, // Prevent text overflow
                overflow: TextOverflow.ellipsis, // Add ellipsis for long text
              ),
            ),
            IconButton(
              onPressed: widget.options.isEmpty ? null : _showOptionsModal, // Disable if no options
              icon: const Icon(CupertinoIcons.chevron_down),
              color: AppColors.formFillColor,
              iconSize: 20.r,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the search controller
    super.dispose();
  }
}