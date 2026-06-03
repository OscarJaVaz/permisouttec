import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/config/transitions/page_transitions.dart';
import 'package:permisouttec/pages/screens/divisiones/divisiones_screen.dart';
import 'package:permisouttec/pages/screens/home/home_screen.dart';
import 'package:permisouttec/pages/screens/home_directivo/home_directivo_screen.dart';
import 'package:permisouttec/pages/screens/home_profesor/home_profesor_screen.dart';
import 'package:permisouttec/pages/screens/login/login_page_with_background.dart';
import 'package:permisouttec/pages/screens/nueva_division/nueva_division_screen.dart';
import 'package:permisouttec/pages/screens/nuevo_permiso/nuevo_permiso_screen.dart';
import 'package:permisouttec/pages/screens/nuevo_profesor/nuevo_profesor_screen.dart';
import 'package:permisouttec/pages/screens/nuevo_puesto/nuevo_puesto_screen.dart';
import 'package:permisouttec/pages/screens/permisos/permisos_screen.dart';
import 'package:permisouttec/pages/screens/profesores/profesores_screen.dart';
import 'package:permisouttec/pages/screens/puestos/puestos_screen.dart';
import 'package:permisouttec/pages/screens/registro/registro_screen.dart';
import 'package:permisouttec/pages/screens/ver_solicitudes_directivos/ver_solicitudes_directivos_screen.dart';
import 'package:permisouttec/pages/screens/visualizar_permisos/visualizar_permisos_screen.dart';
import 'package:permisouttec/providers/auth_provider.dart';

final routerRefreshNotifierProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier();
  ref.listen(authStateProvider, (_, __) => notifier.refresh());
  ref.onDispose(notifier.dispose);
  return notifier;
});

class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final location = state.matchedLocation;
      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.registro;

      if (!isLoggedIn &&
          AppRoutes.protectedPaths.contains(location) &&
          !isAuthRoute) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const LoginPageWithBackground(),
        ),
      ),
      GoRoute(
        path: AppRoutes.registro,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const RegistroPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.homeProfesor,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const HomePageProfesor(),
        ),
      ),
      GoRoute(
        path: AppRoutes.homeDirectivo,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const HomePageDirectivo(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profesores,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const Profesores(),
        ),
      ),
      GoRoute(
        path: AppRoutes.puestos,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const Puestos(),
        ),
      ),
      GoRoute(
        path: AppRoutes.divisiones,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const Divisiones(),
        ),
      ),
      GoRoute(
        path: AppRoutes.permisos,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const Permisos(),
        ),
      ),
      GoRoute(
        path: AppRoutes.visualizarPermisos,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const VisualizarPermisos(),
        ),
      ),
      GoRoute(
        path: AppRoutes.verSolicitudesDirectivos,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const VerSolicitudesDirectivosPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.nuevoPermiso,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const NuevoPermiso(),
        ),
      ),
      GoRoute(
        path: AppRoutes.nuevoProfesor,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const NuevoProfesor(),
        ),
      ),
      GoRoute(
        path: AppRoutes.nuevoPuesto,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const NuevoPuesto(),
        ),
      ),
      GoRoute(
        path: AppRoutes.nuevaDivision,
        pageBuilder: (context, state) => slideTransitionPage(
          key: state.pageKey,
          child: const NuevaDivision(),
        ),
      ),
    ],
  );
});
