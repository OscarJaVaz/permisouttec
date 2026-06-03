import 'package:flutter/material.dart';

/// Envuelve pantallas con campos de texto: al tocar fuera, cierra el teclado.
///
/// Usar en el `body` del [Scaffold] (o equivalente) cuando haya [TextField],
/// [TextFormField] u otros focos de entrada.
class DismissKeyboard extends StatelessWidget {
  const DismissKeyboard({super.key, required this.child});

  final Widget child;

  static void unfocus(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unfocus(context),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
