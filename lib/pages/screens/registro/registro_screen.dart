import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permisouttec/providers/permisos_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/config/theme/app_motion.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/pages/screens/login/widgets/login_text_field.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_date_helper.dart';
import 'package:permisouttec/pages/screens/registro/widgets/registro_date_field.dart';
import 'package:permisouttec/pages/screens/registro/widgets/registro_dropdown_field.dart';
import 'package:permisouttec/services/rtdb_auth_sync.dart';
import 'package:permisouttec/widgets/animated_dialog.dart';
import 'package:permisouttec/widgets/dismiss_keyboard.dart';
import 'package:permisouttec/widgets/entrance_animation.dart';
import 'package:permisouttec/widgets/pressable_scale.dart';

class RegistroPage extends ConsumerStatefulWidget {
  const RegistroPage({super.key});

  @override
  ConsumerState<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends ConsumerState<RegistroPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nombreFocusNode = FocusNode();
  final FocusNode _apellidoFocusNode = FocusNode();
  final FocusNode _telefonoFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final List<String> _puestos = ['Directivo', 'Profesor'];

  String? _selectedPuesto;
  DateTime? _fechaNacimiento;
  bool _obscurePassword = true;
  bool _privacyAccepted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nombreFocusNode.dispose();
    _apellidoFocusNode.dispose();
    _telefonoFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String _telefonoDigits() =>
      _telefonoController.text.replaceAll(RegExp(r'\D'), '');

  Future<void> _pickFechaNacimiento() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('es', 'MX'),
      initialDate: _fechaNacimiento ?? DateTime(now.year - 22, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  bool _validateForm() {
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    if (nombre.isEmpty || apellido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu nombre y apellido.')),
      );
      return false;
    }
    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona tu fecha de nacimiento.')),
      );
      return false;
    }
    final telefono = _telefonoDigits();
    if (telefono.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un número telefónico válido (10 dígitos).'),
        ),
      );
      return false;
    }
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo electrónico válido.')),
      );
      return false;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres.'),
        ),
      );
      return false;
    }
    if (_selectedPuesto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione su puesto.')),
      );
      return false;
    }
    if (!_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe aceptar el aviso de privacidad para continuar.'),
        ),
      );
      return false;
    }
    return true;
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
    if (!_validateForm()) return;

    DismissKeyboard.unfocus(context);
    setState(() => _isLoading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await syncAuthTokenForRtdb();

      final nombre = _nombreController.text.trim();
      final apellido = _apellidoController.text.trim();
      await userCredential.user?.updateDisplayName('$nombre $apellido');

      await ref.read(usuariosDatasourceProvider).setUsuario(
            userCredential.user!.uid,
            {
              'email': _emailController.text.trim(),
              'nombre': nombre,
              'apellido': apellido,
              'telefono': _telefonoDigits(),
              'fecha_nacimiento':
                  RtdbDateHelper.toDayMillis(_fechaNacimiento!),
              'puesto': _selectedPuesto,
              'solicitud_directivo': _selectedPuesto == 'Directivo',
              'aprobado_directivo': false,
            },
          );

      if (!mounted) return;
      await showAnimatedDialog<void>(
        context: context,
        child: AlertDialog(
          backgroundColor: LoginColors.paperWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Registro exitoso',
            style: _montserrat(18, FontWeight.w600, color: LoginColors.deepEmerald),
          ),
          content: Text(
            'Tu solicitud de registro ha sido enviada. Deberá ser aprobada por un directivo en caso de que hayas solicitado ser un directivo; en caso contrario, omite este mensaje.',
            style: _inter(14, color: LoginColors.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(AppRoutes.login);
              },
              child: Text(
                'OK',
                style: _inter(14, color: LoginColors.deepEmerald, weight: FontWeight.w600),
              ),
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
              EntranceFadeSlide(
                child: Text(
                  'Comienza tu registro',
                  style: _montserrat(24, FontWeight.w600, color: LoginColors.deepEmerald),
                ),
              ),
              const SizedBox(height: 8),
              EntranceFadeSlide(
                index: 1,
                child: Text(
                  'Crea tu cuenta institucional para acceder al portal',
                  style: _inter(16, color: LoginColors.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 32),
              FocusTraversalGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LoginTextField(
                      controller: _nombreController,
                      focusNode: _nombreFocusNode,
                      label: 'Nombre(s)',
                      hint: 'Ingresa tu nombre',
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.givenName],
                      onFieldSubmitted: (_) => _apellidoFocusNode.requestFocus(),
                      entranceIndex: 2,
                    ),
                    const SizedBox(height: 20),
                    LoginTextField(
                      controller: _apellidoController,
                      focusNode: _apellidoFocusNode,
                      label: 'Apellidos',
                      hint: 'Ingresa tus apellidos',
                      prefixIcon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.familyName],
                      onFieldSubmitted: (_) => _telefonoFocusNode.requestFocus(),
                      entranceIndex: 3,
                    ),
                    const SizedBox(height: 20),
                    EntranceFadeSlide(
                      index: 4,
                      child: RegistroDateField(
                        label: 'Fecha de nacimiento',
                        hint: 'Ingresa tu fecha de nacimiento',
                        value: _fechaNacimiento,
                        onTap: _pickFechaNacimiento,
                      ),
                    ),
                    const SizedBox(height: 20),
                    LoginTextField(
                      controller: _telefonoController,
                      focusNode: _telefonoFocusNode,
                      label: 'Teléfono',
                      hint: 'Ingresa tu teléfono',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                      entranceIndex: 5,
                    ),
                    const SizedBox(height: 20),
                    LoginTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      label: 'Correo electrónico',
                      hint: 'Ingresa tu correo electrónico',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                      entranceIndex: 6,
                    ),
                    const SizedBox(height: 20),
                    LoginTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      label: 'Contraseña',
                      hint: 'Ingresa tu contraseña',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => DismissKeyboard.unfocus(context),
                      entranceIndex: 7,
                      suffixIcon: IconButton(
                        icon: AnimatedSwitcher(
                          duration: UttMotion.fast,
                          switchInCurve: UttMotion.easeOut,
                          switchOutCurve: UttMotion.easeOut,
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            key: ValueKey<bool>(_obscurePassword),
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: LoginColors.outline,
                          ),
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    EntranceFadeSlide(
                      index: 8,
                      child: RegistroDropdownField(
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
                    ),
                    const SizedBox(height: 16),
                    EntranceFadeSlide(
                      index: 9,
                      child: Row(
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
                    ),
                    const SizedBox(height: 28),
                    EntranceFadeSlide(
                      index: 10,
                      child: SizedBox(
                        width: double.infinity,
                        child: Focus(
                          skipTraversal: true,
                          child: PressableFilledButton(
                            enabled: !_isLoading,
                            onPressed: _register,
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
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              EntranceFadeSlide(
                index: 11,
                child: Center(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
