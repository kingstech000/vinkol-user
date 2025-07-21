// ignore_for_file: prefer_equal_for_default_values, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:starter_codes/core/utils/colors.dart';
import 'package:starter_codes/core/utils/textstyles.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final bool multiText;
  final TextAlign? textAlign;
  final TextOverflow overflow;
  final Color? color;
  final bool centered;
  final int? maxLines;
  final double? fontSize;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height;
  final FontStyle? fontStyle;
  final FontWeight? fontWeight;
  final double? lineHeight;

  /// free text
  ///
  /// fontSize `none`
  /// fontWeight `none`
  AppText.free(
    this.text, {
    Key? key,
    this.multiText = true,
    this.overflow = TextOverflow.ellipsis,
    this.color,
    this.maxLines,
    this.centered = false,
    this.textAlign,
    this.wordSpacing,
    this.height,
    this.letterSpacing,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
  }) : style = freeStyle.copyWith(
            color: color,
            height: height,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            fontWeight: fontWeight);

  /// h1 text
  ///
  /// fontSize `24`
  /// fontWeight `800`
  AppText.h1(
    this.text, {
    Key? key,
    this.multiText = true,
    this.overflow = TextOverflow.ellipsis,
    this.color,
    this.maxLines,
    this.centered = false,
    this.textAlign,
    this.wordSpacing,
    this.height,
    this.letterSpacing,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
  }) : style = headingStyle1.copyWith(
            color: color,
            height: height,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            fontWeight: fontWeight);

  /// h2 text
  ///
  /// fontSize `24`
  /// fontWeight `700`
  AppText.h2(
    this.text, {
    Key? key,
    this.multiText = true,
    this.overflow = TextOverflow.ellipsis,
    this.color,
    this.maxLines,
    this.centered = false,
    this.textAlign,
    this.wordSpacing,
    this.height,
    this.letterSpacing,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
  }) : style = headingStyle2.copyWith(
            color: color,
            height: height,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            fontWeight: fontWeight);

  /// h3 text
  ///
  /// fontSize `16`
  /// fontWeight `700`
  AppText.h3(
    this.text, {
    Key? key,
    this.multiText = true,
    this.overflow = TextOverflow.ellipsis,
    this.color,
    this.maxLines,
    this.centered = false,
    this.textAlign,
    this.wordSpacing,
    this.height,
    this.letterSpacing,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
  }) : style = headingStyle3.copyWith(
            color: color,
            height: height,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            fontWeight: fontWeight);

  /// h4 text
  ///
  /// fontSize `14`
  /// fontWeight `700`
  AppText.h4(
    this.text, {
    Key? key,
    this.multiText = true,
    this.overflow = TextOverflow.ellipsis,
    this.color,
    this.maxLines,
    this.centered = false,
    this.textAlign,
    this.wordSpacing,
    this.height,
    this.letterSpacing,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
  }) : style = headingStyle4.copyWith(
            color: color,
            height: height,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            fontWeight: fontWeight);

  /// h5 text
  ///
  /// fontSize `24`
  /// fontWeight `500`
  AppText.h5(
    this.text, {
    Key? key,
    this.multiText = true,
    this.overflow = TextOverflow.ellipsis,
    this.color,
    this.maxLines,
    this.centered = false,
    this.textAlign,
    this.wordSpacing,
    this.height,
    this.letterSpacing,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
  }) : style = headingStyle5.copyWith(
            color: color,
            height: height,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            fontWeight: fontWeight);

  /// h6 text
  ///
  /// fontSize `16`
  /// fontWeight `500`
  AppText.h6(
    this.text, {
    Key? key,
    this.multiText = true,
    this.overflow = TextOverflow.ellipsis,
    this.color,
    this.maxLines,
    this.centered = false,
    this.textAlign,
    this.wordSpacing,
    this.height,
    this.letterSpacing,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
  }) : style = headingStyle6.copyWith(
            color: color,
            height: height,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            fontWeight: fontWeight);

  /// body text
  ///
  /// fontSize `16`
  /// fontWeight `400`
  AppText.body(
    this.text, {
    Key? key,
    this.multiText = true,
    this.overflow = TextOverflow.ellipsis,
    this.color,
    this.maxLines,
    this.centered = false,
    this.textAlign,
    this.wordSpacing,
    this.height,
    this.letterSpacing,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
  }) : style = bodyStyle.copyWith(
          color: color,
          height: height,
          letterSpacing: letterSpacing,
          fontSize: fontSize,
          wordSpacing: wordSpacing,
          fontWeight: fontWeight,
        );

  /// caption text
  ///
  /// fontSize `10`
  /// fontWeight `300`
  AppText.caption(
    this.text, {
    Key? key,
    this.multiText = true,
    this.overflow = TextOverflow.ellipsis,
    this.color,
    this.maxLines,
    this.centered = false,
    this.textAlign,
    this.wordSpacing,
    this.height,
    this.letterSpacing,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
  }) : style = captionStyle.copyWith(
            color: color,
            height: height,
            letterSpacing: letterSpacing,
            fontSize: fontSize,
            wordSpacing: wordSpacing,
            fontWeight: fontWeight);

  /// button text
  ///
  /// fontSize `16`
  /// fontWeight `600`
  AppText.button(
    this.text, {
    Key? key,
    this.multiText = true,
    this.overflow = TextOverflow.ellipsis,
    this.color,
    this.maxLines,
    this.centered = false,
    this.textAlign,
    this.wordSpacing,
    this.height,
    this.letterSpacing,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.lineHeight,
  }) : style = buttonStyle.copyWith(
            color: color,
            height: height,
            letterSpacing: letterSpacing,
            fontSize: fontSize,
            fontStyle: fontStyle,
            wordSpacing: wordSpacing,
            fontWeight: fontWeight);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: multiText || maxLines != null ? maxLines ?? 9999999999 : 1,
      overflow: overflow,
      textAlign: centered ? TextAlign.center : textAlign ?? TextAlign.left,
      style: style.copyWith(
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        color: color ?? AppColors.black,
        height: lineHeight,
        fontSize: fontSize,
      ),
    );
  }
}
