import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Palette {
  static const cream = Color(0xFFFAEBD7);
  static const purple = Color(0xFF7E3FBF);
  static const deepPurple = Color(0xFF3B1F5E);
  static const lilac = Color(0xFFD97BE8);
  static const orange = Color(0xFFFFC978);
  static const red = Color(0xFFFF1A1A);
  static const green = Color(0xFF4CB782);
}

TextStyle displayStyle(double size, {Color color = Colors.black}) =>
    GoogleFonts.abrilFatface(fontSize: size, color: color);
