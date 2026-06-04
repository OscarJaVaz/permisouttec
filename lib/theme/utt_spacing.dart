import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Espaciado derivado del tema Material, densidad visual y padding del sistema.
@immutable
class UttSpacing {
  const UttSpacing({
    required this.screenHorizontal,
    required this.blockGap,
  });

  final double screenHorizontal;
  final double blockGap;

  EdgeInsets get screenPadding =>
      EdgeInsets.symmetric(horizontal: screenHorizontal);

  static UttSpacing of(BuildContext context) {
    final theme = Theme.of(context);
    final viewPadding = MediaQuery.paddingOf(context);
    final textTheme = theme.textTheme;
    final density = theme.visualDensity;

    final materialUnit =
        kMinInteractiveDimension + density.baseSizeAdjustment.dx;

    final horizontalInset = math.max(
      viewPadding.left,
      math.max(viewPadding.right, materialUnit),
    );

    final materialTextTheme = ThemeData(useMaterial3: true).textTheme;
    final headlineSize = textTheme.headlineSmall?.fontSize ??
        materialTextTheme.headlineSmall!.fontSize!;
    final bodySize = textTheme.titleMedium?.fontSize ??
        materialTextTheme.titleMedium!.fontSize!;

    return UttSpacing(
      screenHorizontal: horizontalInset,
      blockGap: (headlineSize + bodySize) / 2,
    );
  }
}

extension UttSpacingContext on BuildContext {
  UttSpacing get uttSpacing => UttSpacing.of(this);
}
