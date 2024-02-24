import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permisouttec/pages/Divisiones.dart';
import 'package:permisouttec/pages/Profesores.dart';
import 'package:permisouttec/pages/Puestos.dart';
import 'package:permisouttec/pages/VerSolicitudesDirectivosPage.dart';
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

  // Método para mostrar una alerta de confirmación antes de cerrar sesión
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe hacer clic en un botón para cerrar la alerta
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres cerrar sesión?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar la alerta
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar la alerta
                _logout(context); // Cerrar sesión
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
            icon: Icon(Icons.article_outlined), // Nuevo ícono para ver las solicitudes de directivos
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VerSolicitudesDirectivosPage()), // Navegar a la pantalla para ver las solicitudes de directivos
              );
            },
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
          VerSolicitudesDirectivosPage(),
          Container(), // Agregar una pantalla dummy para que coincida con la longitud de items
        ],
        items: [
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.work_outline),
            title: "Puestos",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.people_outline),
            title: "Profesores",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.visibility),
            title: "Permisos",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.business),
            title: "Divisiones",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.article_outlined), // Nuevo ícono para ver las solicitudes de directivos
            title: "Solicitudes",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.logout), // Nuevo ícono para cerrar sesión
            title: "Cerrar Sesión",
            activeColorPrimary: Colors.red, // Puedes cambiar el color según tus preferencias
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
        onItemSelected: (index) {
          // Manejar la acción de cerrar sesión cuando se selecciona el ícono correspondiente
          if (index == 5) {
            _showLogoutConfirmationDialog(context); // Mostrar la alerta de confirmación
          }
        },
      ),
      // Anulamos el gesto de deslizamiento para cerrar sesión en la pantalla de inicio
      extendBody: true,
      extendBodyBehindAppBar: true,
      drawerEdgeDragWidth: 0,
      drawerScrimColor: Colors.transparent,
    );
  }
}