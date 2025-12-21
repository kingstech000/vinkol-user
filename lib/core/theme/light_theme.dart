import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF000001),
    primary: Color(0xFF684DFA),
    secondary: Color(0xFF8068FF),
    tertiary: Color(0xFFE4FDE1),
    inversePrimary: Color(0xFF000001),
  ),
  scaffoldBackgroundColor: const Color(0xFFEFEFF1),
  textTheme: GoogleFonts.montserratTextTheme(),
);
