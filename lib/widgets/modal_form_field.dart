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
    this.modalHeightFactor = 0.6,
    this.enableSearch = false,
  });

  final String title;
  final List<String> options;
  final TextEditingController controller;
  final Color textColor;
  final Function(String)? onOptionSelected;
  final double modalHeightFactor;
  final bool enableSearch;

  @override
  State<ModalFormField> createState() => _ModalFormFieldState();
}

class _ModalFormFieldState extends State<ModalFormField> {
  late TextEditingController _searchController;
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredOptions = widget.options;
  }

  @override
  void didUpdateWidget(covariant ModalFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options != oldWidget.options) {
      if (widget.enableSearch) {
        _filterOptions(_searchController.text);
      } else {
        _filteredOptions = widget.options;
      }
    }
  }

  void _filterOptions(String query) {
    if (!widget.enableSearch) {
      return;
    }
    setState(() {
      if (query.isEmpty) {
        _filteredOptions = widget.options;
      } else {
        _filteredOptions = widget.options
            .where(
                (option) => option.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showOptionsModal() {
    _searchController.clear();
    _filterOptions('');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              height:
                  MediaQuery.of(context).size.height * widget.modalHeightFactor,
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
                              borderSide:
                                  const BorderSide(color: AppColors.lightgrey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide:
                                  const BorderSide(color: AppColors.lightgrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide:
                                  const BorderSide(color: AppColors.darkgrey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.h, horizontal: 12.w),
                          ),
                          onChanged: (value) {
                            modalSetState(() {
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
                              widget.enableSearch &&
                                      _searchController.text.isNotEmpty
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
      onTap: widget.options.isEmpty ? null : _showOptionsModal,
      child: Container(
        height: 45.h,
        width: double.infinity,
        padding:
            EdgeInsetsDirectional.only(top: 12.h, bottom: 12.w, start: 12.w),
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
            Expanded(
              child: AppText.button(
                widget.controller.text.isEmpty
                    ? widget.title
                    : widget.controller.text,
                color: widget.controller.text.isEmpty
                    ? widget.textColor
                    : AppColors.black,
                fontSize: 14.sp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: widget.options.isEmpty
                  ? null
                  : _showOptionsModal, // Disable if no options
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
