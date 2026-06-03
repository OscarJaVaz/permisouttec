import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/pages/screens/login/widgets/login_text_field.dart';
import 'package:permisouttec/pages/screens/registro/widgets/registro_dropdown_field.dart';
import 'package:permisouttec/widgets/dismiss_keyboard.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final List<String> _puestos = ['Directivo', 'Profesor'];

  String? _selectedPuesto;
  bool _obscurePassword = true;
  bool _privacyAccepted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  TextStyle _montserrat(double size, FontWeight weight, {Color? color}) {
    return GoogleFonts.montserrat(
      fontSize: size,
      fontWeight: weight,
      color: color ?? LoginColors.onSurface,
    );
  }

  TextStyle _inter(double size, {Color? color, FontWeight? weight}) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? LoginColors.onSurface,
    );
  }

  Future<void> _register() async {
    if (!_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe aceptar el aviso de privacidad para continuar.'),
        ),
      );
      return;
    }
    if (_selectedPuesto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione su puesto.')),
      );
      return;
    }

    DismissKeyboard.unfocus(context);
    setState(() => _isLoading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'email': _emailController.text.trim(),
        'puesto': _selectedPuesto,
        'solicitud_directivo': _selectedPuesto == 'Directivo',
        'aprobado_directivo': false,
      });

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Registro exitoso'),
          content: const Text(
            'Tu solicitud de registro ha sido enviada. Deberá ser aprobada por un directivo en caso de que hayas solicitado ser un directivo; en caso contrario, omite este mensaje.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go(AppRoutes.login);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'email-already-in-use' => 'Este correo ya está registrado.',
        'weak-password' => 'La contraseña es demasiado débil.',
        'invalid-email' => 'El correo electrónico no es válido.',
        _ => 'No se pudo completar el registro. Intente de nuevo.',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (kDebugMode) print('Error al registrar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar. Intente de nuevo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        backgroundColor: LoginColors.paperWhite,
        surfaceTintColor: LoginColors.paperWhite,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: LoginColors.deepEmerald),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
        ),
        title: Text(
          'UTT Permisos',
          style: _montserrat(20, FontWeight.w700, color: LoginColors.deepEmerald),
        ),
        centerTitle: true,
      ),
      body: DismissKeyboard(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Comienza tu registro',
                style: _montserrat(24, FontWeight.w600, color: LoginColors.deepEmerald),
              ),
              const SizedBox(height: 8),
              Text(
                'Crea tu cuenta institucional para acceder al portal',
                style: _inter(16, color: LoginColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              FocusTraversalGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LoginTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      label: 'Correo electrónico',
                      hint: 'ejemplo@utt.edu.mx',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: 20),
                    LoginTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      label: 'Contraseña',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => DismissKeyboard.unfocus(context),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: LoginColors.outline,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    RegistroDropdownField(
                      label: 'Puesto',
                      hint: 'Selecciona tu puesto',
                      value: _selectedPuesto,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Selecciona tu puesto'),
                        ),
                        ..._puestos.map(
                          (puesto) => DropdownMenuItem(
                            value: puesto,
                            child: Text(puesto),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedPuesto = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _privacyAccepted,
                            activeColor: LoginColors.deepEmerald,
                            side: const BorderSide(color: LoginColors.outlineVariant),
                            onChanged: (value) {
                              setState(() => _privacyAccepted = value ?? false);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _privacyAccepted = !_privacyAccepted);
                            },
                            child: Text.rich(
                              TextSpan(
                                style: _inter(12, color: LoginColors.onSurfaceVariant),
                                children: [
                                  const TextSpan(text: 'Acepto el '),
                                  TextSpan(
                                    text: 'Aviso de Privacidad',
                                    style: _inter(
                                      12,
                                      color: LoginColors.deepEmerald,
                                      weight: FontWeight.w600,
                                    ).copyWith(decoration: TextDecoration.underline),
                                  ),
                                  const TextSpan(
                                    text: ' y los términos de uso institucional.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _register,
                        style: FilledButton.styleFrom(
                          backgroundColor: LoginColors.deepEmerald,
                          foregroundColor: LoginColors.onPrimary,
                          disabledBackgroundColor:
                              LoginColors.deepEmerald.withValues(alpha: 0.6),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: LoginColors.deepEmerald.withValues(alpha: 0.25),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: LoginColors.onPrimary,
                                ),
                              )
                            : Text(
                                'Registrarse',
                                style: _montserrat(18, FontWeight.w700).copyWith(
                                  color: LoginColors.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: Text.rich(
                    TextSpan(
                      style: _inter(16, color: LoginColors.onSurfaceVariant),
                      children: [
                        const TextSpan(text: '¿Ya tienes una cuenta? '),
                        TextSpan(
                          text: 'Iniciar sesión',
                          style: _inter(
                            16,
                            color: LoginColors.deepEmerald,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
