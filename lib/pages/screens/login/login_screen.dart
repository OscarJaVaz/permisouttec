import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:permisouttec/config/router/app_routes.dart';

import 'package:permisouttec/config/theme/app_motion.dart';

import 'package:permisouttec/pages/screens/login/colors_login.dart';

import 'package:permisouttec/pages/screens/login/widgets/login_text_field.dart';

import 'package:permisouttec/domain/entities/stored_credential_profile.dart';

import 'package:permisouttec/pages/screens/login/login_welcome_view.dart';

import 'package:permisouttec/providers/biometric_login_provider.dart';

import 'package:permisouttec/services/auth_session.dart';
import 'package:permisouttec/services/home_prefetch.dart';

import 'package:permisouttec/widgets/dismiss_keyboard.dart';

import 'package:permisouttec/widgets/entrance_animation.dart';

import 'package:permisouttec/widgets/pressable_scale.dart';

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

  bool _forceFullLogin = false;

  @override
  void dispose() {
    _emailController.dispose();

    _passwordController.dispose();

    _emailFocusNode.dispose();

    _passwordFocusNode.dispose();

    super.dispose();
  }

  void _focusPasswordField() => _passwordFocusNode.requestFocus();

  void _togglePasswordVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  Future<void> fnLogin() async {
    await _signInWithCredentials(
      _emailController.text.trim(),
      _passwordController.text,
      persistForBiometric: true,
    );
  }

  Future<void> _signInWithCredentials(
    String email,
    String password, {
    required bool persistForBiometric,
  }) async {
    setState(() => _isLoading = true);

    try {
      final result = await signInAndPrefetchSession(
        ref,
        email: email,
        password: password,
        persistForBiometric: persistForBiometric,
      );

      if (result.isSuccess && mounted) {
        context.go(homeRouteForUsuario(result.usuario!));
      } else if (result.firebaseErrorCode == 'wrong-password' && mounted) {
        _showIncorrectCredentialsAlert();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _biometricLogin(StoredCredentialProfile profile) async {
    if (_isLoading) return;

    final biometric = ref.read(biometricAuthServiceProvider);

    final availability = await biometric.checkAvailability();

    if (!availability.isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(availability.message ?? 'Biometría no disponible.')),
        );
      }

      return;
    }

    final result = await biometric.authenticate(
      reason: 'Confirme su identidad para entrar al sistema',
    );

    if (!result.success) {
      if (mounted && result.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message!)),
        );
      }

      return;
    }

    if (!mounted) return;

    context.push(AppRoutes.autenticandoBiometrico, extra: profile);
  }

  void _switchToFullLogin() {
    setState(() => _forceFullLogin = true);
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

  Widget _buildLoginSkeleton() {
    Widget skeletonBox({double height = 56}) => Container(
          height: height,
          decoration: BoxDecoration(
            color: LoginColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
        );

    final content = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      child: Column(
        children: [
          skeletonBox(height: 100),
          const SizedBox(height: 40),
          skeletonBox(height: 24),
          const SizedBox(height: 12),
          skeletonBox(height: 16),
          const SizedBox(height: 32),
          skeletonBox(),
          const SizedBox(height: 20),
          skeletonBox(),
          const SizedBox(height: 24),
          skeletonBox(height: 52),
        ],
      ),
    );

    return UttMotion.motion(
      context,
      content,
      (w) => w
          .animate()
          .fadeIn(duration: UttMotion.medium, curve: UttMotion.easeOut),
    );
  }

  Widget _buildAuthBody(StoredCredentialProfile? profile) {
    final showWelcome = profile != null && !_forceFullLogin;

    final modeKey = showWelcome ? 'welcome' : 'full';

    return AnimatedSwitcher(
      duration: UttMotion.medium,
      switchInCurve: UttMotion.easeOut,
      switchOutCurve: UttMotion.easeOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: showWelcome
          ? SingleChildScrollView(
              key: ValueKey<String>(modeKey),
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
              child: LoginWelcomeView(
                displayName: profile.displayName,
                onBiometricLogin: () => _biometricLogin(profile),
                onUseAnotherAccount: _switchToFullLogin,
              ),
            )
          : KeyedSubtree(
              key: ValueKey<String>(modeKey),
              child: _buildFullLoginScroll(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storedProfileAsync = ref.watch(storedCredentialProfileProvider);

    return Scaffold(
      backgroundColor: LoginColors.background,
      body: DismissKeyboard(
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                child: storedProfileAsync.when(
                  loading: () => _buildLoginSkeleton(),
                  error: (_, __) => _buildFullLoginScroll(),
                  data: (profile) => _buildAuthBody(profile),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFullLoginScroll() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      child: Column(
        children: [
          EntranceFadeSlide(child: _buildHeader()),
          const SizedBox(height: 40),
          _buildForm(),
          const SizedBox(height: 16),
          EntranceFadeSlide(index: 4, child: _buildRegisterLink()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'utt-logo',
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 140,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LoginColors.deepEmerald.withValues(alpha: 0.06),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Image.asset(
                      'assets/images/utt_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Entrar al sistema',
          textAlign: TextAlign.center,
          style:
              _montserrat(24, FontWeight.w600, color: LoginColors.deepEmerald),
        ),
        const SizedBox(height: 8),
        Text(
          'Plataforma Institucional Educativa',
          textAlign: TextAlign.center,
          style: _inter(16, color: LoginColors.onSurfaceVariant).copyWith(
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: FocusTraversalGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LoginTextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              label: 'Correo electrónico',
              hint: 'correo@institucional.mx',
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email
              ],
              onFieldSubmitted: (_) => _focusPasswordField(),
              entranceIndex: 1,
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
              onFieldSubmitted: (_) => DismissKeyboard.unfocus(context),
              entranceIndex: 2,
              suffixIcon: IconButton(
                icon: AnimatedSwitcher(
                  duration: UttMotion.fast,
                  child: Icon(
                    key: ValueKey<bool>(_obscureText),
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: LoginColors.outline,
                  ),
                ),
                onPressed: _togglePasswordVisibility,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: EntranceFadeSlide(
                index: 3,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Contacte al administrador para recuperar su acceso.',
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: _inter(12,
                        color: LoginColors.secondary, weight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            EntranceFadeSlide(
              index: 4,
              child: SizedBox(
                width: double.infinity,
                child: Focus(
                  skipTraversal: true,
                  child: PressableFilledButton(
                    enabled: !_isLoading,
                    onPressed: fnLogin,
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
                      shadowColor:
                          LoginColors.deepEmerald.withValues(alpha: 0.25),
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Iniciar Sesión',
                                style:
                                    _montserrat(18, FontWeight.w600).copyWith(
                                  color: LoginColors.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.login, size: 22),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('¿Usuario nuevo? ',
            style: _inter(14, color: LoginColors.onSurfaceVariant)),
        TextButton(
          onPressed: () => context.push(AppRoutes.registro),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Regístrate aquí',
            style: _inter(14,
                color: LoginColors.deepEmerald, weight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        color: LoginColors.surfaceSubtle,
        border: Border(top: BorderSide(color: LoginColors.outlineVariant)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                size: 18,
                color: LoginColors.deepEmerald.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'UNIVERSIDAD TECNOLÓGICA DE TECÁMAC',
                  textAlign: TextAlign.center,
                  style: _inter(12,
                          color: LoginColors.deepEmerald,
                          weight: FontWeight.w600)
                      .copyWith(letterSpacing: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Aviso de Privacidad',
                  style: _inter(12, color: LoginColors.outline),
                ),
              ),
              Text('•', style: _inter(12, color: LoginColors.outlineVariant)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Ayuda',
                    style: _inter(12, color: LoginColors.outline)),
              ),
              Text('•', style: _inter(12, color: LoginColors.outlineVariant)),
              Text('v1.0.0',
                  style: _inter(12,
                      color: LoginColors.outline.withValues(alpha: 0.5))),
            ],
          ),
        ],
      ),
    );
  }
}
