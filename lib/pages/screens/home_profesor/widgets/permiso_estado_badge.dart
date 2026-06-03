import 'package:flutter/material.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/theme/utt_text_styles.dart';

class PermisoEstadoBadge extends StatelessWidget {
  const PermisoEstadoBadge({super.key, required this.estado});

  final String estado;

  Color _backgroundFor(String value) {
    switch (value.toLowerCase()) {
      case 'aprobado':
        return LoginColors.deepEmerald.withValues(alpha: 0.12);
      case 'rechazado':
        return Colors.red.shade50;
      default:
        return LoginColors.surfaceSubtle;
    }
  }

  Color _foregroundFor(String value) {
    switch (value.toLowerCase()) {
      case 'aprobado':
        return LoginColors.deepEmerald;
      case 'rechazado':
        return Colors.red.shade800;
      default:
        return LoginColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = estado.isEmpty ? 'pendiente' : estado;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundFor(label),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: UttTextStyles.inter(
          11,
          color: _foregroundFor(label),
          weight: FontWeight.w700,
        ).copyWith(letterSpacing: 0.6),
      ),
    );
  }
}
