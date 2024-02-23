import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permisouttec/pages/Divisiones.dart';
import 'package:permisouttec/pages/Profesores.dart';
import 'package:permisouttec/pages/Puestos.dart';
import 'package:permisouttec/pages/VisualizarPermisos.dart';
import 'package:permisouttec/pages/login.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Método para cerrar sesión
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Redirigir a la pantalla de inicio de sesión y reemplazar la vista actual
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()), // Redirigir a la página de inicio de sesión
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight -
                kBottomNavigationBarHeight,
          ),
          child: Placeholder(), // Aquí puedes agregar el contenido de la página principal si es necesario
        ),
      ),
      bottomNavigationBar: PersistentTabView(
        context,
        controller: PersistentTabController(initialIndex: 0),
        screens: [
          Puestos(), // Puestos
          Profesores(), // Profesores
          VisualizarPermisos(), // VisualizarPermisos
          Divisiones(), // Divisiones
        ],
        items: [
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.work_outline), // Cambia el icono de acuerdo a tus necesidades
            title: "Puestos",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.people_outline), // Cambia el icono de acuerdo a tus necesidades
            title: "Profesores",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.visibility), // Cambia el icono de acuerdo a tus necesidades
            title: "Permisos",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.business), // Cambia el icono de acuerdo a tus necesidades
            title: "Divisiones",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
        ],
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        decoration: const NavBarDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
      ),
      // Anulamos el gesto de deslizamiento para cerrar sesión en la pantalla de inicio
      extendBody: true,
      extendBodyBehindAppBar: true,
      drawerEdgeDragWidth: 0,
      drawerScrimColor: Colors.transparent,
    );
  }
}
