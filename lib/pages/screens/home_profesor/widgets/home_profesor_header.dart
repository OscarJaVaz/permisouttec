import 'package:flutter/material.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/theme/utt_text_styles.dart';

class HomeProfesorHeader extends StatelessWidget {
  const HomeProfesorHeader({
    super.key,
    required this.displayName,
    required this.pendientes,
    required this.aprobados,
  });

  final String displayName;
  final int pendientes;
  final int aprobados;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              const SizedBox(height: 4),
              Text(
                'Tus permisos y ausencias',
                style: UttTextStyles.inter(
                  14,
                  color: LoginColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatChip(
                    label: 'Pendientes',
                    count: pendientes,
                    color: LoginColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    label: 'Aprobados',
                    count: aprobados,
                    color: LoginColors.deepEmerald,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        '$label: $count',
        style: UttTextStyles.inter(12, color: color, weight: FontWeight.w600),
      ),
    );
  }
}
