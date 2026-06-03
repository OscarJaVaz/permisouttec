import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Tokens de movimiento UTT; respeta preferencias de accesibilidad del sistema.
abstract final class UttMotion {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration pageFade = Duration(milliseconds: 280);
  static const Duration pageSlide = Duration(milliseconds: 300);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;

  static const int staggerBaseMs = 60;
  static const double slideOffsetY = 0.08;

  static bool disableAnimations(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// Aplica [apply] solo si las animaciones están habilitadas.
  static Widget motion(
    BuildContext context,
    Widget child,
    Widget Function(Widget) apply,
  ) {
    if (disableAnimations(context)) return child;
    return apply(child);
  }

  /// Efectos estándar de entrada (fade + slide vertical).
  static Widget entranceWidget(
    Widget widget, {
    int index = 0,
    Duration? duration,
    double beginY = slideOffsetY,
  }) {
    final stagger = Duration(milliseconds: staggerBaseMs * index);
    final d = duration ?? medium;
    return widget
        .animate(delay: stagger)
        .fadeIn(duration: d, curve: easeOut)
        .slideY(begin: beginY, end: 0, duration: d, curve: easeOut);
  }

  static Duration staggerDelay(int index) =>
      Duration(milliseconds: staggerBaseMs * index);
}
