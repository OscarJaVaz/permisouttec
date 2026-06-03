import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/domain/entities/usuario_entity.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/pages/screens/login/widgets/login_text_field.dart';
import 'package:permisouttec/providers/auth_provider.dart';
import 'package:permisouttec/widgets/dismiss_keyboard.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _focusPasswordField() {
    _passwordFocusNode.requestFocus();
  }

  void _submitLogin() {
    DismissKeyboard.unfocus(context);
    if (!_isLoading) {
      fnLogin();
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  String _homeRouteForUsuario(UsuarioEntity usuario) {
    if (usuario.solicitudDirectivo && !usuario.aprobadoDirectivo) {
      return AppRoutes.homeProfesor;
    }
    if (usuario.puesto == 'Directivo') {
      return AppRoutes.home;
    }
    if (usuario.puesto == 'Profesor') {
      return AppRoutes.homeProfesor;
    }
    return AppRoutes.homeProfesor;
  }

  Future<void> fnLogin() async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      final usuario = await repository.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (usuario != null && mounted) {
        context.go(_homeRouteForUsuario(usuario));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' && mounted) {
        _showIncorrectCredentialsAlert();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showIncorrectCredentialsAlert() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Credenciales incorrectas'),
        content: const Text(
          'El correo electrónico o la contraseña son incorrectos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  TextStyle _serifHeadline(double size, FontWeight weight) {
    return GoogleFonts.sourceSerif4(
      fontSize: size,
      fontWeight: weight,
      color: LoginColors.primary,
      letterSpacing: -0.5,
    );
  }

  TextStyle _body(double size, {Color? color, FontWeight? weight}) {
    return GoogleFonts.hankenGrotesk(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? LoginColors.onSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyFont = _body(16);
    final labelFont = _body(12, color: LoginColors.onSurfaceVariant, weight: FontWeight.w700);

    return Scaffold(
      backgroundColor: LoginColors.surface,
      body: DismissKeyboard(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                _buildBranding(),
                const SizedBox(height: 32),
                _buildLoginCard(bodyFont),
                const SizedBox(height: 32),
                _buildSupportingLinks(labelFont, bodyFont),
                const SizedBox(height: 24),
                _buildFooter(labelFont, bodyFont),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            color: LoginColors.surfaceLowest,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/images/utt_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Text('PIUTTEC', style: _serifHeadline(24, FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          'PLATAFORMA DE INFORMACIÓN',
          style: _body(
            14,
            color: LoginColors.onSurfaceVariant,
            weight: FontWeight.w600,
          ).copyWith(letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _buildLoginCard(TextStyle bodyFont) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
      decoration: BoxDecoration(
        color: LoginColors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FocusTraversalGroup(
        child: Column(
        children: [
          Text(
            'Entrar al sistema',
            style: _body(18, weight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          LoginTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'Correo electrónico',
            hint: 'correo@institucional.mx',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            onFieldSubmitted: (_) => _focusPasswordField(),
          ),
          const SizedBox(height: 20),
          LoginTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Contraseña',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureText,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _submitLogin(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: LoginColors.outline,
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : fnLogin,
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.primary,
                foregroundColor: LoginColors.onPrimary,
                disabledBackgroundColor: LoginColors.primary.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: LoginColors.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Iniciar Sesión', style: bodyFont.copyWith(
                          color: LoginColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        )),
                        const SizedBox(width: 8),
                        const Icon(Icons.login, size: 22),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contacte al administrador para recuperar su acceso.'),
                ),
              );
            },
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: _body(14, color: LoginColors.secondary, weight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('¿Usuario nuevo? ', style: _body(14, color: LoginColors.onSurfaceVariant)),
              TextButton(
                onPressed: () => context.push(AppRoutes.registro),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Regístrate aquí',
                  style: _body(14, color: LoginColors.scholarBlue, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildSupportingLinks(TextStyle labelFont, TextStyle bodyFont) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              child: Text('Aviso Integral', style: labelFont.copyWith(letterSpacing: 0.5)),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () {},
              child: Text('Aviso de Privacidad', style: labelFont.copyWith(letterSpacing: 0.5)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Acceda con sus credenciales institucionales para ingresar a la plataforma.',
            textAlign: TextAlign.center,
            style: bodyFont.copyWith(color: LoginColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(TextStyle labelFont, TextStyle bodyFont) {
    return Column(
      children: [
        const Divider(color: LoginColors.outlineVariant, height: 48),
        Text(
          'Universidad Tecnológica de Tecámac',
          textAlign: TextAlign.center,
          style: labelFont.copyWith(letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          'Plataforma de Información Universitaria © 2024',
          textAlign: TextAlign.center,
          style: bodyFont.copyWith(
            color: LoginColors.outline,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
