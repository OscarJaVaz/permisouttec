class UsuarioEntity {
  const UsuarioEntity({
    required this.uid,
    required this.email,
    required this.puesto,
    required this.solicitudDirectivo,
    required this.aprobadoDirectivo,
  });

  final String uid;
  final String? email;
  final String? puesto;
  final bool solicitudDirectivo;
  final bool aprobadoDirectivo;
}
