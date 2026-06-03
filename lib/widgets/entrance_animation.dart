import 'package:flutter/material.dart';
import 'package:permisouttec/config/theme/app_motion.dart';

/// Envuelve un hijo con fade + slide vertical escalonado.
class EntranceFadeSlide extends StatelessWidget {
  const EntranceFadeSlide({
    super.key,
    required this.child,
    this.index = 0,
    this.duration,
    this.beginY = UttMotion.slideOffsetY,
  });

  final Widget child;
  final int index;
  final Duration? duration;
  final double beginY;

  @override
  Widget build(BuildContext context) {
    return UttMotion.motion(
      context,
      child,
      (w) => UttMotion.entranceWidget(
        w,
        index: index,
        duration: duration,
        beginY: beginY,
      ),
    );
  }
}

/// Aplica [EntranceFadeSlide] a cada hijo directo de una columna.
class EntranceStaggerColumn extends StatelessWidget {
  const EntranceStaggerColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 0,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final animated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0 && spacing > 0) {
        animated.add(SizedBox(height: spacing));
      }
      animated.add(EntranceFadeSlide(index: i, child: children[i]));
    }
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: animated,
    );
  }
}

/// Extensión para animar listas de widgets con índice base.
extension EntranceAnimateList on List<Widget> {
  List<Widget> withEntranceStagger({int startIndex = 0}) {
    return asMap().entries
        .map(
          (e) => EntranceFadeSlide(
            index: startIndex + e.key,
            child: e.value,
          ),
        )
        .toList();
  }
}
