import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';

class HomePageDirectivo extends StatefulWidget {
  const HomePageDirectivo({super.key});

  @override
  State<HomePageDirectivo> createState() => _HomePageDirectivoState();
}

class _HomePageDirectivoState extends State<HomePageDirectivo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Directivo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push(AppRoutes.visualizarPermisos),
          child: const Text('Ver Permisos Solicitados'),
        ),
      ),
    );
  }
}
