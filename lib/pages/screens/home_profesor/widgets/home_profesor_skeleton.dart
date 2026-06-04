import 'package:flutter/material.dart';
import 'package:permisouttec/pages/screens/home_profesor/widgets/home_profesor_bottom_bar.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/theme/utt_text_styles.dart';

/// Placeholder estructural mientras llega el primer evento de RTDB.
class HomeProfesorSkeleton extends StatelessWidget {
  const HomeProfesorSkeleton({
    super.key,
    required this.displayName,
    this.onSolicitarPermiso,
    this.onCerrarSesion,
  });

  final String displayName;
  final VoidCallback? onSolicitarPermiso;
  final VoidCallback? onCerrarSesion;

  Widget _shimmerBox({required double height, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: LoginColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'utt-logo',
                        child: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Image.asset(
                              'assets/images/utt_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, $displayName',
                              style: UttTextStyles.montserrat(
                                22,
                                FontWeight.w600,
                                color: LoginColors.deepEmerald,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _shimmerBox(height: 14, width: 160),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _shimmerBox(height: 320),
                  const SizedBox(height: 20),
                  _shimmerBox(height: 12, width: 180),
                  const SizedBox(height: 12),
                  _shimmerBox(height: 88),
                ],
              ),
            ),
          ),
        ),
        if (onSolicitarPermiso != null && onCerrarSesion != null)
          HomeProfesorBottomBar(
            isLoading: false,
            onSolicitarPermiso: onSolicitarPermiso!,
            onCerrarSesion: onCerrarSesion!,
          ),
      ],
    );
  }
}
