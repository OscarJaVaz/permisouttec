import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_date_helper.dart';
import 'package:permisouttec/infraestructure/rtdb/rtdb_record.dart';
import 'package:permisouttec/pages/screens/home_profesor/widgets/home_profesor_bottom_bar.dart';
import 'package:permisouttec/pages/screens/home_profesor/widgets/home_profesor_header.dart';
import 'package:permisouttec/pages/screens/home_profesor/widgets/permiso_calendar_card.dart';
import 'package:permisouttec/pages/screens/home_profesor/widgets/permiso_day_card.dart';
import 'package:permisouttec/pages/screens/home_profesor/widgets/permiso_estado_badge.dart';
import 'package:permisouttec/pages/screens/login/colors_login.dart';
import 'package:permisouttec/providers/auth_provider.dart';
import 'package:permisouttec/providers/permisos_provider.dart';
import 'package:permisouttec/theme/utt_text_styles.dart';

class HomePageProfesor extends ConsumerStatefulWidget {
  const HomePageProfesor({super.key});

  @override
  ConsumerState<HomePageProfesor> createState() => _HomePageProfesorState();
}

class _HomePageProfesorState extends ConsumerState<HomePageProfesor> {
  late User _currentUser;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    final now = DateTime.now();
    _selectedDay = now;
    _focusedDay = now;
  }

  String get _displayName {
    final email = _currentUser.email;
    if (email == null || email.isEmpty) return 'Profesor';
    final local = email.split('@').first;
    if (local.isEmpty) return 'Profesor';
    return local[0].toUpperCase() + local.substring(1);
  }

  List<RtdbRecord> _activeRecords(List<RtdbRecord> records) {
    return records.where((r) => !r.boolValue('archivado')).toList();
  }

  List<RtdbRecord> _recordsForDay(List<RtdbRecord> records, DateTime day) {
    return _activeRecords(records).where((record) {
      return RtdbDateHelper.isSameDay(record.data['fecha'], day);
    }).toList();
  }

  int _countByEstado(List<RtdbRecord> records, String estado) {
    return _activeRecords(records)
        .where((r) => (r.string('estado') ?? '').toLowerCase() == estado)
        .length;
  }

  String _formatFecha(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showPermisoDetails(RtdbRecord record, DateTime fecha) {
    final tipo = record.string('tipo') ?? '—';
    final estado = record.string('estado') ?? 'pendiente';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: LoginColors.paperWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Detalle de ausencia',
          style: UttTextStyles.montserrat(18, FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatFecha(fecha),
              style: UttTextStyles.inter(14, color: LoginColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text('Tipo', style: UttTextStyles.inter(12, color: LoginColors.outline)),
            const SizedBox(height: 4),
            Text(tipo, style: UttTextStyles.montserrat(16, FontWeight.w600)),
            const SizedBox(height: 12),
            Text('Estado', style: UttTextStyles.inter(12, color: LoginColors.outline)),
            const SizedBox(height: 8),
            PermisoEstadoBadge(estado: estado),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cerrar',
              style: UttTextStyles.inter(
                14,
                color: LoginColors.deepEmerald,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (!mounted) return;
      context.go(AppRoutes.login);
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  Widget _buildDaySection(List<RtdbRecord> dayRecords) {
    final dayLabel =
        'Permisos del ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 12),
          child: Text(
            dayLabel.toUpperCase(),
            style: UttTextStyles.inter(
              12,
              color: LoginColors.onSurfaceVariant,
              weight: FontWeight.w600,
            ).copyWith(letterSpacing: 0.8),
          ),
        ),
        if (dayRecords.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: LoginColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LoginColors.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_outlined,
                  size: 40,
                  color: LoginColors.outline.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  'No hay permisos este día',
                  textAlign: TextAlign.center,
                  style: UttTextStyles.inter(
                    14,
                    color: LoginColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          ...dayRecords.map((record) {
            final fecha = RtdbDateHelper.fromValue(record.data['fecha']);
            final fechaLabel =
                fecha != null ? _formatFecha(fecha) : _formatFecha(_selectedDay);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PermisoDayCard(
                record: record,
                fechaLabel: fechaLabel,
                onTap: fecha != null
                    ? () => _showPermisoDetails(record, fecha)
                    : null,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildEmptyGlobal() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 56,
              color: LoginColors.deepEmerald.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no tienes solicitudes',
              textAlign: TextAlign.center,
              style: UttTextStyles.montserrat(18, FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Usa el botón inferior para registrar tu primera ausencia o permiso.',
              textAlign: TextAlign.center,
              style: UttTextStyles.inter(
                14,
                color: LoginColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermisosContent(List<RtdbRecord> records) {
    final active = _activeRecords(records);

    if (active.isEmpty) {
      return Column(
        children: [
          Expanded(child: _buildEmptyGlobal()),
          HomeProfesorBottomBar(
            isLoading: _isSigningOut,
            onSolicitarPermiso: () => context.push(AppRoutes.nuevoPermiso),
            onCerrarSesion: _signOut,
          ),
        ],
      );
    }

    final dayRecords = _recordsForDay(records, _selectedDay);
    final pendientes = _countByEstado(records, 'pendiente');
    final aprobados = _countByEstado(records, 'aprobado');

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
                  HomeProfesorHeader(
                    displayName: _displayName,
                    pendientes: pendientes,
                    aprobados: aprobados,
                  ),
                  const SizedBox(height: 20),
                  PermisoCalendarCard(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    records: records,
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                  ),
                  _buildDaySection(dayRecords),
                ],
              ),
            ),
          ),
        ),
        HomeProfesorBottomBar(
          isLoading: _isSigningOut,
          onSolicitarPermiso: () => context.push(AppRoutes.nuevoPermiso),
          onCerrarSesion: _signOut,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final permisosAsync =
        ref.watch(permisosByUsuarioStreamProvider(_currentUser.uid));

    return Scaffold(
      backgroundColor: LoginColors.background,
      body: permisosAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(
          child: CircularProgressIndicator(color: LoginColors.deepEmerald),
        ),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudieron cargar tus permisos. Intenta de nuevo.',
              textAlign: TextAlign.center,
              style: UttTextStyles.inter(14, color: LoginColors.onSurfaceVariant),
            ),
          ),
        ),
        data: _buildPermisosContent,
      ),
    );
  }
}
