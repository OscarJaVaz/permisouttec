import 'package:flutter/material.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/theme/utt_text_styles.dart';

class HomeProfesorHeader extends StatelessWidget {
  const HomeProfesorHeader({
    super.key,
    required this.displayName,
    this.pendientes = 0,
    this.aprobados = 0,
  });

  final String displayName;
  final int pendientes;
  final int aprobados;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 48,
              child: Image.asset(
                'assets/images/utt_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 2),
                  Text(
                    'Mis permisos y ausencias',
                    style: UttTextStyles.inter(
                      14,
                      color: LoginColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (pendientes > 0 || aprobados > 0) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (pendientes > 0)
                _SummaryChip(
                  label: '$pendientes pendiente${pendientes == 1 ? '' : 's'}',
                  background: LoginColors.institutionalGold.withValues(alpha: 0.2),
                  foreground: LoginColors.secondary,
                ),
              if (aprobados > 0)
                _SummaryChip(
                  label: '$aprobados aprobado${aprobados == 1 ? '' : 's'}',
                  background: LoginColors.deepEmerald.withValues(alpha: 0.12),
                  foreground: LoginColors.deepEmerald,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
