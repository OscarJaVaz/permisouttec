import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permisouttec/config/router/app_routes.dart';
import 'package:permisouttec/domain/entities/usuario_entity.dart';
import 'package:permisouttec/providers/auth_provider.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String _homeRouteForUsuario(UsuarioEntity usuario) {
    if (usuario.solicitudDirectivo && !usuario.aprobadoDirectivo) {
      return AppRoutes.homeProfesor;
    }
    if (usuario.puesto == 'Directivo') {
      return AppRoutes.home;
    }
    if (usuario.puesto == 'Profesor') {
      return AppRoutes.homeProfesor;
    }
    return AppRoutes.homeProfesor;
  }

  Future<void> fnLogin() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final usuario = await repository.signIn(
        _emailController.text,
        _passwordController.text,
      );
      if (usuario != null && mounted) {
        context.go(_homeRouteForUsuario(usuario));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        showIncorrectCredentialsAlert();
      }
    }
  }

  void showIncorrectCredentialsAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Credenciales incorrectas'),
          content: const Text(
            'El correo electrónico o la contraseña son incorrectos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        title: const Text('Permisos Uttec'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/5509/5509636.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Bienvenido',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  obscureText: _obscureText,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: fnLogin,
                  child: const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Usuario nuevo?'),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.registro),
                      child: const Text('Regístrate aquí'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
