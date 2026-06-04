class UsuarioEntity {
  const UsuarioEntity({
    required this.uid,
    required this.email,
    required this.puesto,
    required this.solicitudDirectivo,
    required this.aprobadoDirectivo,
    this.nombre,
    this.apellido,
    this.telefono,
    this.fechaNacimiento,
  });

  final String uid;
  final String? email;
  final String? puesto;
  final bool solicitudDirectivo;
  final bool aprobadoDirectivo;
  final String? nombre;
  final String? apellido;
  final String? telefono;
  final DateTime? fechaNacimiento;

  String get displayName {
    final full = '${nombre?.trim() ?? ''} ${apellido?.trim() ?? ''}'.trim();
    if (full.isNotEmpty) return full;
    if (email != null && email!.isNotEmpty) {
      return displayNameFromEmail(email!);
    }
    return 'Usuario';
  }

  static String displayNameFromEmail(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return 'Usuario';
    return local
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
