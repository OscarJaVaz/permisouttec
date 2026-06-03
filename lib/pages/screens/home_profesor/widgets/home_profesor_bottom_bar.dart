import 'package:flutter/material.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/theme/utt_text_styles.dart';

class HomeProfesorBottomBar extends StatelessWidget {
  const HomeProfesorBottomBar({
    super.key,
    required this.onSolicitarPermiso,
    required this.onCerrarSesion,
    this.isLoading = false,
  });

  final VoidCallback? onSolicitarPermiso;
  final VoidCallback? onCerrarSesion;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: LoginColors.paperWhite,
        border: Border(top: BorderSide(color: LoginColors.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isLoading ? null : onSolicitarPermiso,
              icon: const Icon(Icons.add_circle_outline, size: 22),
              label: Text(
                'Solicitar permiso',
                style: UttTextStyles.montserrat(16, FontWeight.w600).copyWith(
                  color: LoginColors.onPrimary,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.deepEmerald,
                foregroundColor: LoginColors.onPrimary,
                disabledBackgroundColor:
                    LoginColors.deepEmerald.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: isLoading ? null : onCerrarSesion,
            child: Text(
              'Cerrar sesión',
              style: UttTextStyles.inter(
                14,
                color: LoginColors.secondary,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
