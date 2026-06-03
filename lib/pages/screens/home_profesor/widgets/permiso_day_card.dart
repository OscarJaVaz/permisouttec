import 'package:flutter/material.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';
import 'package:permisouttec/pages/screens/home_profesor/widgets/permiso_estado_badge.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/theme/utt_text_styles.dart';

class PermisoDayCard extends StatelessWidget {
  const PermisoDayCard({
    super.key,
    required this.record,
    required this.fechaLabel,
    this.onTap,
  });

  final RtdbRecord record;
  final String fechaLabel;
  final VoidCallback? onTap;

  IconData _iconForTipo(String? tipo) {
    final t = (tipo ?? '').toLowerCase();
    if (t.contains('enfermedad') || t.contains('dolor')) {
      return Icons.medical_services_outlined;
    }
    if (t.contains('personal')) return Icons.person_outline;
    return Icons.event_note_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final tipo = record.string('tipo') ?? 'Sin tipo';
    final estado = record.string('estado') ?? 'pendiente';

    return Material(
      color: LoginColors.paperWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LoginColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: LoginColors.deepEmerald.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LoginColors.deepEmerald.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconForTipo(tipo),
                  color: LoginColors.deepEmerald,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tipo,
                      style: UttTextStyles.montserrat(16, FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fechaLabel,
                      style: UttTextStyles.inter(
                        13,
                        color: LoginColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    PermisoEstadoBadge(estado: estado),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: LoginColors.outline, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
