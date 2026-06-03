import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permisouttec/config/theme/app_motion.dart';

/// Botón con escala al presionar y feedback háptico ligero.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.onPressed,
    required this.child,
    this.enabled = true,
    this.scale = 0.98,
    this.haptic = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool enabled;
  final double scale;
  final bool haptic;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || widget.onPressed == null) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
    if (value && widget.haptic) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = !widget.enabled || widget.onPressed == null;
    final targetScale = _pressed && !disabled ? widget.scale : 1.0;

    return AnimatedScale(
      scale: UttMotion.disableAnimations(context) ? 1.0 : targetScale,
      duration: UttMotion.fast,
      curve: UttMotion.easeOut,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: disabled ? null : (_) => _setPressed(true),
        onTapUp: disabled
            ? null
            : (_) {
                _setPressed(false);
                widget.onPressed?.call();
              },
        onTapCancel: disabled ? null : () => _setPressed(false),
        child: widget.child,
      ),
    );
  }
}

/// [FilledButton] envuelto con [PressableScale] (el tap lo maneja el wrapper).
class PressableFilledButton extends StatelessWidget {
  const PressableFilledButton({
    super.key,
    required this.onPressed,
    required this.style,
    required this.child,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final ButtonStyle style;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = enabled ? onPressed : null;
    return PressableScale(
      enabled: enabled,
      onPressed: effectiveOnPressed,
      child: IgnorePointer(
        child: FilledButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: child,
        ),
      ),
    );
  }
}
