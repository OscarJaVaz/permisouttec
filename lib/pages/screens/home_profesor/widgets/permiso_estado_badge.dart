import 'package:flutter/material.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/theme/utt_text_styles.dart';

class PermisoEstadoBadge extends StatelessWidget {
  const PermisoEstadoBadge({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final normalized = estado.toLowerCase();
    final (background, foreground, label) = switch (normalized) {
      'aprobado' => (
          LoginColors.deepEmerald.withValues(alpha: 0.12),
          LoginColors.deepEmerald,
          'Aprobado',
        ),
      'rechazado' => (
          const Color(0xFFB3261E).withValues(alpha: 0.12),
          const Color(0xFFB3261E),
          'Rechazado',
        ),
      _ => (
          LoginColors.institutionalGold.withValues(alpha: 0.2),
          LoginColors.secondary,
          'Pendiente',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: UttTextStyles.inter(12, color: foreground, weight: FontWeight.w600),
      ),
    );
  }
}
