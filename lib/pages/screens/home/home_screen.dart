import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/pages/screens/divisiones/divisiones_screen.dart';
import 'package:permisouttec/pages/screens/profesores/profesores_screen.dart';
import 'package:permisouttec/pages/screens/puestos/puestos_screen.dart';
import 'package:permisouttec/pages/screens/ver_solicitudes_directivos/ver_solicitudes_directivos_screen.dart';
import 'package:permisouttec/pages/screens/visualizar_permisos/visualizar_permisos_screen.dart';
import 'package:permisouttec/services/auth_sign_out.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final PersistentTabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = PersistentTabController(initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await signOutAndClearRtdb(ref);
    if (context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres cerrar sesión?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.article_outlined),
            onPressed: () =>
                context.push(AppRoutes.verSolicitudesDirectivos),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight -
                kBottomNavigationBarHeight,
          ),
          child: const Placeholder(),
        ),
      ),
      bottomNavigationBar: PersistentTabView(
        context,
        controller: _tabController,
        screens: [
          const Puestos(),
          const Profesores(),
          const VisualizarPermisos(),
          const Divisiones(),
          const VerSolicitudesDirectivosPage(),
          const SizedBox.shrink(),
        ],
        items: [
          PersistentBottomNavBarItem(
            icon: Icon(Icons.work_outline),
            title: 'Puestos',
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(Icons.people_outline),
            title: 'Profesores',
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(Icons.visibility),
            title: 'Permisos',
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(Icons.business),
            title: 'Divisiones',
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(Icons.article_outlined),
            title: 'Solicitudes',
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(Icons.logout),
            title: 'Cerrar Sesión',
            activeColorPrimary: Colors.red,
            inactiveColorPrimary: Colors.grey,
          ),
        ],
        confineToSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        decoration: const NavBarDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        onItemSelected: (index) {
          if (index == 5) {
            _showLogoutConfirmationDialog(context);
          }
        },
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      drawerEdgeDragWidth: 0,
      drawerScrimColor: Colors.transparent,
    );
  }
}
