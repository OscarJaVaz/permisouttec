import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/config/theme/app_motion.dart';
import 'package:permisouttec/domain/entities/stored_credential_profile.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/services/auth_session.dart';
import 'package:permisouttec/services/home_prefetch.dart';
import 'package:permisouttec/theme/utt_spacing.dart';
import 'package:permisouttec/widgets/entrance_animation.dart';
import 'package:permisouttec/widgets/pressable_scale.dart';

/// Pantalla intermedia tras confirmar biometría: inicia sesión y navega a home.
class BiometricAuthenticatingScreen extends ConsumerStatefulWidget {
  const BiometricAuthenticatingScreen({
    super.key,
    required this.profile,
  });

  final StoredCredentialProfile profile;

  @override
  ConsumerState<BiometricAuthenticatingScreen> createState() =>
      _BiometricAuthenticatingScreenState();
}

class _BiometricAuthenticatingScreenState
    extends ConsumerState<BiometricAuthenticatingScreen> {
  bool _isWorking = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _completeSignIn());
  }

  Future<void> _completeSignIn() async {
    if (!mounted) return;
    final container = ProviderScope.containerOf(context);

    setState(() {
      _isWorking = true;
      _errorMessage = null;
    });

    final result = await signInAndPrefetchSession(
      container,
      email: widget.profile.email,
      password: widget.profile.password,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      context.go(homeRouteForUsuario(result.usuario!));
      return;
    }

    setState(() {
      _isWorking = false;
      _errorMessage = result.firebaseErrorCode == 'wrong-password'
          ? 'Las credenciales guardadas ya no son válidas. Inicia sesión con tu correo y contraseña.'
          : 'No se pudo iniciar sesión. Intenta de nuevo.';
    });
  }

  void _returnToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  Widget _centeredTextBlock({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final spacing = context.uttSpacing;

    return Padding(
      padding: spacing.screenPadding,
      child: Center(
        child: EntranceStaggerColumn(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: spacing.blockGap,
          children: children,
        ),
      ),
    );
  }

  Widget _buildWorkingContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _centeredTextBlock(
      context: context,
      children: [
        Text(
          'Autenticando',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        Text(
          'Hola, ${widget.profile.displayName}',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium,
        ),
        Text(
          'Preparando tu sesión…',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return _centeredTextBlock(
      context: context,
      children: [
        Text(
          'No pudimos entrar',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: LoginColors.onSurface,
          ),
        ),
        Text(
          _errorMessage ?? 'Ocurrió un error.',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium,
        ),
        SizedBox(
          width: double.infinity,
          child: PressableFilledButton(
            onPressed: _completeSignIn,
            style: theme.filledButtonTheme.style ??
                FilledButton.styleFrom(),
            child: Text(
              'Reintentar',
              style: textTheme.labelLarge,
            ),
          ),
        ),
        TextButton(
          onPressed: _returnToLogin,
          child: Text(
            'Volver al inicio',
            style: textTheme.titleMedium?.copyWith(
              color: LoginColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isWorking,
      child: Scaffold(
        backgroundColor: LoginColors.background,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: UttMotion.medium,
            switchInCurve: UttMotion.easeOut,
            switchOutCurve: UttMotion.easeOut,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: UttMotion.easeOut,
              );
              return FadeTransition(opacity: curved, child: child);
            },
            child: _isWorking
                ? KeyedSubtree(
                    key: const ValueKey('working'),
                    child: _buildWorkingContent(context),
                  )
                : KeyedSubtree(
                    key: const ValueKey('error'),
                    child: _buildErrorContent(context),
                  ),
          ),
        ),
      ),
    );
  }
}
