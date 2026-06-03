import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/theme/app_motion.dart';

CustomTransitionPage<T> fadeTransitionPage<T>({
  required LocalKey key,
  required Widget child,
  Duration? duration,
}) {
  final d = duration ?? UttMotion.pageFade;
  return CustomTransitionPage<T>(
    key: key,
    transitionDuration: d,
    reverseTransitionDuration: d,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: UttMotion.easeOut);
      return FadeTransition(opacity: curved, child: child);
    },
  );
}

CustomTransitionPage<T> slideTransitionPage<T>({
  required LocalKey key,
  required Widget child,
  Duration? duration,
  Offset begin = const Offset(1.0, 0.0),
}) {
  final d = duration ?? UttMotion.pageSlide;
  return CustomTransitionPage<T>(
    key: key,
    transitionDuration: d,
    reverseTransitionDuration: d,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: begin, end: Offset.zero)
          .chain(CurveTween(curve: UttMotion.easeOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

/// Transición tipo fade-through (escala + fade) sin paquete extra.
CustomTransitionPage<T> fadeThroughTransitionPage<T>({
  required LocalKey key,
  required Widget child,
  Duration? duration,
}) {
  final d = duration ?? UttMotion.pageFade;
  return CustomTransitionPage<T>(
    key: key,
    transitionDuration: d,
    reverseTransitionDuration: d,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: UttMotion.easeOut);
      final scale = Tween<double>(begin: 0.96, end: 1).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}
