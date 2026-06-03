import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permisouttec/config/theme/app_motion.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/widgets/entrance_animation.dart';
import 'package:permisouttec/widgets/pressable_scale.dart';

class LoginWelcomeView extends StatelessWidget {
  const LoginWelcomeView({
    super.key,
    required this.displayName,
    required this.isLoading,
    required this.onBiometricLogin,
    required this.onUseAnotherAccount,
  });

  final String displayName;
  final bool isLoading;
  final VoidCallback onBiometricLogin;
  final VoidCallback onUseAnotherAccount;

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

  Widget _buildLogo() {
    return Hero(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return EntranceStaggerColumn(
      spacing: 0,
      children: [
        _buildLogo(),
        const SizedBox(height: 32),
        Text(
          'Hola, $displayName',
          textAlign: TextAlign.center,
          style: _montserrat(26, FontWeight.w600, color: LoginColors.deepEmerald),
        ),
        const SizedBox(height: 8),
        Text(
          'Plataforma Institucional Educativa',
          textAlign: TextAlign.center,
          style: _inter(16, color: LoginColors.onSurfaceVariant),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: PressableFilledButton(
            enabled: !isLoading,
            onPressed: onBiometricLogin,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: UttMotion.fast,
                  switchInCurve: UttMotion.easeOut,
                  switchOutCurve: UttMotion.easeOut,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: LoginColors.onPrimary,
                          ),
                        )
                      : const Icon(
                          key: ValueKey('fingerprint'),
                          Icons.fingerprint,
                          size: 26,
                          color: LoginColors.onPrimary,
                        ),
                ),
                const SizedBox(width: 10),
                Text(
                  isLoading ? 'Validando...' : 'Acceso biométrico',
                  style: _montserrat(18, FontWeight.w600).copyWith(
                    color: LoginColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: isLoading ? null : onUseAnotherAccount,
          child: Text(
            'Iniciar con otra cuenta',
            style: _inter(14, color: LoginColors.secondary, weight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
