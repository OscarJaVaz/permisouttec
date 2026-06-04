abstract final class AppRoutes {
  static const login = '/login';
  static const autenticandoBiometrico = '/login/autenticando';
  static const registro = '/registro';
  static const home = '/home';
  static const homeProfesor = '/home-profesor';
  static const homeDirectivo = '/home-directivo';
  static const profesores = '/profesores';
  static const puestos = '/puestos';
  static const divisiones = '/divisiones';
  static const permisos = '/permisos';
  static const visualizarPermisos = '/visualizar-permisos';
  static const verSolicitudesDirectivos = '/ver-solicitudes-directivos';
  static const nuevoPermiso = '/nuevo-permiso';
  static const nuevoProfesor = '/nuevo-profesor';
  static const nuevoPuesto = '/nuevo-puesto';
  static const nuevaDivision = '/nueva-division';

  static const protectedPaths = <String>[
    home,
    homeProfesor,
    homeDirectivo,
    profesores,
    puestos,
    divisiones,
    permisos,
    visualizarPermisos,
    verSolicitudesDirectivos,
    nuevoPermiso,
    nuevoProfesor,
    nuevoPuesto,
    nuevaDivision,
  ];
}
