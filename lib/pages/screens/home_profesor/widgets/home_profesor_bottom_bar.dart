import 'package:flutter/material.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/theme/utt_text_styles.dart';
import 'package:permisouttec/widgets/pressable_scale.dart';

class HomeProfesorBottomBar extends StatelessWidget {
  const HomeProfesorBottomBar({
    super.key,
    required this.isLoading,
    required this.onSolicitarPermiso,
    required this.onCerrarSesion,
  });

  final bool isLoading;
  final VoidCallback onSolicitarPermiso;
  final VoidCallback onCerrarSesion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: LoginColors.paperWhite,
        border: Border(top: BorderSide(color: LoginColors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: PressableFilledButton(
                enabled: !isLoading,
                onPressed: onSolicitarPermiso,
                style: FilledButton.styleFrom(
                  backgroundColor: LoginColors.deepEmerald,
                  foregroundColor: LoginColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Solicitar permiso',
                      style: UttTextStyles.montserrat(16, FontWeight.w600)
                          .copyWith(color: LoginColors.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            PressableScale(
              enabled: !isLoading,
              onPressed: isLoading ? null : onCerrarSesion,
              child: IconButton.filledTonal(
                onPressed: isLoading ? null : onCerrarSesion,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout, color: LoginColors.deepEmerald),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
