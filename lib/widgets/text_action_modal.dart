import 'package:flutter/material.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/text.dart';
import 'package:starter_codes/widgets/app_button.dart';
import 'package:starter_codes/widgets/gap.dart';
import 'package:starter_codes/widgets/white_container.dart';

void textActionModal(
  BuildContext context, {
  Color color = AppColors.primary,
  required VoidCallback onPressed,
  required String dialogText,
  required String buttonText,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: AppColors.white,
        child: WhiteContainer(
          widget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.h4(
                dialogText,
                color: AppColors.black,
              ),
              Gap.h10,
              SizedBox(
                height: 50,
                child: AppButton.primary(
                  title: buttonText,
                  onTap: () {
                    onPressed();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
