import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permisouttec/config/router/app_router.dart';
import 'package:permisouttec/constants/enviroment.dart';
import 'package:permisouttec/services/firebase_service.dart';

Future<void> main() async {
  await FirebaseService.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: Enviroment.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      routerConfig: router,
    );
  }
}
