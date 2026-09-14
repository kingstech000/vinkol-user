import 'package:flutter/material.dart';

class AppColors {
  static const black = Color(0xff000000);
  static const white = Color(0xffFFFFFF);
  static const background = Color(0xFFF0F2F5);
  static const blue = Color(0xff0E6CF8);
  static const darkgrey = Color(0xff6D6969);
  static const greyLight = Color(0xFF303030);
  static const green = Color.fromARGB(255, 55, 152, 30);
  static const lightgrey = Color(0xffD9D9D9);
  static const primary = Color(0xFF0E74D8);
  static const primaryLight = Color(0xFF8068FF);
  static const purpleGrey = Color(0xFFCECAE5);
  static const red = Color(0xffE54335);

  /// The red for anything set in type — error messages, destructive labels,
  /// and any surface white text sits on. [red] stays the icon and accent red;
  /// it does not carry enough contrast to be read at body sizes.
  static const redText = Color(0xffC4342A);
  /// The brand blue for anything set in type on a non-white surface. [primary]
  /// is 4.15:1 on [background] — fine for fills, icons and controls, short of
  /// AA for a label someone has to read.
  static const primaryText = Color(0xFF0B5EB4);
  static const formFillColor = Color(0xFFEEEEEE);
  static const formWhite = Color(0xFFEEEEEE);
}
