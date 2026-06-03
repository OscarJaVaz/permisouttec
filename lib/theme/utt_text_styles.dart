import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';

abstract final class UttTextStyles {
  static TextStyle montserrat(
    double size,
    FontWeight weight, {
    Color? color,
  }) {
    return GoogleFonts.montserrat(
      fontSize: size,
      fontWeight: weight,
      color: color ?? LoginColors.onSurface,
    );
  }

  static TextStyle inter(
    double size, {
    Color? color,
    FontWeight? weight,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? LoginColors.onSurface,
    );
  }
}
