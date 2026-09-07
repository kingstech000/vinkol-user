import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/core/utils/textstyles.dart';
import 'package:starter_codes/widgets/app_textfield.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ModalFormField extends StatefulWidget {
  const ModalFormField({
    super.key,
    required this.title,
    required this.options,
    required this.controller,
    this.onOptionSelected,
    this.textColor,
    this.modalHeightFactor = 0.6,
    this.enableSearch = false,
  });

  final String title;
  final List<String> options;
  final TextEditingController controller;

  /// Overrides the shared placeholder colour. Left null the picker's
  /// placeholder matches every other field on the form.
  final Color? textColor;
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
              (option) => option.toLowerCase().contains(query.toLowerCase()),
            )
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
                            prefixIcon: const Icon(
                              PhosphorIconsRegular.magnifyingGlass,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                color: AppColors.lightgrey,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                color: AppColors.lightgrey,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                color: AppColors.darkgrey,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.h,
                              horizontal: 12.w,
                            ),
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
    final enabled = widget.options.isNotEmpty;
    // A read-only AppTextField rather than a container dressed to look like
    // one: the picker then inherits the fill, radius, padding and type of every
    // other field in the form for free, and cannot drift away from them.
    return AppTextField(
      controller: widget.controller,
      readOnly: true,
      onTap: enabled ? _showOptionsModal : null,
      hint: widget.title,
      hintStyle: widget.textColor == null
          ? null
          : headingStyle6.copyWith(color: widget.textColor, fontSize: 14),
      suffixIcon: Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: Icon(
          PhosphorIconsRegular.caretDown,
          size: 20,
          color: enabled ? AppColors.darkgrey : AppColors.lightgrey,
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
