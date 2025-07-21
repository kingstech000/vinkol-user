import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'dart:async';

Future<String?> showTransactionPinModal(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final Completer<String?> pinCompleter = Completer<String?>();
  String enteredPin = '';
  FocusScope.of(context).unfocus();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Form(
              key: formKey,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(20),
                    right: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            pinCompleter.complete(null);
                          },
                          icon: const Icon(Icons.cancel),
                        ),
                      ],
                    ),
                    AppText.h4(
                      'Enter The Delivery Pin',
                      color: AppColors.black,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        bool isFilled = enteredPin.length > index;
                        bool isActive = enteredPin.length == index;

                        return AnimatedContainer(
                          duration: 200.ms,
                          margin: EdgeInsets.all(4.sp),
                          width: 50.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: isFilled
                                ? AppColors.primary.withOpacity(0.8)
                                : (isActive
                                    ? AppColors.primary.withOpacity(0.5)
                                    : AppColors.lightgrey),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.2),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              isFilled ? '●' : '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    Gap.h10,
                    GestureDetector(
                      child: Center(
                        child: AppText.caption(
                          'Enter the code given to the user to change  the status to delivered',
                          color: AppColors.primary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Number Pad
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.7,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        if (index == 9) {
                          return const SizedBox.shrink();
                        } else if (index == 10) {
                          return numberButton('0', () {
                            if (enteredPin.length < 4) {
                              setState(() {
                                enteredPin += '0';
                              });
                              if (enteredPin.length == 4) {
                                pinCompleter.complete(enteredPin);
                                Navigator.of(context).pop();
                              }
                            }
                          });
                        } else if (index == 11) {
                          return IconButton(
                            onPressed: () {
                              if (enteredPin.isNotEmpty) {
                                setState(() {
                                  enteredPin = enteredPin.substring(
                                      0, enteredPin.length - 1);
                                });
                              }
                            },
                            icon: const Icon(Icons.backspace_outlined),
                          );
                        } else {
                          return numberButton('${index + 1}', () {
                            if (enteredPin.length < 4) {
                              setState(() {
                                enteredPin += '${index + 1}';
                              });
                              if (enteredPin.length == 4) {
                                pinCompleter.complete(enteredPin);
                                Navigator.of(context).pop();
                              }
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );

  return pinCompleter.future;
}

// Function to create number buttons
Widget numberButton(String number, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.formWhite,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  );
}
