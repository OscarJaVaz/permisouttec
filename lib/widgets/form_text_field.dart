import 'package:flutter/material.dart';
import 'package:permisouttec/widgets/dismiss_keyboard.dart';

/// Campo de formulario con [FocusNode] para pantallas con varios inputs.
class FormTextField extends StatelessWidget {
  const FormTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onFieldSubmitted,
      decoration: InputDecoration(labelText: labelText),
    );
  }
}

/// Pasa al siguiente [FocusNode] o cierra el teclado si es el último campo.
void submitFormField(
  BuildContext context, {
  FocusNode? nextFocus,
}) {
  if (nextFocus != null) {
    nextFocus.requestFocus();
  } else {
    DismissKeyboard.unfocus(context);
  }
}
